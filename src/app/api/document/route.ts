import { NextRequest, NextResponse } from "next/server";
import { saveUploadedFile } from "@/lib/fileUpload";
import path from "path";
import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";

import { getCurrentUser } from "@/app/actions/authActions";

export async function POST(req: NextRequest) {
  try {
    const user = await getCurrentUser();
    if (!user || user.role === "STUDENT") {
      return NextResponse.json({ error: "Yetkisiz islem" }, { status: 401 });
    }

    const formData = await req.formData();
    const file = formData.get("file") as File;
    const name = formData.get("name") as string;
    const type = formData.get("type") as "EXAM_PDF" | "SOLUTION_PDF" | "OTHER";
    const tags = formData.get("tags") as string;
    const title = formData.get("title") as string;
    const category = formData.get("category") as string;
    const academicYear = formData.get("academicYear") as string;
    const description = formData.get("description") as string;

    if (!file || file.size === 0) {
      return NextResponse.json({ error: "Dosya bulunamadı." }, { status: 400 });
    }

    if (file.size > 50 * 1024 * 1024) {
      return NextResponse.json({ error: "Dosya boyutu 50MB sınırını aşamaz." }, { status: 400 });
    }

    const bytes = await file.arrayBuffer();
    const safeName = file.name.replace(/[^a-zA-Z0-9.\-_]/g, '-');
    const fileName = `${Date.now()}-arsiv-${safeName}`;
    await saveUploadedFile(fileName, Buffer.from(bytes));
    
    const url = `/uploads/${fileName}`;

    const document = await prisma.document.create({
      data: {
        name: name || file.name,
        url,
        type: type || "EXAM_PDF",
        tags,
        title: title || null,
        category: category || null,
        academicYear: academicYear || null,
        description: description || null,
        sizeBytes: file.size,
        institutionId: user.role !== "SUPERADMIN" ? user.institutionId : undefined,
      }
    });

    revalidatePath("/muro-admin/dokumanlar");

    return NextResponse.json({ success: true, document });
  } catch (err: any) {
    console.error("API Document Upload Error:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
