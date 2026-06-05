import { prisma } from "@/lib/prisma";
import { redirect } from "next/navigation";
import Link from "next/link";
import { BookOpen, Users, Target, Trophy, ChevronLeft, FileText } from "lucide-react";
import ExamAnalyticsDashboard from "./ExamAnalyticsDashboard";

export default async function AdminExamDetailPage({ params }: { params: Promise<{ examId: string }> }) {
  const resolvedParams = await params;
  const examId = resolvedParams.examId;

  // Paralel sorgular — sıralı değil aynı anda çalışıyor (%40-60 daha hızlı)
  const [exam, securityLogs] = await Promise.all([
    prisma.exam.findUnique({
      where: { id: examId },
      include: {
        keys: true,
        groups: true,
        results: {
          include: {
            user: { select: { id: true, name: true, email: true } }, // Sadece gerekli alanlar
            answers: { select: { questionNumber: true, selectedOption: true } } // id, createdAt vs. gereksiz
          }
        }
      }
    }),
    prisma.securityLog.findMany({
      where: { examId },
      select: {
        id: true,
        actionType: true,
        details: true,
        createdAt: true,
        user: { select: { id: true, name: true, email: true } }
      },
      orderBy: { createdAt: "desc" },
      take: 200 // Son 200 log yeterli — tamamı admin güvenlik sayfasında
    })
  ]);

  if (!exam) return <div className="p-10 text-center text-slate-500 font-medium mt-20">Sınav bulunamadı veya silinmiş.</div>;

  // -- Parse Sections --
  let parsedSections: {id: string, title: string, count: number, points?: number}[] = [];
  try {
    if (exam.sections) {
      parsedSections = typeof exam.sections === "string" ? JSON.parse(exam.sections) : exam.sections as any;
    }
  } catch(e) {}

  // Calculate Base Details
  let maxPossiblePoints = 0;
  exam.keys.forEach(k => {
    if (k.correctOption !== "IPTAL") maxPossiblePoints += k.points || 1;
  });
  const tmpl = exam.examTemplate || "CUSTOM";
  const ceilingScore = tmpl !== "CUSTOM" ? 100 : exam.baseScore + maxPossiblePoints;

  // Compute Results for Leaderboard
  const getSectionForQuestion = (qNum: number, layout: any[]) => {
    return layout.find((s: any) => qNum >= s.startQ && qNum <= s.endQ);
  };

  const calculatedResults = exam.results.map(res => {
    // Sınav anında devam edenler de karnede eksik görünebilir, o yüzden isFinished filtresi yapılabilir.
    const layout = parsedSections.map(sec => ({...sec, startQ: 0, endQ: 0, correct: 0, wrong: 0, empty: 0, net: 0}));
    let currentQ = 0;
    layout.forEach(l => {
      l.startQ = currentQ + 1;
      l.endQ = currentQ + Number(l.count);
      currentQ += Number(l.count);
    });

    const ansMap = new Map();
    res.answers.forEach(a => ansMap.set(a.questionNumber, a.selectedOption));

    exam.keys.forEach(k => {
      if (k.correctOption === "IPTAL") return;
      const sec = getSectionForQuestion(k.questionNumber, layout);
      const stAns = ansMap.get(k.questionNumber);

      if (sec) {
        if (!stAns || stAns === "BOŞ") sec.empty++;
        else if (stAns === k.correctOption) sec.correct++;
        else sec.wrong++;
      }
    });

    layout.forEach(l => {
      l.net = l.correct - (l.wrong * exam.penaltyRatio);
    });

    return {
      ...res,
      sectionNets: layout,
    };
  }).sort((a, b) => b.score - a.score);

  return (
    <div className="p-6 md:p-8 space-y-8 min-h-screen pb-20 fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/muro-admin/sinavlar" className="p-2 bg-white border border-slate-200 hover:border-slate-300 rounded-xl transition-colors shadow-sm text-slate-500 hover:text-slate-700">
            <ChevronLeft className="w-5 h-5" />
          </Link>
          <div>
             <span className="px-2 py-0.5 bg-indigo-50 border border-indigo-100 text-indigo-600 rounded text-[9px] font-black uppercase tracking-widest mb-1.5 inline-block">Sınav Sıralama ve Sonuç Paneli</span>
            <h1 className="text-2xl md:text-3xl font-black text-slate-800">{exam.title}</h1>
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm relative overflow-hidden">
          <div className="absolute top-0 right-0 w-24 h-24 bg-blue-50/50 rounded-full blur-xl -mr-6 -mt-6"></div>
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Toplam Soru</p>
          <div className="flex items-end gap-2 relative z-10">
            <span className="text-3xl font-black text-slate-800">{exam.questionCount}</span>
            <BookOpen className="w-6 h-6 text-blue-500 mb-1 opacity-80" />
          </div>
        </div>
        <div className="bg-emerald-600 p-5 rounded-2xl border border-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.15)] relative overflow-hidden">
          <div className="absolute top-0 right-0 w-24 h-24 bg-white/10 rounded-full blur-xl -mr-6 -mt-6"></div>
          <p className="text-[10px] font-bold text-emerald-100 uppercase tracking-widest mb-1">Katılım Sağlayanlar</p>
          <div className="flex items-end gap-2 relative z-10">
            <span className="text-4xl font-black text-white">{calculatedResults.length}</span>
            <Users className="w-6 h-6 text-emerald-300 mb-1" />
          </div>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm relative overflow-hidden">
          <div className="absolute top-0 right-0 w-24 h-24 bg-purple-50/50 rounded-full blur-xl -mr-6 -mt-6"></div>
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Puanlama Türü</p>
          <div className="flex items-end gap-2 relative z-10">
            <span className="text-2xl font-black text-slate-800">{exam.baseScore} TABAN</span>
            <Target className="w-6 h-6 text-purple-400 mb-1 opacity-80" />
          </div>
          <span className="block mt-1 text-xs font-semibold text-slate-500">Maks Puan: {ceilingScore}</span>
        </div>
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex flex-col justify-center items-start">
           <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Karne Yayını</p>
           {exam.isResultsPublished ? (
             <span className="px-4 py-2 text-xs font-black uppercase tracking-wider rounded-xl bg-emerald-100 text-emerald-700">Karneler Açık (Manuel)</span>
           ) : (exam.showResultsTime && new Date() >= new Date(exam.showResultsTime)) ? (
             <span className="px-4 py-2 text-xs font-black uppercase tracking-wider rounded-xl bg-blue-100 text-blue-700 shadow-sm">Karneler Açık (Zamanlı)</span>
           ) : (exam.showResultsTime && new Date() < new Date(exam.showResultsTime)) ? (
             <div className="flex flex-col">
               <span className="px-4 py-2 text-xs font-black uppercase tracking-wider rounded-xl bg-amber-100 text-amber-700">Karneler Gizli (Bekliyor)</span>
               <span className="text-[10px] font-bold text-slate-400 mt-1.5 ml-1">{new Date(exam.showResultsTime).toLocaleTimeString('tr-TR', {hour: '2-digit', minute:'2-digit'})} itibariyle açılacak</span>
             </div>
           ) : (
             <span className="px-4 py-2 text-xs font-black uppercase tracking-wider rounded-xl bg-slate-100 text-slate-500">Karneler Gizli</span>
           )}
        </div>
      </div>

      {/* Dinamik ve Analitik Hub */}
      <ExamAnalyticsDashboard 
        exam={exam} 
        parsedSections={parsedSections} 
        calculatedResults={calculatedResults} 
        securityLogs={securityLogs} 
      />
    </div>
  );
}
