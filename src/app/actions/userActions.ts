"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import * as xlsx from "xlsx";
import { logTransaction, logBulkGroupTransactions } from "./accountingActions";
import { getCurrentUser } from "./authActions";

// GRUPLAR
export async function getGroups(filters?: { search?: string, status?: string, sortBy?: string }) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;
  
  if (filters?.status && filters.status !== "all") {
    whereClause.isActive = filters.status === "active";
  }

  if (filters?.search && filters.search.trim() !== "") {
    whereClause.OR = [
      { name: { contains: filters.search, mode: 'insensitive' } },
    ];
  }

  let orderBy: any = { createdAt: "desc" };
  
  if (filters?.sortBy) {
    switch (filters.sortBy) {
      case "oldest":
        orderBy = { createdAt: "asc" };
        break;
      case "az":
        orderBy = { name: "asc" };
        break;
      case "za":
        orderBy = { name: "desc" };
        break;
      case "newest":
      default:
        orderBy = { createdAt: "desc" };
        break;
    }
  }

  return await prisma.group.findMany({
    where: whereClause,
    orderBy: orderBy,
    include: { _count: { select: { users: true, exams: true, packages: true } } }
  });
}

export async function getGroupStats() {
  const currentUser = await getCurrentUser();
  if (!currentUser) return { total: 0, active: 0, passive: 0, totalStudentsInGroups: 0 };

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;

  const total = await prisma.group.count({ where: whereClause });
  const active = await prisma.group.count({ where: { ...whereClause, isActive: true } });
  const passive = total - active;
  
  // Gruplara atanmış toplam öğrenci sayısını hesapla
  const totalStudentsInGroups = await prisma.user.count({ 
    where: { ...whereClause, groups: { some: {} }, role: "STUDENT" } 
  });

  return { total, active, passive, totalStudentsInGroups };
}

export async function createGroup(data: { name: string; description?: string; price?: number; parentId?: string }) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  // Boş stringleri null'a çevir
  const safeDesc = data.description && data.description.trim() !== "" ? data.description.trim() : null;
  const parentId = data.parentId && data.parentId.trim() !== "" ? data.parentId : null;

  try {
    await prisma.group.create({
      data: {
        name: data.name,
        description: safeDesc,
        price: data.price || 0,
        parentId,
        institutionId: currentUser.institutionId
      }
    });
    revalidatePath("/muro-admin/gruplar");
    revalidatePath("/muro-admin/ogrenciler");
    return { success: true };
  } catch (err: any) {
    if (err.code === 'P2002') {
      throw new Error("Bu Grup Kodu (Benzersiz) başkası tarafından kullanılıyor!");
    }
    throw new Error("Grup oluşturulurken hata oluştu: " + err.message);
  }
}

export async function updateGroup(id: string, data: { name?: string; description?: string; price?: number; isActive?: boolean; expireAt?: Date | null }) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  const updateData: any = {};
  if (data.name !== undefined) updateData.name = data.name;
  if (data.description !== undefined) updateData.description = data.description && data.description.trim() !== "" ? data.description.trim() : null;
  if (data.price !== undefined) updateData.price = data.price;
  if (data.isActive !== undefined) updateData.isActive = data.isActive;
  if (data.expireAt !== undefined) updateData.expireAt = data.expireAt;

  await prisma.group.update({
    where: { id },
    data: updateData
  });
  
  revalidatePath(`/muro-admin/gruplar/${id}`);
  revalidatePath("/muro-admin/gruplar");
  return { success: true };
}

export async function deleteGroup(id: string) {
  await prisma.group.delete({ where: { id } });
  revalidatePath("/muro-admin/kullanicilar");
}

// KULLANICILAR (Yeni nesil gelişmiş listeleme - Server-Side Pagination)
export async function getUsers(filters?: { role?: string, status?: string, search?: string, groupId?: string, dateRange?: string, sortBy?: string, page?: number, pageSize?: number }) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;
  
  if (filters?.role && filters.role !== "all") {
    whereClause.role = filters.role;
  }
  
  if (filters?.status && filters.status !== "all") {
    whereClause.isActive = filters.status === "active";
  }
  
  if (filters?.groupId && filters.groupId !== "all") {
    whereClause.groups = { some: { id: filters.groupId } };
  }

  if (filters?.dateRange && filters.dateRange !== "all") {
    const now = new Date();
    if (filters.dateRange === 'today') {
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      whereClause.createdAt = { gte: today };
    } else if (filters.dateRange === 'week') {
      const lastWeek = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      whereClause.createdAt = { gte: lastWeek };
    } else if (filters.dateRange === 'month') {
      const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
      whereClause.createdAt = { gte: lastMonth };
    }
  }

  if (filters?.search && filters.search.trim() !== "") {
    whereClause.OR = [
      { name: { contains: filters.search, mode: 'insensitive' } },
      { email: { contains: filters.search, mode: 'insensitive' } },
      { phone: { contains: filters.search, mode: 'insensitive' } },
    ];
  }

  let orderBy: any = { createdAt: "desc" };
  
  if (filters?.sortBy) {
    switch (filters.sortBy) {
      case "oldest":
        orderBy = { createdAt: "asc" };
        break;
      case "az":
        orderBy = { name: "asc" };
        break;
      case "za":
        orderBy = { name: "desc" };
        break;
      case "newest":
      default:
        orderBy = { createdAt: "desc" };
        break;
    }
  }

  const page = filters?.page || 1;
  const pageSize = filters?.pageSize || 25;
  const skip = (page - 1) * pageSize;

  const [users, totalCount] = await Promise.all([
    prisma.user.findMany({
      where: whereClause,
      include: { groups: true },
      orderBy: orderBy,
      skip,
      take: pageSize,
    }),
    prisma.user.count({ where: whereClause })
  ]);

  return { users, totalCount, totalPages: Math.ceil(totalCount / pageSize) };
}

// KULLANICI İSTATİSTİKLERİ (KPI Dashboard için)
export async function getUserStats() {
  const currentUser = await getCurrentUser();
  if (!currentUser) return { total: 0, active: 0, passive: 0, students: 0, teachers: 0 };

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;

  const total = await prisma.user.count({ where: whereClause });
  const active = await prisma.user.count({ where: { ...whereClause, isActive: true } });
  const passive = total - active;
  const students = await prisma.user.count({ where: { ...whereClause, role: "STUDENT" } });
  const teachers = total - students; // Admin ve Editörleri "Eğitmen/Yetkili" sayıyoruz

  return { total, active, passive, students, teachers };
}

export async function createStudent(data: { name: string; email: string; password?: string; phone?: string; groupId?: string; role?: string }) {
  const currentUser = await getCurrentUser();
  // Şifre boş bırakılmışsa otomatik 123456 ata
  const password = data.password || "123456";
  
  if (data.role === "SUPERADMIN") {
    if (currentUser?.role !== "SUPERADMIN") {
      throw new Error("Süper Admin hesabı ekleme yetkiniz yok.");
    }
  }
  
  try {
    const user = await prisma.user.create({
      data: {
        name: data.name,
        email: data.email,
        phone: data.phone || null,
        password, // Gerçekte bcrypt ile hashlenmeli
        role: (data.role as any) || "STUDENT",
        institutionId: currentUser?.institutionId,
        groups: data.groupId ? { connect: { id: data.groupId } } : undefined
      }
    });
    
    // İşlem / Muhasebe Logu
    if (data.groupId) {
       const group = await prisma.group.findUnique({ where: { id: data.groupId }});
       if (group && group.price > 0) {
          await logTransaction({
            userId: user.id,
            amount: group.price,
            reason: "GROUP_JOIN",
            groupId: group.id
          });
       }
    }

    revalidatePath("/muro-admin/ogrenciler");
    return { success: true };
  } catch (err: any) {
    if (err.code === 'P2002') {
      throw new Error("Bu E-posta adresi sistemde zaten kayıtlı.");
    }
    throw new Error("Öğrenci eklenirken bir hata oluştu.");
  }
}

export async function updateStudent(id: string, data: { name: string; email: string; password?: string; phone?: string; groupId?: string; role?: string }) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  if (data.role === "SUPERADMIN" && currentUser.role !== "SUPERADMIN") {
    throw new Error("Süper Admin atama yetkiniz yok.");
  }

  const targetUser = await prisma.user.findUnique({ where: { id } });
  if (targetUser?.role === "SUPERADMIN" && currentUser.role !== "SUPERADMIN") {
    throw new Error("Süper Admin yetkilerini değiştiremezsiniz.");
  }

  try {
    const updateData: any = {
      name: data.name,
      email: data.email,
      phone: data.phone || null,
      role: (data.role as any) || "STUDENT",
    };

    if (data.password && data.password.trim() !== "") {
      updateData.password = data.password;
    }

    if (data.groupId) {
      updateData.groups = { set: [{ id: data.groupId }] };
    } else {
      updateData.groups = { set: [] };
    }

    await prisma.user.update({
      where: { id },
      data: updateData
    });

    revalidatePath("/muro-admin/ogrenciler");
    return { success: true };
  } catch (err: any) {
    if (err.code === 'P2002') {
      throw new Error("Bu E-posta adresi sistemde zaten kayıtlı.");
    }
    throw new Error("Öğrenci güncellenirken bir hata oluştu: " + err.message);
  }
}

export async function deleteStudent(id: string) {
  const currentUser = await getCurrentUser();
  const userToDelete = await prisma.user.findUnique({ where: { id } });

  if (userToDelete?.role === "SUPERADMIN" && currentUser?.role !== "SUPERADMIN") {
    throw new Error("Süper Admin hesabı silinemez. Bu işlem sadece başka bir Süper Admin tarafından yapılabilir.");
  }

  await prisma.user.delete({ where: { id } });
  revalidatePath("/muro-admin/ogrenciler");
}

// EXCEL TOPLU ÖĞRENCİ YÜKLEME
export async function importStudentsExcel(formData: FormData) {
  const file = formData.get("file") as File;
  if (!file) throw new Error("Dosya bulunamadı");
  
  const arrayBuffer = await file.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  const workbook = xlsx.read(buffer, { type: "buffer" });
  
  const sheetName = workbook.SheetNames[0];
  const sheet = workbook.Sheets[sheetName];
  
  // Excel'den parse et (Sütunlar: Ad Soyad, Email, Telefon, Şifre(Opsiyonel), Grup Adı)
  const rows: any[] = xlsx.utils.sheet_to_json(sheet);
  
  let addedCount = 0;
  
  for (const row of rows) {
    const name = row["Ad Soyad"] || row["İsim"] || row["Ad"] || null;
    const email = row["Email"] || row["E-posta"] || null;
    if (!name || !email) continue; // Boş veya hatalı satırı atla
    
    // Grubu isminden bul veya oluştur
    let groupId = null;
    const groupName = row["Grup"] || row["Sınıf"];
    if (groupName) {
      let group = await prisma.group.findFirst({ where: { name: groupName } });
      if (!group) {
        group = await prisma.group.create({ data: { name: groupName } });
      }
      groupId = group.id;
    }
    
    // Kullanıcı varsa es geç veya güncelle, biz şimdilik hata almamak için kontrol edelim
    const existing = await prisma.user.findUnique({ where: { email } });
    const currentUser = await getCurrentUser();
    if (!existing) {
      await prisma.user.create({
        data: {
          name,
          email,
          phone: row["Telefon"] ? String(row["Telefon"]) : null,
          password: row["Şifre"] ? String(row["Şifre"]) : "123456",
          role: "STUDENT",
          institutionId: currentUser?.institutionId,
          groups: groupId ? { connect: { id: groupId } } : undefined
        }
      });
      addedCount++;
    }
  }
  
  revalidatePath("/muro-admin/ogrenciler");
  return { success: true, count: addedCount };
}

export async function getGroupDetails(groupId: string) {
  return await prisma.group.findUnique({
    where: { id: groupId },
    include: {
      users: {
        orderBy: { name: 'asc' }
      },
      exams: {
        orderBy: { createdAt: 'desc' }
      },
      packages: {
        orderBy: { createdAt: 'desc' },
        include: { exams: true }
      }
    }
  });
}

export async function removeStudentFromGroup(studentId: string, groupId: string) {
  await prisma.user.update({
    where: { id: studentId },
    data: { groups: { disconnect: { id: groupId } } }
  });
  revalidatePath(`/muro-admin/gruplar/${groupId}`);
  revalidatePath("/muro-admin/ogrenciler");
  revalidatePath("/muro-admin/gruplar");
}

export async function removeExamFromGroup(examId: string, groupId: string) {
  await prisma.exam.update({
    where: { id: examId },
    data: {
      groups: {
        disconnect: { id: groupId }
      }
    }
  });
  revalidatePath(`/muro-admin/gruplar/${groupId}`);
  revalidatePath("/muro-admin/sinavlar");
  revalidatePath("/muro-admin/gruplar");
}

export async function assignExamToGroup(examId: string, groupId: string) {
  await prisma.exam.update({
    where: { id: examId },
    data: {
      groups: {
        connect: { id: groupId }
      }
    }
  });
  revalidatePath(`/muro-admin/gruplar/${groupId}`);
  revalidatePath("/muro-admin/sinavlar");
  revalidatePath("/muro-admin/gruplar");
}

// YENİ ÖZELLİKLER (Toplu Atama, Aktif/Pasif, Süre)

export async function toggleUserStatus(userId: string, isActive: boolean) {
  await prisma.user.update({
    where: { id: userId },
    data: { isActive }
  });
  revalidatePath("/muro-admin/ogrenciler");
}

export async function toggleGroupStatus(groupId: string, isActive: boolean) {
  await prisma.group.update({
    where: { id: groupId },
    data: { isActive }
  });
  revalidatePath("/muro-admin/gruplar");
  revalidatePath(`/muro-admin/gruplar/${groupId}`);
}

export async function updateGroupExpireDate(groupId: string, expireAt: Date | null) {
  await prisma.group.update({
    where: { id: groupId },
    data: { expireAt }
  });
  revalidatePath("/muro-admin/gruplar");
  revalidatePath(`/muro-admin/gruplar/${groupId}`);
}

export async function bulkAssignStudents(groupId: string, studentIds: string[]) {
  // Seçilen tüm öğrencilerin groupId'sini güncelle
  for (const id of studentIds) {
    await prisma.user.update({
      where: { id },
      data: { groups: { connect: { id: groupId } } }
    });
  }
  
  // Muhasebe logu yarat
  await logBulkGroupTransactions(studentIds, groupId);

  revalidatePath("/muro-admin/ogrenciler");
  revalidatePath("/muro-admin/gruplar");
  revalidatePath(`/muro-admin/gruplar/${groupId}`);
  return { success: true };
}

export async function bulkRemoveFromGroup(groupId: string, userIds: string[]) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  for (const userId of userIds) {
    await prisma.user.update({
      where: { id: userId },
      data: { groups: { disconnect: { id: groupId } } }
    });
  }

  revalidatePath(`/muro-admin/gruplar/${groupId}`);
  revalidatePath("/muro-admin/gruplar");
  return { success: true };
}

export async function bulkTransferToGroup(sourceGroupId: string, targetGroupId: string, userIds: string[]) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  for (const userId of userIds) {
    await prisma.user.update({
      where: { id: userId },
      data: { 
        groups: { 
          disconnect: { id: sourceGroupId },
          connect: { id: targetGroupId }
        } 
      }
    });
  }

  revalidatePath(`/muro-admin/gruplar/${sourceGroupId}`);
  revalidatePath(`/muro-admin/gruplar/${targetGroupId}`);
  revalidatePath("/muro-admin/gruplar");
  return { success: true };
}

// --- ÖĞRENCİ CRM (STUDENT 360) VE YÖNETİM ---

export async function bulkToggleUserStatus(userIds: string[], isActive: boolean) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");

  await prisma.user.updateMany({
    where: { id: { in: userIds } },
    data: { isActive }
  });

  revalidatePath("/muro-admin/ogrenciler");
  return { success: true };
}

// --- ÖĞRENCİ CRM (STUDENT 360) VE YÖNETİM ---

export async function getStudentCRMProfile(id: string) {
  const profile = await prisma.user.findUnique({
    where: { id },
    include: {
      groups: true,
      directExams: {
        orderBy: { createdAt: "desc" }
      },
      results: {
        include: {
          exam: true
        },
        orderBy: { createdAt: "desc" }
      },
      transactions: {
        orderBy: { createdAt: "desc" }
      },
      logs: {
        orderBy: { createdAt: "desc" }
      }
    }
  });

  if (!profile) throw new Error("Öğrenci bulunamadı.");
  
  return profile;
}

export async function updateStudentStatus(id: string, isActive: boolean) {
  await prisma.user.update({
    where: { id },
    data: { isActive }
  });
  revalidatePath(`/muro-admin/ogrenciler/${id}`);
  revalidatePath("/muro-admin/ogrenciler");
  return { success: true };
}

export async function updateStudentPasswordByAdmin(id: string, newPassword: string) {
  if (newPassword.length < 5) throw new Error("Şifre en az 5 karakter olmalıdır.");
  
  await prisma.user.update({
    where: { id },
    data: { password: newPassword }
  });
  return { success: true };
}

export async function updateUserRole(id: string, newRole: string) {
  const currentUser = await getCurrentUser();
  if (!currentUser || (currentUser.role !== "SUPERADMIN" && currentUser.role !== "ADMIN")) {
    throw new Error("Kullanıcı rolü değiştirme yetkiniz yok.");
  }

  // Sadece SUPERADMIN kendini veya başkasını SUPERADMIN yapabilir, 
  // ya da bir SUPERADMIN'i başka bir role çekebilir.
  if (newRole === "SUPERADMIN" && currentUser.role !== "SUPERADMIN") {
    throw new Error("Süper Admin atama yetkiniz yok.");
  }

  const targetUser = await prisma.user.findUnique({ where: { id } });
  if (targetUser?.role === "SUPERADMIN" && currentUser.role !== "SUPERADMIN") {
    throw new Error("Süper Admin'in rolünü değiştiremezsiniz.");
  }

  await prisma.user.update({
    where: { id },
    data: { role: newRole as any }
  });
  revalidatePath(`/muro-admin/ogrenciler/${id}`);
  revalidatePath("/muro-admin/ogrenciler");
  return { success: true };
}

export async function bulkDeleteStudents(userIds: string[]) {
  const currentUser = await getCurrentUser();
  if (!currentUser || (currentUser.role !== "ADMIN" && currentUser.role !== "SUPERADMIN")) {
    throw new Error("Kullanıcı silme yetkiniz yok.");
  }

  // Find users to be deleted to check roles
  const usersToDelete = await prisma.user.findMany({ 
    where: { id: { in: userIds } },
    select: { id: true, role: true }
  });

  if (currentUser.role !== "SUPERADMIN") {
    const hasSuperAdmin = usersToDelete.some(u => u.role === "SUPERADMIN");
    if (hasSuperAdmin) {
      throw new Error("Seçili kullanıcılar arasında Süper Admin bulunuyor. Silme işlemi iptal edildi.");
    }
  }

  await prisma.user.deleteMany({
    where: { id: { in: userIds } }
  });

  revalidatePath("/muro-admin/ogrenciler");
  return { success: true };
}
