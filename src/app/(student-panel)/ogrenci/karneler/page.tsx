import { getCurrentUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { FileText, Target, CalendarDays, CheckCircle2, Clock, Lock } from "lucide-react";
import Link from "next/link";
import dayjs from "dayjs";
import 'dayjs/locale/tr';
dayjs.locale('tr');

export const dynamic = "force-dynamic";

export default async function StudentKarnelerPage() {
  const student = await getCurrentUser();
  if (!student) {
    redirect("/login");
  }

  // Sadece bitirilen sınavların sonuçlarını al
  const results = await prisma.examResult.findMany({
    where: {
      userId: student.id,
      isFinished: true
    },
    include: {
      exam: true
    },
    orderBy: { updatedAt: "desc" }
  });

  // Hesaplanmış paket karnelerini al
  const packageResults = await prisma.packageResult.findMany({
    where: {
      userId: student.id,
      isComputed: true
    },
    include: {
      package: true
    },
    orderBy: { updatedAt: "desc" }
  });

  return (
    <div className="font-sans text-slate-800 flex flex-col">
      <main className="flex-1 w-full max-w-6xl mx-auto space-y-8">
        <div>
          <h2 className="text-2xl font-bold flex items-center gap-2 text-slate-800">
            <FileText className="w-6 h-6 text-blue-600" /> Geçmiş Karnelerim
          </h2>
          <p className="text-slate-500 mt-1 text-sm">Daha önce tamamladığınız sınavların sonuç raporlarına buradan ulaşabilirsiniz.</p>
        </div>

        {/* PAKET KARNELERİ BÖLÜMÜ */}
        {packageResults.length > 0 && (
          <div className="space-y-4">
            <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
              <span className="w-8 h-8 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center">
                <Target className="w-4 h-4" />
              </span>
              Birleşik Paket Karneleri (P3, P93, P48 vb.)
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {packageResults.map(pkgRes => {
                const scoresObj = (pkgRes.scores as Record<string, number>) || {};
                
                // En yüksek veya en anlamlı puanı bul
                let displayScoreName = "Genel Toplam";
                let displayScoreVal = scoresObj.total || 0;
                
                if (scoresObj.KPSS_P121) { displayScoreName = "KPSS P121"; displayScoreVal = scoresObj.KPSS_P121; }
                else if (scoresObj.KPSS_P10) { displayScoreName = "KPSS P10"; displayScoreVal = scoresObj.KPSS_P10; }
                else if (scoresObj.KPSS_P3) { displayScoreName = "KPSS P3"; displayScoreVal = scoresObj.KPSS_P3; }
                else if (scoresObj.KPSS_P93) { displayScoreName = "KPSS P93"; displayScoreVal = scoresObj.KPSS_P93; }
                else if (scoresObj.KPSS_P48) { displayScoreName = "KPSS P48"; displayScoreVal = scoresObj.KPSS_P48; }

                return (
                  <div key={pkgRes.id} className="bg-gradient-to-br from-indigo-500 to-blue-600 border border-indigo-400 rounded-2xl overflow-hidden shadow-md hover:shadow-lg transition-all flex flex-col relative group text-white">
                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full blur-2xl -mr-10 -mt-10 transition-colors"></div>
                    
                    <div className="p-5 flex-1 relative z-10">
                      <div className="flex justify-between items-start mb-4">
                        <div className="p-3 rounded-2xl bg-white/20 border border-white/20">
                          <CheckCircle2 className="w-5 h-5 text-white" />
                        </div>
                        <span className="px-3 py-1 bg-black/20 rounded-lg text-[10px] font-bold text-white flex items-center gap-1.5 uppercase tracking-wider">
                          <CalendarDays className="w-3 h-3" /> {dayjs(pkgRes.updatedAt).locale('tr').format('DD MMM YYYY')}
                        </span>
                      </div>
                      
                      <h3 className="text-base font-bold mb-1 line-clamp-2 min-h-[48px]">{pkgRes.package.title}</h3>
                      
                      <div className="flex items-center gap-4 mt-6">
                        <div className="flex-1 px-4 py-2 bg-white/10 rounded-lg border border-white/10 flex justify-between items-center transition-colors">
                          <span className="text-indigo-100 text-[10px] font-bold uppercase tracking-wider">{displayScoreName}</span>
                          <div className="flex items-center gap-1.5">
                              <Target className="w-4 h-4 text-indigo-200" />
                              <span className="text-lg font-black">{displayScoreVal}</span>
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    <div className="p-3 border-t border-white/10 bg-black/10 relative z-10 flex">
                      <Link 
                        href={`/ogrenci/karneler/paket/${pkgRes.packageId}`}
                        className="w-full py-2 rounded-lg text-center text-xs font-bold transition-all bg-white text-indigo-600 shadow-sm hover:bg-indigo-50"
                      >
                        Birleşik Karnemi İncele
                      </Link>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* TEKLİ OTURUM KARNELERİ BÖLÜMÜ */}
        {results.length > 0 && (
          <div className="space-y-4">
            <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2 mt-6">
              <span className="w-8 h-8 rounded-full bg-slate-100 text-slate-500 flex items-center justify-center">
                <FileText className="w-4 h-4" />
              </span>
              Tekli Oturum / Branş Karneleri
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {results.map(result => {
              const netScore = result.correctCount - (result.wrongCount * result.exam.penaltyRatio);
              const formattedNet = netScore > 0 ? parseFloat(netScore.toFixed(2)) : 0;
              
              // Sonuç Gösterim Zamanı Kontrolü
              const isTimePublished = result.exam.showResultsTime && new Date() >= new Date(result.exam.showResultsTime);
              const isReallyPublished = result.exam.isResultsPublished || isTimePublished;
              const isLocked = !isReallyPublished;
              
              const isFuturePublish = !isReallyPublished && result.exam.showResultsTime && new Date() < new Date(result.exam.showResultsTime);

              return (
                <div key={result.id} className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all flex flex-col relative group">
                  <div className="absolute top-0 right-0 w-32 h-32 bg-blue-50/50 rounded-full blur-2xl -mr-10 -mt-10 transition-colors"></div>
                  
                  <div className="p-5 flex-1 relative z-10">
                    <div className="flex justify-between items-start mb-4">
                      <div className={`p-3 rounded-2xl ${isLocked ? 'bg-slate-100 text-slate-400' : 'bg-blue-50 text-blue-600'} border`}>
                        <CheckCircle2 className="w-5 h-5" />
                      </div>
                      <span className="px-3 py-1 bg-slate-50 border border-slate-200 rounded-lg text-[10px] font-bold text-slate-500 flex items-center gap-1.5 uppercase tracking-wider">
                        <CalendarDays className="w-3 h-3" /> {dayjs(result.updatedAt).locale('tr').format('DD MMM YYYY')}
                      </span>
                    </div>
                    
                    <h3 className="text-base font-bold mb-1 line-clamp-2 min-h-[48px] text-slate-800">{result.exam.title}</h3>
                    
                    {!isLocked ? (
                      <div className="flex items-center gap-4 mt-6">
                        <div className="flex-1 px-4 py-2 bg-slate-50 rounded-lg border border-slate-100 flex justify-between items-center transition-colors shadow-[inset_0_1px_2px_rgba(0,0,0,0.02)]">
                          <span className="text-slate-500 text-[10px] font-bold uppercase tracking-wider">Net</span>
                          <div className="flex items-center gap-1.5">
                             <Target className="w-4 h-4 text-cyan-500" />
                             <span className="text-lg font-black text-slate-800">{formattedNet}</span>
                          </div>
                        </div>
                      </div>
                    ) : (
                      <div className="mt-6 px-4 py-2 bg-amber-50/50 border border-amber-100 rounded-lg flex items-center justify-center">
                        <span className="text-amber-600 text-[10px] font-bold uppercase tracking-wider text-center flex items-center gap-2">
                           <Lock className="w-3 h-3" /> {isFuturePublish ? `Açılış: ${new Date(result.exam.showResultsTime!).toLocaleDateString('tr-TR')}` : "Değerlendirme Aşamasında"}
                        </span>
                      </div>
                    )}
                  </div>
                  
                  <div className="p-3 border-t border-slate-100 bg-slate-50/50 relative z-10 flex">
                    <Link 
                      href={`/ogrenci/karne/${result.id}`}
                      className={`w-full py-2 rounded-lg text-center text-xs font-bold transition-all ${
                        isLocked 
                        ? 'bg-white border border-slate-200 text-slate-500 hover:bg-slate-50' 
                        : 'bg-white border text-blue-600 border-blue-200 shadow-sm hover:bg-blue-50'
                      }`}
                    >
                      {isLocked ? "Detayları Gör" : "Karnemi İncele"}
                    </Link>
                  </div>
                </div>
              );
            })}
          </div>
          </div>
        )}
        
        {results.length === 0 && packageResults.length === 0 && (
          <div className="py-20 text-center border-2 border-dashed border-slate-200 rounded-3xl bg-white shadow-sm mt-8">
            <FileText className="w-12 h-12 text-slate-300 mx-auto mb-4" />
            <h3 className="text-xl font-bold text-slate-700">Henüz karne bulunmuyor</h3>
            <p className="text-slate-500 mt-2 max-w-md mx-auto text-sm">Tamamladığınız herhangi bir sınav veya hesaplanmış paket bulunamadı.</p>
          </div>
        )}
      </main>
    </div>
  );
}
