import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { cookies } from "next/headers";

const MAX_DRAWING_PAYLOAD_BYTES = 2_000_000; // 2MB

export async function POST(req: Request) {
  try {
    // 1. Auth kontrolü
    const cookieStore = await cookies();
    const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // 2. Payload boyut kontrolü — ham text olarak oku
    const bodyText = await req.text();
    if (bodyText.length > MAX_DRAWING_PAYLOAD_BYTES) {
      return NextResponse.json(
        { error: "DRAWING_LIMIT_EXCEEDED", message: "Çizim verisi çok büyük (max 500KB)" },
        { status: 413 }
      );
    }

    const { resultId, drawings } = JSON.parse(bodyText);

    if (!resultId) {
      return NextResponse.json({ error: "resultId gerekli" }, { status: 400 });
    }

    // 3. resultId'nin bu kullanıcıya ait olduğunu ve sınavın bitmediğini doğrula
    const result = await prisma.examResult.findUnique({
      where: { id: resultId },
      select: { userId: true, isFinished: true }
    });

    if (!result || result.userId !== userId) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }
    if (result.isFinished) {
      return NextResponse.json({ error: "Exam is already finished" }, { status: 403 });
    }

    // 4. Çizimi kaydet
    await prisma.examResult.update({
      where: { id: resultId },
      data: { drawings }
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error("Save Drawing Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
