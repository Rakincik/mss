"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import dayjs from "dayjs";
import { getCurrentUser } from "./authActions";

// --- GÜNLÜK MUHASEBE VE LOGLAMA ---

export async function logTransaction(data: { userId: string, amount: number, reason: string, groupId?: string, examId?: string }) {
  if (data.amount <= 0) return; // Belki ücretsizleri loglamamak daha iyi olabilir
  const currentUser = await getCurrentUser();
  
  await prisma.transaction.create({
    data: {
      userId: data.userId,
      amount: data.amount,
      reason: data.reason,
      groupId: data.groupId || null,
      examId: data.examId || null,
      institutionId: currentUser?.institutionId
    }
  });
}

// Toplu bir grubun ücretinin çekilip N kişiye uygulanması
export async function logBulkGroupTransactions(userIds: string[], groupId: string) {
  const group = await prisma.group.findUnique({ where: { id: groupId }});
  if (!group || group.price <= 0) return;

  const currentUser = await getCurrentUser();

  const txData = userIds.map(userId => ({
    userId,
    amount: group.price,
    reason: "GROUP_JOIN",
    groupId: group.id,
    institutionId: currentUser?.institutionId
  }));

  await prisma.transaction.createMany({ data: txData });
}

// Direkt bağımsız Sınav Satın Alımı tetiklemesi
export async function buyDirectExam(userId: string, examId: string) {
  const exam = await prisma.exam.findUnique({ where: { id: examId }});
  if (!exam) throw new Error("Sınav bulunamadı");

  // Öğrenciyi sınava direkt bağla
  await prisma.user.update({
    where: { id: userId },
    data: {
      directExams: {
        connect: { id: examId }
      }
    }
  });

  // Artık bağımsız sınav ücreti yok, sadece erişim açılıyor.

  revalidatePath("/ogrenci/dashboard");
  revalidatePath("/muro-admin/muhasebe");
  return { success: true };
}


// --- DASHBOARD GRAFİK VE İSTATİSTİKLERİ ---

export async function getAccountingStats(startDateStr?: string, endDateStr?: string) {
  const currentUser = await getCurrentUser();
  if (!currentUser) return null;

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;
  
  if (startDateStr && endDateStr) {
    whereClause.createdAt = {
      gte: new Date(startDateStr),
      lte: new Date(endDateStr)
    };
  }
  whereClause.institutionId = currentUser.institutionId || null;

  const now = new Date();
  const startOfThisMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0);

  // Bu işlem yoğun verilerde optimize edilmelidir, ancak sistem ölçeğinde yeterli performans verir
  const transactions = await prisma.transaction.findMany({
    where: whereClause,
    orderBy: { createdAt: "desc" }
  });
  
  // Grupları ve sınavları manuel olarak haritalıyoruz (Database constraint hatasını önlemek için)
  const allGroups = await prisma.group.findMany({ select: { id: true, name: true }});
  const allExams = await prisma.exam.findMany({ select: { id: true, title: true }});
  
  const groupMap = new Map(allGroups.map(g => [g.id, g.name]));
  const examMap = new Map(allExams.map(e => [e.id, e.title]));

  let totalRevenue = 0;
  let currentMonthRevenue = 0;
  let lastMonthRevenue = 0;
  
  // Sadece pozitif satışları sayalım, iadeleri değil
  let salesCount = transactions.filter(t => t.amount > 0).length;
  let currentMonthSales = 0;
  let lastMonthSales = 0;
  
  const productDistributionMap = new Map<string, number>();

  transactions.forEach(tx => {
    totalRevenue += tx.amount;
    const txDate = tx.createdAt;

    if (txDate >= startOfThisMonth) {
      currentMonthRevenue += tx.amount;
      if (tx.amount > 0) currentMonthSales++;
    } else if (txDate >= startOfLastMonth && txDate <= endOfLastMonth) {
      lastMonthRevenue += tx.amount;
      if (tx.amount > 0) lastMonthSales++;
    }
    
    // Ürün bazlı dağılım (iade işlemleri geliri düşürür)
    let label = tx.reason;
    if (tx.reason === "GROUP_JOIN" && tx.groupId) label = groupMap.get(tx.groupId) || "Bilinmeyen Grup";
    else if (tx.reason === "EXAM_PURCHASE" && tx.examId) label = examMap.get(tx.examId) || "Bilinmeyen Sınav";
    else if (tx.reason === "REFUND") label = "İade Edilenler";
    
    productDistributionMap.set(label, (productDistributionMap.get(label) || 0) + tx.amount);
  });

  let revenueGrowth = 0;
  if (lastMonthRevenue > 0) {
    revenueGrowth = ((currentMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100;
  } else if (currentMonthRevenue > 0) {
    revenueGrowth = 100; // Geçen ay 0 ise, bu ay pozitif ise %100 kabul et
  } else {
    revenueGrowth = 0; // İkisi de 0 ise büyüme %0
  }
  
  const productDistribution = Array.from(productDistributionMap.entries())
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value);
  
  // En son satılanlar (Son 10)
  const recentTransactionsRaw = await prisma.transaction.findMany({
    where: whereClause,
    take: 10,
    orderBy: { createdAt: 'desc' },
    include: {
      user: { select: { name: true, email: true } }
    }
  });

  const recentTransactions = recentTransactionsRaw.map((tx: any) => ({
    ...tx,
    group: tx.groupId ? { name: groupMap.get(tx.groupId) } : null,
    exam: tx.examId ? { title: examMap.get(tx.examId) } : null,
    createdAt: tx.createdAt.toISOString()
  }));

  return {
    totalRevenue,
    currentMonthRevenue,
    lastMonthRevenue,
    revenueGrowth,
    totalSales: salesCount,
    currentMonthSales,
    recentTransactions,
    productDistribution
  };
}

export async function refundTransaction(txId: string) {
  const currentUser = await getCurrentUser();
  if (!currentUser || (currentUser.role !== "SUPERADMIN" && currentUser.role !== "ADMIN")) {
    throw new Error("Yetkisiz işlem");
  }

  const tx = await prisma.transaction.findUnique({ where: { id: txId } });
  if (!tx || tx.amount <= 0) return { success: false, error: "İade edilecek işlem bulunamadı veya bu işlem zaten bir iade işlemi." };
  
  await prisma.transaction.create({
    data: {
      userId: tx.userId,
      amount: -tx.amount,
      reason: "REFUND",
      groupId: tx.groupId,
      examId: tx.examId,
      institutionId: tx.institutionId
    }
  });
  
  revalidatePath("/muro-admin/muhasebe");
  return { success: true };
}

export async function getRevenueChartData(period: "DAY" | "WEEK" | "MONTH" | "YEAR" = "MONTH", startDateStr?: string, endDateStr?: string) {
  const currentUser = await getCurrentUser();
  if (!currentUser) return [];

  const whereClause: any = {};
  whereClause.institutionId = currentUser.institutionId || null;
  
  if (startDateStr && endDateStr) {
    whereClause.createdAt = {
      gte: new Date(startDateStr),
      lte: new Date(endDateStr)
    };
  }

  // Örnek basit mock veya gerçek gruplayıcı. Pratikte Prisma "groupBy" datetime field ile düzgün çalışmaz, js tabanlı gruplamak en güvenlisidir.
  const transactions = await prisma.transaction.findMany({
    where: whereClause,
    orderBy: { createdAt: "asc" }
  });

  const chartData: any[] = [];
  const map = new Map<string, number>();

  transactions.forEach(tx => {
    let key = "";
    if (period === "MONTH") {
      key = dayjs(tx.createdAt).format("MMM YYYY"); // Örn: 'Oca 2026'
    } else if (period === "DAY") {
      key = dayjs(tx.createdAt).format("DD MMM");
    } else if (period === "YEAR") {
      key = dayjs(tx.createdAt).format("YYYY");
    }
    
    map.set(key, (map.get(key) || 0) + tx.amount);
  });

  map.forEach((total, dateLabel) => {
    chartData.push({
      date: dateLabel,
      gelir: total
    });
  });

  return chartData;
}
