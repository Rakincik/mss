"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { getCurrentUser } from "./authActions";

export async function getSecurityLogs(page: number = 1, pageSize: number = 25) {
  const currentUser = await getCurrentUser();
  if (!currentUser) return { logs: [], totalCount: 0, totalPages: 0 };

  const whereClause: any = {};
  if (currentUser.role !== "SUPERADMIN") {
    whereClause.exam = { institutionId: currentUser.institutionId || null };
  }

  const skip = (page - 1) * pageSize;
  
  const [logs, totalCount] = await Promise.all([
    prisma.securityLog.findMany({
      where: whereClause,
      orderBy: { createdAt: "desc" },
      include: {
        user: { select: { name: true, email: true } },
        exam: { select: { title: true } }
      },
      skip,
      take: pageSize
    }),
    prisma.securityLog.count({ where: whereClause })
  ]);

  return { logs, totalCount, totalPages: Math.ceil(totalCount / pageSize) };
}

export async function deleteLog(id: string) {
  const currentUser = await getCurrentUser();
  const whereClause: any = { id };
  if (currentUser?.role !== "SUPERADMIN") {
    whereClause.exam = { institutionId: currentUser?.institutionId || null };
  }
  
  const log = await prisma.securityLog.findFirst({
    where: whereClause
  });
  if (!log) throw new Error("Bu logu silme yetkiniz yok.");

  await prisma.securityLog.delete({ where: { id } });
  revalidatePath("/muro-admin/guvenlik");
}

export async function clearAllLogs() {
  const currentUser = await getCurrentUser();
  if (currentUser?.role !== "SUPERADMIN") throw new Error("Bu işlemi sadece sistem yöneticisi yapabilir.");
  
  await prisma.securityLog.deleteMany({});
  revalidatePath("/muro-admin/guvenlik");
}

/**
 * Eski logları arşivle/temizle
 * @param olderThanDays - Kaç günden eski loglar silinsin (varsayılan: 90 gün)
 * @returns Silinen log sayısı
 */
export async function archiveOldLogs(olderThanDays: number = 90) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

  const result = await prisma.securityLog.deleteMany({
    where: {
      createdAt: { lt: cutoffDate }
    }
  });

  revalidatePath("/muro-admin/guvenlik");
  return { deletedCount: result.count, cutoffDate: cutoffDate.toISOString() };
}

/**
 * Log istatistikleri — DB boyutunu izlemek için
 */
export async function getLogStats() {
  const currentUser = await getCurrentUser();
  const whereClause: any = {};
  if (currentUser?.role !== "SUPERADMIN") {
    whereClause.exam = { institutionId: currentUser?.institutionId || null };
  }

  const [totalLogs, oldestLog, newestLog] = await Promise.all([
    prisma.securityLog.count({ where: whereClause }),
    prisma.securityLog.findFirst({ where: whereClause, orderBy: { createdAt: "asc" }, select: { createdAt: true } }),
    prisma.securityLog.findFirst({ where: whereClause, orderBy: { createdAt: "desc" }, select: { createdAt: true } }),
  ]);

  return {
    totalLogs,
    oldestLogDate: oldestLog?.createdAt?.toISOString() || null,
    newestLogDate: newestLog?.createdAt?.toISOString() || null,
  };
}
