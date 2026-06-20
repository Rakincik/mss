import { NextRequest, NextResponse } from "next/server";
import { saveUploadedFile } from "@/lib/fileUpload";
import path from "path";
import { prisma } from "@/lib/prisma";
import { logAction } from "@/lib/auditLogger";
import { getCurrentUser } from "@/app/actions/authActions";

export async function POST(req: NextRequest) {
  try {
    const formData = await req.formData();
    
    const title = formData.get("title") as string;
    const description = formData.get("description") as string;
    const examTemplate = (formData.get("examTemplate") as string) || "CUSTOM";
    const baseScoreRaw = formData.get("baseScore") as string;
    const baseScore = (baseScoreRaw !== null && baseScoreRaw !== "") ? parseFloat(baseScoreRaw) : 100;
    
    const penaltyRatioRaw = formData.get("penaltyRatio") as string;
    const penaltyRatio = (penaltyRatioRaw !== null && penaltyRatioRaw !== "") ? parseFloat(penaltyRatioRaw) : 0.25;
    
    const isActive = formData.get("isActive") === "on";
    
    const sectionsStr = formData.get("sections") as string;
    let sectionsData = [];
    let questionCount = 0;
    
    const keysDataStr = formData.get("keysData") as string;
    let customKeys: any[] = [];
    if (keysDataStr) {
      try { customKeys = JSON.parse(keysDataStr); } catch(e){}
    }
    
    if (sectionsStr) {
      sectionsData = JSON.parse(sectionsStr);
      questionCount = sectionsData.reduce((acc: number, s: any) => acc + (parseInt(s.count) || 0), 0);
    } else {
      questionCount = parseInt(formData.get("questionCount") as string) || 0;
    }
    const selectedGroupsStr = formData.get("groups") as string;
    
    const startTimeStr = formData.get("startTime") as string;
    const endTimeStr = formData.get("endTime") as string;
    const showResultsTimeStr = formData.get("showResultsTime") as string;
    const durationMinutesStr = formData.get("durationMinutes") as string;
    
    // Parse Dates safely
    const parseLocalToUTC = (dateStr: string) => {
      if (!dateStr) return null;
      if (dateStr.includes("Z") || dateStr.includes("+")) return new Date(dateStr);
      if (dateStr.length === 16) return new Date(`${dateStr}:00+03:00`); // YYYY-MM-DDTHH:mm
      if (dateStr.length === 19) return new Date(`${dateStr}+03:00`);    // YYYY-MM-DDTHH:mm:ss
      return new Date(dateStr);
    };
    
    const startTime = parseLocalToUTC(startTimeStr);
    const endTime = parseLocalToUTC(endTimeStr);
    const showResultsTime = parseLocalToUTC(showResultsTimeStr);
    const parsedDuration = parseInt(durationMinutesStr);
    const durationMinutes = !isNaN(parsedDuration) ? parsedDuration : null;
    
    if (durationMinutes !== null && durationMinutes <= 0) {
      return NextResponse.json({ error: "Sınav süresi 0 veya negatif olamaz. Süresiz yapmak için alanı boş bırakın." }, { status: 400 });
    }
    
    const pdfFile = formData.get("pdfFile") as File;
    const solutionPdfFile = formData.get("solutionPdfFile") as File | null;
    const existingPdfUrl = formData.get("existingPdfUrl") as string;
    const existingSolutionPdfUrl = formData.get("existingSolutionPdfUrl") as string;

    let pdfUrl = existingPdfUrl;
    if (!pdfUrl) {
      if (!pdfFile || pdfFile.size === 0) {
        return NextResponse.json({ error: "Sınav PDF'i zorunludur." }, { status: 400 });
      }
      if (pdfFile.size > 50 * 1024 * 1024) {
        return NextResponse.json({ error: "Sınav PDF dosya boyutu 50MB sınırını aşamaz." }, { status: 400 });
      }
      const pdfBytes = await pdfFile.arrayBuffer();
      const safeName = pdfFile.name.replace(/[^a-zA-Z0-9.\-_]/g, '-');
      const pdfName = `${Date.now()}-sinav-${safeName}`;
      await saveUploadedFile(pdfName, Buffer.from(pdfBytes));
      pdfUrl = `/uploads/${pdfName}`;
      
      // Arşive otomatik ekle
      await prisma.document.create({
        data: { name: pdfFile.name, url: pdfUrl, type: "EXAM_PDF", sizeBytes: pdfFile.size }
      });
    }

    let solutionPdfUrl = existingSolutionPdfUrl || null;
    if (!solutionPdfUrl && solutionPdfFile && solutionPdfFile.size > 0) {
      if (solutionPdfFile.size > 50 * 1024 * 1024) {
        return NextResponse.json({ error: "Çözüm PDF dosya boyutu 50MB sınırını aşamaz." }, { status: 400 });
      }
      const solBytes = await solutionPdfFile.arrayBuffer();
      const safeSolName = solutionPdfFile.name.replace(/[^a-zA-Z0-9.\-_]/g, '-');
      const solName = `${Date.now()}-cozum-${safeSolName}`;
      await saveUploadedFile(solName, Buffer.from(solBytes));
      solutionPdfUrl = `/uploads/${solName}`;
      
      // Arşive otomatik ekle
      await prisma.document.create({
        data: { name: solutionPdfFile.name, url: solutionPdfUrl, type: "SOLUTION_PDF", sizeBytes: solutionPdfFile.size }
      });
    }

    // Grupları Connect
    let groupsConnect = [];
    if (selectedGroupsStr) {
      const groupIds = JSON.parse(selectedGroupsStr);
      groupsConnect = groupIds.map((id: string) => ({ id }));
    }

    // Prisma Kayıt
    const exam = await prisma.exam.create({
      data: {
        title,
        description,
        questionCount,
        sections: sectionsData.length > 0 ? sectionsData : null,
        startTime,
        endTime,
        showResultsTime,
        durationMinutes,
        pdfUrl,
        solutionPdfUrl,
        examTemplate,
        baseScore,
        penaltyRatio,
        isActive,
        groups: { connect: groupsConnect }
      }
    });
    
    const user = await getCurrentUser();
    await logAction("EXAM_CREATE", user, `Yeni sınav oluşturuldu: ${title}`, { examId: exam.id, questionCount });

    // Anahtarları Oluştur
    if (customKeys && customKeys.length > 0) {
      const insertData = customKeys.map((k: any) => ({
        examId: exam.id,
        questionNumber: k.questionNumber,
        correctOption: k.correctOption,
        topic: k.topic || null,
        points: k.points || 1.0,
        videoUrl: k.videoUrl || null
      }));
      await prisma.questionKey.createMany({ data: insertData });
    } else {
      let emptyKeys = [];
      let currentQuestionNum = 1;
      
      if (sectionsData.length > 0) {
         for(const sec of sectionsData) {
            for(let i = 0; i < (parseInt(sec.count) || 0); i++) {
               emptyKeys.push({
                  examId: exam.id,
                  questionNumber: currentQuestionNum,
                  correctOption: "A",
                  topic: sec.title, // Default kazanım
                  points: sec.points !== undefined ? parseFloat(sec.points) : 1.0
               });
               currentQuestionNum++;
            }
         }
      } else {
         emptyKeys = Array.from({ length: questionCount }).map((_, i) => ({
           examId: exam.id,
           questionNumber: i + 1,
           correctOption: "A",
         }));
      }
      
      await prisma.questionKey.createMany({ data: emptyKeys });
    }

    return NextResponse.json({ success: true, exam });
  } catch (err: any) {
    console.error("API Upload Error:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
