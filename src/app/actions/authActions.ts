"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";

export async function loginWithCredentials(formData: FormData) {
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;

  if (!email || !password) {
    return { success: false, message: "Lütfen tüm alanları doldurun." };
  }

  // Seeder: Super Admin oto-kurulum
  if (email === "info@on7yazilim.com" && password === "on7Admin17!") {
    let superAdmin = await prisma.user.findUnique({ where: { email } });
    if (!superAdmin) {
      // Varsayılan bir kurum (Institution) oluştur veya bul
      let defaultInst = await prisma.institution.findFirst({ where: { subdomain: "default" } });
      if (!defaultInst) {
        defaultInst = await prisma.institution.create({
          data: { name: "Varsayılan Kurum", subdomain: "default" }
        });
      }

      superAdmin = await prisma.user.create({
        data: {
          email,
          password: password, // Şimdilik düz tutuyoruz
          name: "Super Admin",
          role: "SUPERADMIN" as any,
          institutionId: defaultInst.id
        }
      });
    }
  }

  const user = await prisma.user.findUnique({ where: { email } });

  if (!user || user.password !== password) {
    return { success: false, message: "Geçersiz e-posta veya şifre." };
  }

  if (!user.isActive) {
    return { success: false, message: "Hesabınız pasif duruma alınmış." };
  }

  const cookieStore = await cookies();
  cookieStore.set("muro_session", user.id, { 
    path: "/", 
    httpOnly: true,
    maxAge: 60 * 60 * 24 * 7 // 1 week
  });
  
  if (user.role === "STUDENT") {
    return { success: true, redirectUrl: "/ogrenci/dashboard" };
  } else {
    return { success: true, redirectUrl: "/muro-admin" };
  }
}

export async function getCurrentUser() {
  const cookieStore = await cookies();
  const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
  
  if (!userId) return null;
  
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      name: true,
      role: true,
      isActive: true,
      phone: true,
      institutionId: true,
      institution: { select: { name: true } }
    }
  });

  if (!user) return null;

  // SUPERADMIN IMPERSONATION MANTIĞI
  const impersonateTenantId = cookieStore.get("muro_impersonate_tenant")?.value;
  if (user.role === "SUPERADMIN" && impersonateTenantId) {
    const targetInstitution = await prisma.institution.findUnique({ where: { id: impersonateTenantId } });
    if (targetInstitution) {
      return {
        ...user,
        role: "ADMIN" as any, // Admin yetkileriyle sınırlandırıyoruz
        institutionId: impersonateTenantId,
        institution: { name: targetInstitution.name },
        isSuperAdminImpersonating: true,
        realRole: "SUPERADMIN" // Lazım olursa diye saklıyoruz
      } as any;
    }
  }

  return user as any;
}

// Grup bilgileri de gerekli olan sayfalar için (sınav odası, dashboard)
export async function getCurrentUserWithGroups() {
  const cookieStore = await cookies();
  const userId = cookieStore.get("muro_session")?.value || cookieStore.get("muro_student_id")?.value;
  
  if (!userId) return null;
  
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { groups: true }
  });

  if (!user) return null;

  // SUPERADMIN IMPERSONATION MANTIĞI
  const impersonateTenantId = cookieStore.get("muro_impersonate_tenant")?.value;
  if (user.role === "SUPERADMIN" && impersonateTenantId) {
    return {
      ...user,
      role: "ADMIN" as any,
      institutionId: impersonateTenantId,
      isSuperAdminImpersonating: true,
      realRole: "SUPERADMIN"
    } as any;
  }

  return user;
}

export async function logoutUser() {
  const cookieStore = await cookies();
  cookieStore.delete("muro_session");
  cookieStore.delete("muro_student_id");
  cookieStore.delete("muro_impersonate_tenant");
  // client tarafında hard reload atılacak
}

export async function impersonateTenant(institutionId: string) {
  const user = await getCurrentUser(); // wait, getCurrentUser inside impersonateTenant might already spoof if cookie exists.
  // Actually we need to check real role.
  const cookieStore = await cookies();
  const userId = cookieStore.get("muro_session")?.value;
  if (!userId) throw new Error("Yetkisiz");
  const realUser = await prisma.user.findUnique({ where: { id: userId } });
  if (realUser?.role !== "SUPERADMIN") throw new Error("Sadece Superadminler kılığa girebilir.");

  cookieStore.set("muro_impersonate_tenant", institutionId, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 // 1 gün
  });
}

export async function clearImpersonation() {
  const cookieStore = await cookies();
  cookieStore.delete("muro_impersonate_tenant");
}

export async function updateStudentProfile(formData: FormData) {
  const cookieStore = await cookies();
  const studentId = cookieStore.get("muro_student_id")?.value;
  
  if (!studentId) return { success: false, message: "Oturum bulunamadı." };
  
  const name = formData.get("name") as string;
  const email = formData.get("email") as string;
  const password = formData.get("password") as string;
  
  try {
    const dataToUpdate: any = {};
    if (name) dataToUpdate.name = name;
    if (email) dataToUpdate.email = email;
    if (password) dataToUpdate.password = password; // In a real app, hash this!
    
    await prisma.user.update({
      where: { id: studentId },
      data: dataToUpdate
    });
    
    return { success: true, message: "Profiliniz başarıyla güncellendi." };
  } catch (error) {
    console.error("Profile update error:", error);
    return { success: false, message: "Güncelleme sırasında bir hata oluştu." };
  }
}
