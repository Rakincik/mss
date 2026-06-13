"use server";

import { prisma } from "@/lib/prisma";
import { getCurrentUser } from "./authActions";
import { DocumentType } from "@prisma/client";
import { revalidatePath } from "next/cache";

export async function getDocuments(type?: DocumentType, query?: string, institutionIdFilter?: string) {
  const user = await getCurrentUser();
  if (!user || user.role === "STUDENT") {
    throw new Error("Yetkiniz yok.");
  }

  const whereClause: any = {};
  
  whereClause.institutionId = user.institutionId || null; // DATA ISOLATION FIX

  if (type) {
    whereClause.type = type;
  }
  
  if (query) {
    whereClause.OR = [
      { name: { contains: query, mode: "insensitive" } },
      { tags: { contains: query, mode: "insensitive" } }
    ];
  }

  const docs = await prisma.document.findMany({
    where: whereClause,
    orderBy: { createdAt: "desc" }
  });

  return docs;
}

export async function deleteDocument(id: string) {
  const user = await getCurrentUser();
  if (!user || !["ADMIN", "SUPERADMIN"].includes(user.role)) {
    throw new Error("Yetkiniz yok.");
  }

  const doc = await prisma.document.findUnique({ where: { id } });
  if (!doc) throw new Error("Doküman bulunamadı.");

  if (user.institutionId && doc.institutionId !== user.institutionId) {
    throw new Error("Bu dokümanı silme yetkiniz yok."); // ISOLATION FIX
  }

  // Fiziksel silme (isteğe bağlı, şimdilik sadece veritabanından siliyoruz, CDN/Sunucuda kalabilir veya fs.unlink eklenebilir)
  // Not: fs.unlink için server action içinde dosya yolu kurgusu yapılmalı.

  await prisma.document.delete({ where: { id } });

  revalidatePath("/muro-admin/dokumanlar");

  return { success: true };
}
