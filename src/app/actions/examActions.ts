"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath, revalidateTag } from "next/cache";
import { saveUploadedFile } from "@/lib/fileUpload";
import path from "path";
import { getCurrentUser } from "./authActions";
import { logAction } from "@/lib/auditLogger";

// SINAVLARI LİSTELE (Sayfalama + Sıralama)
export async function getExams(filters?: { search?: string, sortBy?: string, page?: number, pageSize?: number }) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;

  if (filters?.search && filters.search.trim() !== "") {
    whereClause.OR = [
      { title: { contains: filters.search, mode: 'insensitive' } },
      { description: { contains: filters.search, mode: 'insensitive' } },
    ];
  }

  let orderBy: any = { createdAt: "desc" };
  if (filters?.sortBy) {
    switch (filters.sortBy) {
      case "oldest": orderBy = { createdAt: "asc" }; break;
      case "az": orderBy = { title: "asc" }; break;
      case "za": orderBy = { title: "desc" }; break;
      case "updated": orderBy = { updatedAt: "desc" }; break;
      case "newest":
      default: orderBy = { createdAt: "desc" }; break;
    }
  }

  const page = filters?.page || 1;
  const pageSize = filters?.pageSize || 12;
  const skip = (page - 1) * pageSize;

  const [exams, totalCount] = await Promise.all([
    prisma.exam.findMany({
      where: whereClause,
      orderBy,
      skip,
      take: pageSize,
      include: {
        groups: true,
        keys: true,
        _count: { select: { results: true } }
      }
    }),
    prisma.exam.count({ where: whereClause })
  ]);

  return { exams, totalCount, totalPages: Math.ceil(totalCount / pageSize) };
}

// SINAV OLUŞTUR (Dosya Yükleme Dahil)
export async function createExam(formData: FormData) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  const title = formData.get("title") as string;
  const description = formData.get("description") as string;

  const sectionsStr = formData.get("sections") as string;
  let sectionsData = [];
  let questionCount = 0;

  if (sectionsStr) {
    sectionsData = JSON.parse(sectionsStr);
    questionCount = sectionsData.reduce((acc: number, s: any) => acc + (parseInt(s.count) || 0), 0);
  } else {
    questionCount = parseInt(formData.get("questionCount") as string) || 0;
  }
  const selectedGroupsStr = formData.get("groups") as string; // "id1,id2"
  
  // PDF Dosyaları
  const pdfFile = formData.get("pdfFile") as File;
  const solutionPdfFile = formData.get("solutionPdfFile") as File | null;
  
  if (!pdfFile || pdfFile.size === 0) {
    throw new Error("Sınav PDF'i zorunludur.");
  }

  // Sınav PDF'ini Kaydet
  const pdfBytes = await pdfFile.arrayBuffer();
  const safeName = pdfFile.name.replace(/[^a-zA-Z0-9.\-_]/g, '-');
  const pdfName = `${Date.now()}-sinav-${safeName}`;
  await saveUploadedFile(pdfName, Buffer.from(pdfBytes));
  const pdfUrl = `/uploads/${pdfName}`;

  // Varsa Çözüm Kitapçığını Kaydet
  let solutionPdfUrl = null;
  if (solutionPdfFile && solutionPdfFile.size > 0) {
    const solBytes = await solutionPdfFile.arrayBuffer();
    const solName = `${Date.now()}-cozum-${solutionPdfFile.name.replace(/[^a-zA-Z0-9.\-_]/g, '-')}`;
    await saveUploadedFile(solName, Buffer.from(solBytes));
    solutionPdfUrl = `/uploads/${solName}`;
  }

  // Grupları (connect) objesine çevir
  let groupsConnect = [];
  if (selectedGroupsStr) {
    const groupIds = JSON.parse(selectedGroupsStr);
    groupsConnect = groupIds.map((id: string) => ({ id }));
  }

  const baseScoreRaw = formData.get("baseScore");
  const baseScore = (baseScoreRaw !== null && baseScoreRaw !== "") ? parseFloat(baseScoreRaw as string) : 100;
  
  const penaltyRatioRaw = formData.get("penaltyRatio");
  const penaltyRatio = (penaltyRatioRaw !== null && penaltyRatioRaw !== "") ? parseFloat(penaltyRatioRaw as string) : 0.25;

  const sessionType = formData.get("sessionType") as string || "STANDART";

  // Sınavı DB'ye yaz
  const exam = await prisma.exam.create({
    data: {
      title,
      description,
      questionCount,
      sections: sectionsData.length > 0 ? sectionsData : null,
      pdfUrl,
      solutionPdfUrl,
      baseScore,
      penaltyRatio,
      sessionType,
      institutionId: currentUser.institutionId,
      groups: { connect: groupsConnect }
    }
  });

  // Varsayılan Boş Cevap Anahtarlarını Oluştur (1'den questionCount'a kadar)
  const emptyKeys = Array.from({ length: questionCount }).map((_, i) => ({
    examId: exam.id,
    questionNumber: i + 1,
    correctOption: "A", // Default
  }));
  await prisma.questionKey.createMany({ data: emptyKeys });

  revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
  return exam;
}

// SINAV SİL
export async function deleteExam(id: string) {
  // İlişkili dosyaları public/uploads'dan silme kodu da eklenebilir. Şimdilik sadece DB silme.
  const exam = await prisma.exam.findUnique({ where: { id } });
  await prisma.exam.delete({ where: { id } });
  
  const user = await getCurrentUser();
  await logAction("EXAM_DELETE", user, `Sınav silindi: ${exam?.title || id}`, { examId: id });
  
  revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
}

// CEVAP ANAHTARI KAYDET/GÜNCELLE
export async function saveQuestionKeys(examId: string, keys: { questionNumber: number, correctOption: string, topic?: string, points?: number, videoUrl?: string }[]) {
  // Önce eskileri silip yenilerini yazmak en güvenli toplu işlem yöntemidir
  await prisma.questionKey.deleteMany({ where: { examId } });
  
  const insertData = keys.map(k => ({
    examId,
    questionNumber: k.questionNumber,
    correctOption: k.correctOption,
    topic: k.topic || null,
    points: k.points || 1,
    videoUrl: k.videoUrl || null
  }));

  await prisma.questionKey.createMany({ data: insertData });
  revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
  return true;
}

export async function updateExamDetails(id: string, data: any) {
  const parseLocalToUTC = (dateStr: string) => {
    if (!dateStr) return null;
    if (dateStr.includes("Z") || dateStr.includes("+")) return new Date(dateStr);
    if (dateStr.length === 16) return new Date(`${dateStr}:00+03:00`);
    if (dateStr.length === 19) return new Date(`${dateStr}+03:00`);
    return new Date(dateStr);
  };

  const startTime = parseLocalToUTC(data.startTime);
  const endTime = parseLocalToUTC(data.endTime);
  const showResultsTime = parseLocalToUTC(data.showResultsTime);
  const virtualTotalParticipants = data.virtualTotalParticipants ? parseInt(data.virtualTotalParticipants) : null;

  try {
    const baseScoreVal = data.baseScore !== "" && data.baseScore != null ? parseFloat(data.baseScore) : 100;
    const penaltyRatioVal = data.penaltyRatio !== "" && data.penaltyRatio != null ? parseFloat(data.penaltyRatio) : 0.25;
    const durationMinutes = data.durationMinutes ? parseInt(data.durationMinutes) : null;
    
    if (durationMinutes !== null && durationMinutes <= 0) {
      return { success: false, error: "Sınav süresi 0 veya negatif olamaz. Süresiz yapmak için alanı boş bırakın." };
    }

    await prisma.exam.update({
      where: { id },
      data: {
        title: data.title,
        description: data.description,
        startTime,
        endTime,
        showResultsTime,
        durationMinutes,
        virtualTotalParticipants,
        baseScore: baseScoreVal,
        penaltyRatio: penaltyRatioVal,
        examTemplate: data.examTemplate || "CUSTOM",
        isActive: data.isActive,
        groups: data.groups ? { set: data.groups.map((gId: string) => ({ id: gId })) } : undefined
      }
    });
    revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message || "Bilinmeyen veritabanı hatası" };
  }
}

export async function toggleExamResultsStatus(id: string, currentStatus: boolean) {
  await prisma.exam.update({
    where: { id },
    data: { isResultsPublished: !currentStatus }
  });
  revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
  return true;
}

export async function toggleExamActiveStatus(id: string, currentStatus: boolean) {
  await prisma.exam.update({
    where: { id },
    data: { isActive: !currentStatus }
  });
  revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
  return true;
}

// SINAV DÜZENLE (Dosya Yükleme Dahil, Tam Güncelleme)
export async function updateExamFull(id: string, formData: FormData) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  const title = formData.get("title") as string;
  const description = formData.get("description") as string;
  const sectionsStr = formData.get("sections") as string;
  
  let sectionsData = null;
  let newQuestionCount = 0;

  if (sectionsStr) {
    sectionsData = JSON.parse(sectionsStr);
    newQuestionCount = sectionsData.reduce((acc: number, s: any) => acc + (parseInt(s.count) || 0), 0);
  } else {
    newQuestionCount = parseInt(formData.get("questionCount") as string) || 0;
  }

  // PDF Dosyaları
  const pdfFile = formData.get("pdfFile") as File | null;
  const solutionPdfFile = formData.get("solutionPdfFile") as File | null;
  const existingPdfUrl = formData.get("existingPdfUrl") as string;
  const existingSolutionPdfUrl = formData.get("existingSolutionPdfUrl") as string;

  let finalPdfUrl = existingPdfUrl;
  let finalSolutionPdfUrl = existingSolutionPdfUrl || null;

  // Yeni PDF yüklendiyse
  if (pdfFile && pdfFile.size > 0) {
    const pdfBytes = await pdfFile.arrayBuffer();
    const safeName = pdfFile.name.replace(/[^a-zA-Z0-9.\-_]/g, '-');
    const pdfName = `${Date.now()}-sinav-${safeName}`;
    await saveUploadedFile(pdfName, Buffer.from(pdfBytes));
    finalPdfUrl = `/uploads/${pdfName}`;
  }

  // Yeni Çözüm PDF'i yüklendiyse
  if (solutionPdfFile && solutionPdfFile.size > 0) {
    const solBytes = await solutionPdfFile.arrayBuffer();
    const solName = `${Date.now()}-cozum-${solutionPdfFile.name.replace(/[^a-zA-Z0-9.\-_]/g, '-')}`;
    await saveUploadedFile(solName, Buffer.from(solBytes));
    finalSolutionPdfUrl = `/uploads/${solName}`;
  }

  const virtualTotalParticipants = formData.get("virtualTotalParticipants") ? parseInt(formData.get("virtualTotalParticipants") as string) : null;

  const parseLocalToUTC = (dateStr: string) => {
    if (!dateStr) return null;
    if (dateStr.includes("Z") || dateStr.includes("+")) return new Date(dateStr);
    if (dateStr.length === 16) return new Date(`${dateStr}:00+03:00`);
    if (dateStr.length === 19) return new Date(`${dateStr}+03:00`);
    return new Date(dateStr);
  };

  const startTime = parseLocalToUTC(formData.get("startTime") as string);
  const endTime = parseLocalToUTC(formData.get("endTime") as string);
  const showResultsTime = parseLocalToUTC(formData.get("showResultsTime") as string);
  
  const baseScoreVal = formData.get("baseScore") ? parseFloat(formData.get("baseScore") as string) : 100;
  const penaltyRatioVal = formData.get("penaltyRatio") ? parseFloat(formData.get("penaltyRatio") as string) : 0.25;
  const durationMinutes = formData.get("durationMinutes") ? parseInt(formData.get("durationMinutes") as string) : null;
  const examTemplate = formData.get("examTemplate") as string || "CUSTOM";
  const sessionType = formData.get("sessionType") as string || "STANDART";
  const isActive = formData.get("isActive") === "true" || formData.get("isActive") === "on";

  const selectedGroupsStr = formData.get("groups") as string;
  let groupsConnect: any = undefined;
  if (selectedGroupsStr) {
    const groupIds = JSON.parse(selectedGroupsStr);
    groupsConnect = { set: groupIds.map((id: string) => ({ id })) };
  }

  const dataToUpdate: any = {
    title,
    description,
    pdfUrl: finalPdfUrl,
    solutionPdfUrl: finalSolutionPdfUrl,
    virtualTotalParticipants,
    startTime,
    endTime,
    showResultsTime,
    durationMinutes,
    baseScore: baseScoreVal,
    penaltyRatio: penaltyRatioVal,
    examTemplate,
    sessionType,
    isActive,
    groups: groupsConnect
  };

  // Eğer bölümler değiştirilmişse questionCount'u da güncelle
  if (sectionsData !== null) {
    dataToUpdate.sections = sectionsData.length > 0 ? sectionsData : null;
    dataToUpdate.questionCount = newQuestionCount;
  }

  const updatedExam = await prisma.exam.update({
    where: { id },
    data: dataToUpdate
  });

  await logAction("EXAM_UPDATE", currentUser, `Sınav güncellendi: ${title}`, { examId: id });

  revalidatePath("/muro-admin/sinavlar");
  revalidateTag("exam-data", "default");
  return updatedExam;
}
