"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function getPackages() {
  try {
    const packages = await prisma.examPackage.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        exams: true,
        results: true,
        groups: true
      }
    });
    return packages;
  } catch (error) {
    console.error("Error fetching packages:", error);
    return [];
  }
}

export async function createPackage(data: { title: string, description?: string, examIds: string[], groupIds: string[], isSequential?: boolean, showResultsTime?: string }) {
  try {
    const newPackage = await prisma.examPackage.create({
      data: {
        title: data.title,
        description: data.description,
        isSequential: data.isSequential || false,
        showResultsTime: data.showResultsTime ? new Date(data.showResultsTime) : null,
        exams: {
          connect: data.examIds.map(id => ({ id }))
        },
        groups: {
          connect: data.groupIds ? data.groupIds.map(id => ({ id })) : []
        }
      }
    });
    revalidatePath("/muro-admin/sinavlar");
    return { success: true, package: newPackage };
  } catch (error: any) {
    console.error("Error creating package:", error);
    return { success: false, error: error.message };
  }
}

export async function updatePackage(packageId: string, data: { title: string, description?: string, examIds: string[], groupIds: string[], isSequential?: boolean, showResultsTime?: string }) {
  try {
    const updatedPackage = await prisma.examPackage.update({
      where: { id: packageId },
      data: {
        title: data.title,
        description: data.description,
        isSequential: data.isSequential !== undefined ? data.isSequential : false,
        showResultsTime: data.showResultsTime ? new Date(data.showResultsTime) : null,
        exams: {
          set: data.examIds.map(id => ({ id }))
        },
        groups: {
          set: data.groupIds ? data.groupIds.map(id => ({ id })) : []
        }
      }
    });
    revalidatePath("/muro-admin/sinavlar");
    revalidatePath("/muro-admin/gruplar");
    return { success: true, package: updatedPackage };
  } catch (error: any) {
    console.error("Error updating package:", error);
    return { success: false, error: error.message };
  }
}

export async function deletePackage(packageId: string) {
  try {
    await prisma.examPackage.delete({
      where: { id: packageId }
    });
    revalidatePath("/muro-admin/sinavlar");
    return { success: true };
  } catch (error: any) {
    console.error("Error deleting package:", error);
    return { success: false, error: error.message };
  }
}

export async function calculatePackageScores(packageId: string) {
  // Puan hesaplama motoru eklenecek
  // Burada packageId'ye bağlı tüm exam'leri (oturumları) ve user'ların result'larını alıp
  // JSON formatında score'ları yazacağız.
  try {
    // 1. Fetch package and its exams
    const pkg = await prisma.examPackage.findUnique({
      where: { id: packageId },
      include: { exams: { include: { results: { where: { isFinished: true } } } } }
    });
    
    if (!pkg) throw new Error("Paket bulunamadı");
    
    // 2. Map all results by userId
    const userResultsMap = new Map<string, any[]>();
    for (const exam of pkg.exams) {
      for (const res of exam.results) {
        if (!userResultsMap.has(res.userId)) {
          userResultsMap.set(res.userId, []);
        }
        userResultsMap.get(res.userId)!.push({ ...res, exam });
      }
    }
    
    // 3. Hesaplama (ÖSYM Şablonlarına göre)
    for (const [userId, results] of userResultsMap.entries()) {
      let gy_gk_net = 0;
      let eb_net = 0;
      let oabt_net = 0;
      let alan_net = 0;
      let standart_net = 0;
      
      // Sınav (Oturum) türlerine göre netleri topla
      results.forEach(r => {
        const net = r.correctCount - (r.wrongCount * (r.exam.penaltyRatio || 0));
        
        if (r.exam.sessionType === 'GY_GK') gy_gk_net += net;
        else if (r.exam.sessionType === 'EB') eb_net += net;
        else if (r.exam.sessionType === 'OABT') oabt_net += net;
        else if (r.exam.sessionType === 'ALAN') alan_net += net;
        else standart_net += net;
      });
      
      // Standart Taban Puan
      const BASE_SCORE = 40; // ÖSYM'nin kullandığı yaklaşık taban puan
      
      // P3 / P93 / P94 Puanı: Sadece GY-GK varsa
      // Formül (Basitleştirilmiş ASP): Taban + (GY_GK_Net * 0.50)
      const KPSS_P3 = BASE_SCORE + (gy_gk_net * 0.50);
      
      // P10 Puanı: GY_GK + Eğitim Bilimleri
      // Formül: Taban + (GY_GK_Net * 0.60) + (EB_Net * 0.40) (Burada GY_GK'yi birleşik sayıyoruz)
      const KPSS_P10 = BASE_SCORE + (gy_gk_net * 0.60) + (eb_net * 0.40);
      
      // P121 Puanı: GY_GK + EB + ÖABT
      // Formül: Taban + (GY_GK_Net * 0.30) + (EB_Net * 0.20) + (OABT_Net * 0.50)
      const KPSS_P121 = BASE_SCORE + (gy_gk_net * 0.30) + (eb_net * 0.20) + (oabt_net * 0.50);
      
      // Kaymakamlık vb. Alan Sınavı
      // Formül: (GY_GK_Net * 0.34) + (Alan_Net * 0.66) // Burada 100 üzerinden taban puansız hesaplama
      let ALAN_PUANI = (gy_gk_net * 0.34) + (alan_net * 0.66);
      if (ALAN_PUANI > 100) ALAN_PUANI = 100;
      
      // Genel Toplam Puan (Eğer kategorisiz standart sınavlar eklendiyse)
      const totalScore = standart_net + gy_gk_net + eb_net + oabt_net + alan_net;

      // Hangi puanların anlamlı olduğunu belirle
      const finalScores: Record<string, number> = { total: totalScore };
      if (gy_gk_net > 0) {
        finalScores["KPSS_P3"] = Number(KPSS_P3.toFixed(3));
        finalScores["KPSS_P93"] = Number(KPSS_P3.toFixed(3));
        finalScores["KPSS_P94"] = Number(KPSS_P3.toFixed(3));
      }
      if (eb_net > 0) finalScores["KPSS_P10"] = Number(KPSS_P10.toFixed(3));
      if (oabt_net > 0) finalScores["KPSS_P121"] = Number(KPSS_P121.toFixed(3));
      if (alan_net > 0) finalScores["KPSS_P48"] = Number(ALAN_PUANI.toFixed(3));
      
      // Update or create PackageResult
      await prisma.packageResult.upsert({
        where: {
          packageId_userId: {
            packageId: pkg.id,
            userId: userId
          }
        },
        create: {
          packageId: pkg.id,
          userId: userId,
          scores: finalScores,
          isComputed: true
        },
        update: {
          scores: finalScores,
          isComputed: true
        }
      });
    }
    
    revalidatePath("/muro-admin/sinavlar");
    return { success: true };
  } catch (error: any) {
    console.error("Error computing package scores:", error);
    return { success: false, error: error.message };
  }
}
