import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";
import { cookies } from "next/headers";
import { z } from "zod";

const telemetrySchema = z.object({
  examId: z.string().min(1, "examId boş olamaz"),
  actionType: z.string().min(1, "actionType boş olamaz").max(50),
  details: z.string().max(500).optional().nullable(),
});

export async function POST(req: NextRequest) {
  try {
    const cookieStore = await cookies();
    const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
    
    if (!userId) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json();
    const parsed = telemetrySchema.safeParse(body);

    if (!parsed.success) {
      return NextResponse.json({ error: "Geçersiz veri", details: parsed.error.flatten() }, { status: 400 });
    }

    const { examId, actionType, details } = parsed.data;

    await prisma.securityLog.create({
      data: {
        examId,
        userId,
        actionType,
        details: details || null
      }
    });

    return NextResponse.json({ success: true });
  } catch (err: any) {
    console.error("Telemetry error:", err);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}
