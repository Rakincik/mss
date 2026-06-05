import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { cookies } from "next/headers";
import { z } from "zod";

const batchAnswerSchema = z.array(z.object({
  resultId: z.string().min(1),
  questionNumber: z.number().int().min(1).max(999),
  selectedOption: z.string().max(10).optional().nullable(),
}));

export async function POST(req: NextRequest) {
  try {
    const cookieStore = await cookies();
    const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
    
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json();
    const parsed = batchAnswerSchema.safeParse(body.answers || body);

    if (!parsed.success) {
      return NextResponse.json({ error: "Geçersiz veri", details: parsed.error.flatten() }, { status: 400 });
    }

    if (parsed.data.length === 0) return NextResponse.json({ success: true });

    // Validate resultId belongs to user (assuming all batch answers belong to the same resultId for security check)
    const resultId = parsed.data[0].resultId;
    const result = await prisma.examResult.findUnique({ 
      where: { id: resultId }, 
      select: { userId: true, isFinished: true } 
    });
    
    if (!result || result.userId !== userId) {
      return NextResponse.json({ error: "Invalid result or unauthorized" }, { status: 403 });
    }
    if (result.isFinished) {
      return NextResponse.json({ error: "Exam is already finished" }, { status: 403 });
    }

    // Execute multiple upserts inside a single transaction for maximum performance
    const operations = parsed.data.map(ans => {
      let optionValue = ans.selectedOption === "BOŞ" ? null : ans.selectedOption;
      return prisma.studentAnswer.upsert({
        where: {
          resultId_questionNumber: {
            resultId,
            questionNumber: ans.questionNumber
          }
        },
        update: {
          selectedOption: optionValue
        },
        create: {
          resultId,
          questionNumber: ans.questionNumber,
          selectedOption: optionValue
        }
      });
    });

    await prisma.$transaction(operations);

    return NextResponse.json({ success: true, savedCount: parsed.data.length });
  } catch (err: any) {
    console.error("Batch answer error:", err);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}
