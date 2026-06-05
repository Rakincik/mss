import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { cookies } from "next/headers";
import { z } from "zod";

const finishSchema = z.object({
  resultId: z.string().min(1, "resultId boş olamaz"),
});

export async function POST(req: NextRequest) {
  try {
    const cookieStore = await cookies();
    const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
    
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json();
    const parsed = finishSchema.safeParse(body);

    if (!parsed.success) {
      return NextResponse.json({ error: "Geçersiz veri", details: parsed.error.flatten() }, { status: 400 });
    }

    const { resultId } = parsed.data;

    const result = await prisma.examResult.findUnique({ 
      where: { id: resultId },
      include: { exam: { include: { keys: true } }, answers: true }
    });

    if (!result || result.userId !== userId) {
      return NextResponse.json({ error: "Invalid result or unauthorized" }, { status: 403 });
    }

    if (result.isFinished) {
      return NextResponse.json({ success: true, message: "Already finished" });
    }

    // Puanı hesapla
    let correctCount = 0;
    let wrongCount = 0;
    let emptyCount = 0;
    let totalPoints = 0;

    const answerMap = new Map();
    result.answers.forEach(a => {
      answerMap.set(a.questionNumber, a.selectedOption);
    });

    const tmpl = result.exam.examTemplate || "CUSTOM";
    const forcedPenalty = tmpl !== "CUSTOM" ? 0.25 : result.exam.penaltyRatio;
    
    result.exam.keys.forEach(k => {
      if (k.correctOption === "IPTAL") return;
      const stAnswer = answerMap.get(k.questionNumber);
      if (!stAnswer || stAnswer === "BOŞ") {
        emptyCount++;
      } else if (stAnswer === k.correctOption) {
        correctCount++;
        totalPoints += k.points;
      } else {
        wrongCount++;
        totalPoints -= (k.points * forcedPenalty);
      }
    });

    const totalNet = correctCount - (wrongCount * forcedPenalty);
    
    let score = 0;
    if (tmpl === "CUSTOM") {
      // CUSTOM Standard Logic
      score = result.exam.baseScore + totalPoints;
    } else {
      // ÖSYM Standart Puan (SP) Simülasyonu (KPSS, HMGS vb. tüm resmi şablonlar için)
      const totalQuestions = result.exam.keys.filter(k => k.correctOption !== "IPTAL").length;
      if (totalQuestions > 0) {
        const assumedMean = totalQuestions * 0.33; 
        const assumedStdDev = totalQuestions * 0.125; 
        
        let sp = ((totalNet - assumedMean) / assumedStdDev) * 10 + 50;
        if (sp > 100) sp = 100;
        score = Math.round(sp * 1000) / 1000;
      }
    }
    
    // Güvenlik amaçlı minimum puan 0
    score = Math.max(0, score);

    // ATOMİK UPDATE: Sadece henüz bitirilmemiş sonuçları güncelle (race condition koruması)
    const updated = await prisma.examResult.updateMany({
      where: { id: resultId, userId, isFinished: false },
      data: {
        isFinished: true,
        correctCount,
        wrongCount,
        emptyCount,
        score
      }
    });

    // Eğer hiçbir satır güncellenmemişse, zaten bitirilmiş demektir (çift tıklama)
    if (updated.count === 0) {
      return NextResponse.json({ success: true, message: "Already finished (concurrent request)" });
    }

    return NextResponse.json({ success: true });
  } catch (err: any) {
    console.error("Finish exam error:", err);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}

