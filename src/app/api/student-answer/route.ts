import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { cookies } from "next/headers";
import { z } from "zod";

const answerSchema = z.object({
  resultId: z.string().min(1, "resultId boş olamaz"),
  questionNumber: z.number().int().min(1).max(999),
  selectedOption: z.string().max(10).optional().nullable(),
});

export async function POST(req: NextRequest) {
  try {
    const cookieStore = await cookies();
    const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
    
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json();
    const parsed = answerSchema.safeParse(body);

    if (!parsed.success) {
      return NextResponse.json({ error: "Geçersiz veri", details: parsed.error.flatten() }, { status: 400 });
    }

    const { resultId, questionNumber, selectedOption } = parsed.data;

    // Doğrulama: Bu resultId gerçekten bu öğrenciye mi ait? Exam bitmiş mi?
    const result = await prisma.examResult.findUnique({ where: { id: resultId } });
    if (!result || result.userId !== userId) {
      return NextResponse.json({ error: "Invalid result or unauthorized" }, { status: 403 });
    }
    if (result.isFinished) {
      return NextResponse.json({ error: "Exam is already finished" }, { status: 403 });
    }

    // Upsert answer
    let optionValue = selectedOption;
    if (selectedOption === "BOŞ") optionValue = null;

    await prisma.studentAnswer.upsert({
      where: {
        resultId_questionNumber: {
          resultId,
          questionNumber
        }
      },
      update: {
        selectedOption: optionValue
      },
      create: {
        resultId,
        questionNumber,
        selectedOption: optionValue
      }
    });

    return NextResponse.json({ success: true });
  } catch (err: any) {
    console.error("Student answer error:", err);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}
