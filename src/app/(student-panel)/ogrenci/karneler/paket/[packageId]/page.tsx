import { prisma } from "@/lib/prisma";
import { getCurrentUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import { Trophy, Layers, Calculator, ChevronRight, CheckCircle2, XCircle, MinusCircle } from "lucide-react";
import Link from "next/link";

export default async function PaketKarnesiPage({ params }: { params: Promise<{ packageId: string }> }) {
  const resolvedParams = await params;
  const packageId = resolvedParams.packageId;
  const student = await getCurrentUser();

  if (!student) redirect("/login");

  const packageResult = await prisma.packageResult.findUnique({
    where: {
      packageId_userId: { packageId, userId: student.id }
    },
    include: {
      package: {
        include: {
          exams: {
            include: {
              results: {
                where: { userId: student.id }
              }
            }
          }
        }
      }
    }
  });

  if (!packageResult) {
    return <div className="p-10 text-slate-800 text-center mt-20">Karne bulunamadı veya yetkiniz yok.</div>;
  }

  const scoresObj = (packageResult.scores as Record<string, number>) || {};
  
  // Sıralama Algoritması
  let primaryScoreKey = "total";
  let primaryScoreName = "Genel Toplam";
  if (scoresObj.KPSS_P121) { primaryScoreKey = "KPSS_P121"; primaryScoreName = "KPSS P121"; }
  else if (scoresObj.KPSS_P10) { primaryScoreKey = "KPSS_P10"; primaryScoreName = "KPSS P10"; }
  else if (scoresObj.KPSS_P3_P93) { primaryScoreKey = "KPSS_P3_P93"; primaryScoreName = "KPSS P3 / P93"; }
  else if (scoresObj.ALAN_PUANI) { primaryScoreKey = "ALAN_PUANI"; primaryScoreName = "Alan Sınavı"; }

  const allResults = await prisma.packageResult.findMany({
    where: { packageId, isComputed: true }
  });

  const scoredResults = allResults.map(r => {
     const s = (r.scores as Record<string, number>) || {};
     return { userId: r.userId, val: s[primaryScoreKey] || 0 };
  }).sort((a, b) => b.val - a.val);

  const realRank = scoredResults.findIndex(r => r.userId === student.id) + 1;
  const totalRealParticipants = scoredResults.length;

  return (
    <div className="font-sans text-slate-800 pb-20">
      <main className="max-w-5xl mx-auto space-y-8 mt-4 px-4">
        
        {/* Başlık Kartı */}
        <div className="bg-white border border-slate-200 rounded-3xl p-8 shadow-sm relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-slate-50 rounded-full blur-3xl -mr-20 -mt-20 pointer-events-none"></div>
          
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 relative z-10">
            <div>
              <span className="px-3 py-1 bg-indigo-50 text-indigo-600 border border-indigo-100 rounded-lg text-[10px] font-bold tracking-widest uppercase mb-4 inline-block">
                Birleşik Paket Karnesi
              </span>
              <h2 className="text-3xl font-black text-slate-900">{packageResult.package.title}</h2>
              <p className="text-slate-500 max-w-xl text-sm mt-3">{packageResult.package.description}</p>
            </div>
          </div>
        </div>

        {/* Ana Puanlar ve Sıralama */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="md:col-span-2 grid grid-cols-2 gap-4">
            {Object.entries(scoresObj).map(([key, value]) => {
              if (key === "total") return null;
              
              let label = key;
              if (key === "KPSS_P3_P93") label = "KPSS P3 / P93";
              if (key === "KPSS_P10") label = "KPSS P10";
              if (key === "KPSS_P121") label = "KPSS P121";
              if (key === "ALAN_PUANI") label = "Alan Puanı";

              return (
                <div key={key} className="bg-white border border-indigo-200 rounded-2xl p-6 relative overflow-hidden shadow-[0_0_20px_rgba(99,102,241,0.15)]">
                  <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-50/50 rounded-full -mr-16 -mt-16"></div>
                  <p className="text-indigo-600 text-[10px] font-bold uppercase tracking-wider mb-2 flex items-center gap-1.5">
                    <Calculator className="w-3 h-3" /> {label}
                  </p>
                  <div className="flex items-end gap-2 relative z-10">
                    <span className="text-4xl font-black text-slate-800">{value}</span>
                  </div>
                </div>
              );
            })}
          </div>

          <div className="bg-white border border-amber-200 rounded-2xl p-6 relative overflow-hidden shadow-[0_0_20px_rgba(245,158,11,0.15)] flex flex-col justify-center items-center text-center">
             <div className="absolute top-0 left-0 w-32 h-32 bg-amber-50/50 rounded-full -ml-16 -mt-16"></div>
             <Trophy className="w-12 h-12 text-amber-500 mb-3 relative z-10" />
             <p className="text-amber-600 text-[10px] font-bold uppercase tracking-wider mb-1 relative z-10">{primaryScoreName} Sıralamanız</p>
             <div className="flex items-end gap-2 relative z-10">
               <span className="text-4xl font-black text-slate-800">{realRank}</span>
               <span className="text-lg font-bold text-slate-400 mb-1">/ {totalRealParticipants}</span>
             </div>
          </div>
        </div>

        {/* Alt Oturumlar (Sınavlar) Özeti */}
        <div className="bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-sm">
          <div className="p-6 border-b border-slate-100 bg-slate-50 flex items-center justify-between">
            <h3 className="text-lg font-bold flex items-center gap-2 text-slate-800">
              <Layers className="w-5 h-5 text-indigo-600" /> Oturumlar (Alt Sınavlar)
            </h3>
          </div>
          <div className="p-6 divide-y divide-slate-100">
            {packageResult.package.exams.map(exam => {
              const res = exam.results[0];
              const isFinished = res?.isFinished;
              
              let sessionLabel = "Standart Sınav";
              if (exam.sessionType === "GY_GK") sessionLabel = "Genel Yetenek - Genel Kültür";
              if (exam.sessionType === "EB") sessionLabel = "Eğitim Bilimleri";
              if (exam.sessionType === "OABT") sessionLabel = "Öğretmenlik Alan (ÖABT)";
              if (exam.sessionType === "ALAN") sessionLabel = "Alan Sınavı";

              if (!isFinished) {
                return (
                  <div key={exam.id} className="py-4 flex items-center justify-between opacity-60">
                    <div>
                      <span className="text-[10px] uppercase font-bold text-slate-400 block mb-1">{sessionLabel}</span>
                      <h4 className="font-bold text-slate-700">{exam.title}</h4>
                    </div>
                    <span className="px-3 py-1 bg-slate-100 text-slate-500 text-xs font-bold rounded-lg">Katılmadınız</span>
                  </div>
                );
              }

              const netScore = res.correctCount - (res.wrongCount * (exam.penaltyRatio || 0));

              return (
                <div key={exam.id} className="py-5 flex flex-col md:flex-row md:items-center justify-between gap-4 group hover:bg-slate-50/50 transition-colors -mx-6 px-6">
                  <div className="flex-1">
                    <span className="text-[10px] uppercase font-bold text-indigo-500 block mb-1">{sessionLabel}</span>
                    <h4 className="font-bold text-slate-800 text-lg mb-2">{exam.title}</h4>
                    
                    <div className="flex items-center gap-6 text-sm font-medium">
                      <span className="flex items-center gap-1.5 text-emerald-600 bg-emerald-50 px-2 py-1 rounded-md"><CheckCircle2 className="w-4 h-4"/> {res.correctCount} Doğru</span>
                      <span className="flex items-center gap-1.5 text-red-500 bg-red-50 px-2 py-1 rounded-md"><XCircle className="w-4 h-4"/> {res.wrongCount} Yanlış</span>
                      <span className="flex items-center gap-1.5 text-slate-500 bg-slate-100 px-2 py-1 rounded-md"><MinusCircle className="w-4 h-4"/> {res.emptyCount} Boş</span>
                    </div>
                  </div>
                  
                  <div className="flex flex-row md:flex-col items-center md:items-end justify-between gap-4">
                    <div className="text-center md:text-right">
                       <span className="block text-[10px] uppercase tracking-wider font-bold text-slate-400 mb-0.5">Oturum Neti</span>
                       <span className="text-2xl font-black text-blue-600">{netScore.toFixed(2)}</span>
                    </div>
                    
                    <Link href={`/ogrenci/karne/${res.id}`} className="flex items-center gap-1 px-4 py-2 bg-white border border-slate-200 hover:border-indigo-300 hover:text-indigo-600 rounded-xl text-sm font-bold text-slate-600 transition-colors shadow-sm group-hover:shadow">
                      Detaylı Analizi Gör <ChevronRight className="w-4 h-4" />
                    </Link>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

      </main>
    </div>
  );
}
