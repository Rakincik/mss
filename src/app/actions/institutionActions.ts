"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { getCurrentUser } from "./authActions";

export async function getInstitutions() {
  const currentUser = await getCurrentUser();
  if (currentUser?.role !== "SUPERADMIN") throw new Error("Yetkisiz işlem");

  return await prisma.institution.findMany({
    orderBy: { createdAt: "desc" },
    include: {
      _count: { select: { users: true, exams: true, groups: true } }
    }
  });
}

export async function createInstitution(data: { 
  name: string; 
  subdomain?: string;
  adminName: string;
  adminEmail: string;
  adminPassword?: string;
}) {
  const currentUser = await getCurrentUser();
  if (currentUser?.role !== "SUPERADMIN") throw new Error("Yetkisiz işlem");

  const password = data.adminPassword || "123456";

  // Aynı email adresiyle başka bir kullanıcı var mı kontrol et
  const existingUser = await prisma.user.findUnique({
    where: { email: data.adminEmail }
  });
  if (existingUser) throw new Error("Bu email adresi zaten kullanımda.");

  // Transaction kullanarak hem kurumu hem de adminini aynı anda oluşturuyoruz
  await prisma.$transaction(async (tx) => {
    const institution = await tx.institution.create({
      data: {
        name: data.name,
        subdomain: data.subdomain || null
      }
    });

    await tx.user.create({
      data: {
        name: data.adminName,
        email: data.adminEmail,
        password: password, // Gerçek sistemde bcrypt ile hashlenmeli
        role: "ADMIN",
        institutionId: institution.id,
      }
    });
  });

  revalidatePath("/muro-admin/kurumlar");
}

export async function toggleInstitutionStatus(id: string, isActive: boolean) {
  const currentUser = await getCurrentUser();
  if (currentUser?.role !== "SUPERADMIN") throw new Error("Yetkisiz işlem");

  await prisma.institution.update({
    where: { id },
    data: { isActive }
  });

  revalidatePath("/muro-admin/kurumlar");
}
