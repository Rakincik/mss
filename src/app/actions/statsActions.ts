"use server";

import { prisma } from "@/lib/prisma";
import { getCurrentUser } from "./authActions";

// Yardımcı: Yetki Kontrolü
async function getAuthorizedInstitutionId() {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error("Yetkisiz işlem");
  return currentUser.role === "SUPERADMIN" ? null : (currentUser.institutionId || null);
}

// 1. Tepe Metrikler (Hero Stats)
export async function getHeroStats() {
  const institutionId = await getAuthorizedInstitutionId();
  const whereInst = institutionId ? { institutionId } : {};

  const [totalStudents, totalExams, examResults] = await Promise.all([
    prisma.user.count({ where: { role: "STUDENT", ...whereInst } }),
    prisma.exam.count({ where: whereInst }),
    prisma.examResult.findMany({
      where: { exam: whereInst },
      select: { score: true, correctCount: true, wrongCount: true, emptyCount: true }
    })
  ]);

  const totalParticipation = examResults.length;
  const totalQuestionsSolved = examResults.reduce((acc, r) => acc + r.correctCount + r.wrongCount + r.emptyCount, 0);
  const averageScore = totalParticipation > 0 
    ? (examResults.reduce((acc, r) => acc + r.score, 0) / totalParticipation).toFixed(2)
    : 0;

  return {
    totalStudents,
    totalExams,
    totalParticipation,
    totalQuestionsSolved,
    averageScore: parseFloat(averageScore as string)
  };
}

// 2. Katılım Trendi (Son 6 Ay)
export async function getParticipationTrend() {
  const institutionId = await getAuthorizedInstitutionId();
  const whereInst = institutionId ? { institutionId } : {};

  // Son 6 ayın sonuçlarını çek
  const sixMonthsAgo = new Date();
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

  const results = await prisma.examResult.findMany({
    where: { 
      exam: whereInst,
      createdAt: { gte: sixMonthsAgo }
    },
    select: { createdAt: true }
  });

  const trendMap: Record<string, number> = {};
  results.forEach(r => {
    const month = r.createdAt.toLocaleString("tr-TR", { month: "short", year: "numeric" });
    trendMap[month] = (trendMap[month] || 0) + 1;
  });

  const trendData = Object.keys(trendMap).map(name => ({
    name,
    Katilim: trendMap[name]
  }));

  // Tarihe göre sıralamak için basit çözüm (Eğer veri varsa)
  return trendData.reverse(); 
}

// 3. Şube (Grup) Rekabeti
export async function getGroupRankings() {
  const institutionId = await getAuthorizedInstitutionId();
  const whereInst = institutionId ? { institutionId } : {};

  const groups = await prisma.group.findMany({
    where: whereInst,
    include: {
      users: {
        include: {
          results: { select: { score: true } }
        }
      }
    }
  });

  const rankings = groups.map(g => {
    let totalScore = 0;
    let resultCount = 0;

    g.users.forEach(u => {
      u.results.forEach(r => {
        totalScore += r.score;
        resultCount++;
      });
    });

    return {
      name: g.name,
      average: resultCount > 0 ? (totalScore / resultCount).toFixed(2) : "0.00",
      participants: resultCount
    };
  }).filter(g => g.participants > 0).sort((a, b) => parseFloat(b.average as string) - parseFloat(a.average as string));

  return rankings;
}

// 4. Onur Tablosu (Leaderboard)
export async function getLeaderboard() {
  const institutionId = await getAuthorizedInstitutionId();
  const whereInst = institutionId ? { institutionId } : {};

  const students = await prisma.user.findMany({
    where: { role: "STUDENT", ...whereInst },
    include: {
      results: { select: { score: true } }
    }
  });

  const leaderboard = students.map(s => {
    const totalScore = s.results.reduce((acc, r) => acc + r.score, 0);
    const avg = s.results.length > 0 ? (totalScore / s.results.length).toFixed(2) : 0;
    return {
      id: s.id,
      name: s.name || "İsimsiz",
      email: s.email,
      average: parseFloat(avg as string),
      examsTaken: s.results.length
    };
  }).filter(s => s.examsTaken > 0).sort((a, b) => b.average - a.average).slice(0, 10);

  return leaderboard;
}

// 5. Sınav Karşılaştırma Listesi
export async function getExamComparisons() {
  const institutionId = await getAuthorizedInstitutionId();
  const whereInst = institutionId ? { institutionId } : {};

  const exams = await prisma.exam.findMany({
    where: whereInst,
    orderBy: { createdAt: "desc" },
    include: {
      results: { select: { score: true } }
    }
  });

  return exams.map(e => {
    const totalScore = e.results.reduce((acc, r) => acc + r.score, 0);
    const avg = e.results.length > 0 ? (totalScore / e.results.length).toFixed(2) : 0;
    
    let difficulty = "Orta";
    if (parseFloat(avg as string) < 40) difficulty = "Zor";
    if (parseFloat(avg as string) > 75) difficulty = "Kolay";
    if (e.results.length === 0) difficulty = "-";

    return {
      id: e.id,
      title: e.title,
      date: e.createdAt,
      participants: e.results.length,
      average: parseFloat(avg as string),
      difficulty
    };
  });
}
