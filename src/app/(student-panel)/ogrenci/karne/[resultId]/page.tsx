import { prisma } from "@/lib/prisma";
import { getCurrentUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import { CheckCircle2, XCircle, MinusCircle, FileText, Target, BookOpen, Clock, Activity, Home, Trophy, PlayCircle } from "lucide-react";
import Link from "next/link";
import PrintButton from "@/components/ui/PrintButton";

export default async function SınavKarnesiPage({ params }: { params: Promise<{ resultId: string }> }) {
  const resolvedParams = await params;
  const resultId = resolvedParams.resultId;
  const student = await getCurrentUser();

  if (!student) redirect("/login");

  const result = await prisma.examResult.findUnique({
    where: { id: resultId },
    include: {
      exam: { include: { keys: true } },
      answers: true
    }
  });

  if (!result || result.userId !== student.id) {
    return <div className="p-10 text-slate-800 text-center mt-20">Karne bulunamadı veya yetkiniz yok.</div>;
  }

  // Sonuç Gösterim Zamanı Kontrolü (Manuel veya Otomatik Tarih)
  const isTimePublished = result.exam.showResultsTime && new Date() >= new Date(result.exam.showResultsTime);
  const isReallyPublished = result.exam.isResultsPublished || isTimePublished;

  if (!isReallyPublished) {
    return (
      <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-6 text-center">
        <div className="bg-white border border-slate-200 rounded-3xl p-10 max-w-lg w-full shadow-sm">
          <Clock className="w-16 h-16 text-amber-500 mx-auto mb-6" />
          <h2 className="text-3xl font-bold text-slate-800 mb-4">Sonuçlar Değerlendirme Aşamasında</h2>
          <p className="text-slate-500 mb-8">
            Bu sınavın sonuçları yöneticiler tarafından henüz yayınlanmadı. İncelemeler bittiğinde karnenize erişebileceksiniz.
          </p>
          <Link href="/ogrenci/dashboard" className="px-6 py-3 bg-white border border-slate-200 hover:bg-slate-50 rounded-xl font-bold text-slate-700 transition-colors shadow-sm">
            Dashboard'a Dön
          </Link>
        </div>
      </div>
    );
  }

  let maxPossiblePoints = 0;
  result.exam.keys.forEach(k => {
    if (k.correctOption !== "IPTAL") maxPossiblePoints += k.points;
  });
  const tmpl = result.exam.examTemplate || "CUSTOM";
  const ceilingScore = tmpl !== "CUSTOM" ? 100 : result.exam.baseScore + maxPossiblePoints;
  const netScore = result.correctCount - (result.wrongCount * result.exam.penaltyRatio);

  // --- DERECE / RANK HESAPLAMASI (Sanal Çarpanlı) ---
  const allResults = await prisma.examResult.findMany({
    where: { examId: result.exam.id, isFinished: true }
  });

  const scoredResults = allResults.map(r => ({
    userId: r.userId,
    score: r.score
  })).sort((a, b) => b.score - a.score);

  const realRank = scoredResults.findIndex(r => r.userId === student.id) + 1;
  const totalRealParticipants = scoredResults.length;

  let displayRank = realRank;
  let displayTotal = totalRealParticipants;

  if (result.exam.virtualTotalParticipants && totalRealParticipants > 1) {
    const vTotal = result.exam.virtualTotalParticipants;
    displayRank = Math.round(((realRank - 1) / (totalRealParticipants - 1)) * (vTotal - 1)) + 1;
    displayTotal = vTotal;
  } else if (result.exam.virtualTotalParticipants && totalRealParticipants === 1) {
    displayRank = 1;
    displayTotal = result.exam.virtualTotalParticipants;
  }
  // --- DERECE SON ---

  
  // --- BÖLÜM BAZLI (TEST) ANALİZ ---
  let parsedSections: {id: string, title: string, count: number, points?: number}[] = [];
  try {
    if (result.exam.sections) {
      parsedSections = typeof result.exam.sections === "string" ? JSON.parse(result.exam.sections) : result.exam.sections as any;
    }
  } catch(e) {}

  const sectionAnalysis = parsedSections.map(sec => ({
    id: sec.id,
    title: sec.title,
    count: typeof sec.count === "string" ? parseInt(sec.count) : sec.count,
    correct: 0,
    wrong: 0,
    empty: 0,
    net: 0,
    startQ: 0,
    endQ: 0
  }));

  let currentQCount = 0;
  sectionAnalysis.forEach(sec => {
    sec.startQ = currentQCount + 1;
    sec.endQ = currentQCount + sec.count;
    currentQCount += sec.count;
  });

  const getSectionForQuestion = (qNum: number) => {
    return sectionAnalysis.find(s => qNum >= s.startQ && qNum <= s.endQ);
  };

  // Kazanım / Konu Bazlı Analiz
  const topicAnalysis: Record<string, { correct: number, wrong: number, empty: number }> = {};
  
  const answerMap = new Map();
  result.answers.forEach(a => answerMap.set(a.questionNumber, a.selectedOption));

  result.exam.keys.forEach(k => {
    if (k.correctOption === "IPTAL") return;
    
    // Kazanım veya Test başlığı yoksa Genel Kazanım kullan
    const sec = getSectionForQuestion(k.questionNumber);
    const topic = k.topic || sec?.title || "Genel Kapsam";
    
    if (!topicAnalysis[topic]) {
      topicAnalysis[topic] = { correct: 0, wrong: 0, empty: 0 };
    }
    
    const stAns = answerMap.get(k.questionNumber);
    let isCorrect = false, isWrong = false, isEmpty = false;
    
    if (!stAns || stAns === "BOŞ") {
      isEmpty = true;
      topicAnalysis[topic].empty++;
    } else if (stAns === k.correctOption) {
      isCorrect = true;
      topicAnalysis[topic].correct++;
    } else {
      isWrong = true;
      topicAnalysis[topic].wrong++;
    }

    // Section update
    if (sec) {
      if (isCorrect) sec.correct++;
      else if (isWrong) sec.wrong++;
      else sec.empty++;
      sec.net = sec.correct - (sec.wrong * result.exam.penaltyRatio);
    }
  });


  const wrongOrEmptyQuestions = result.exam.keys
    .filter(k => {
      const ans = answerMap.get(k.questionNumber);
      return (!ans || ans === "BOŞ" || (k.correctOption !== "IPTAL" && ans !== k.correctOption));
    })
    .filter(k => k.videoUrl);

  return (
    <div className="font-sans text-slate-800 pb-20">
      <main className="max-w-6xl mx-auto space-y-8 mt-4 px-4">
        {/* Başlık Kartı */}
        <div className="bg-white border border-slate-200 rounded-3xl p-8 shadow-sm relative overflow-hidden">
          <div className="absolute top-0 right-0 w-64 h-64 bg-slate-50 rounded-full blur-3xl -mr-20 -mt-20 pointer-events-none"></div>
          
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 relative z-10">
            <div>
              <span className="px-3 py-1 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-lg text-[10px] font-bold tracking-widest uppercase mb-4 inline-block">Sınav Tamamlandı</span>
              <h2 className="text-3xl font-black text-slate-900">{result.exam.title}</h2>
              <div className="flex items-center gap-4 mt-3">
                 <p className="text-slate-500 max-w-xl text-sm">{result.exam.description}</p>
                 <div className="px-4 py-2 bg-gradient-to-r from-amber-50 to-amber-100 border border-amber-200 rounded-xl flex items-center gap-2">
                    <Trophy className="w-5 h-5 text-amber-500" />
                    <div>
                      <span className="block text-[9px] uppercase font-black text-amber-600/70 tracking-wider">Genel Sıralama</span>
                      <span className="font-bold text-amber-700">{displayRank} / {displayTotal}</span>
                    </div>
                 </div>
              </div>
            </div>
            
            <div className="flex gap-4">
              <PrintButton />
              {result.exam.solutionPdfUrl && (
                <Link href={`/ogrenci/karne/${result.id}/cozum`} className="flex items-center gap-2 px-5 py-2.5 bg-white hover:bg-slate-50 border border-slate-200 text-slate-700 rounded-xl font-bold transition-colors shadow-sm text-sm print:hidden">
                  <FileText className="w-4 h-4 text-emerald-500" /> Çözüm Kitapçığı & Optiğim
                </Link>
              )}
            </div>
          </div>
        </div>

        {/* Skor İstatistikleri */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          <div className="bg-white border border-slate-200 rounded-2xl p-6 relative overflow-hidden shadow-sm">
             <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-50 rounded-full -mr-16 -mt-16"></div>
             <p className="text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-2">Doğru Sayısı</p>
             <div className="flex items-end gap-2 relative z-10">
               <span className="text-4xl font-black text-emerald-600">{result.correctCount}</span>
               <CheckCircle2 className="w-6 h-6 text-emerald-500 mb-1 opacity-80" />
             </div>
          </div>
          <div className="bg-white border border-slate-200 rounded-2xl p-6 relative overflow-hidden shadow-sm">
             <div className="absolute top-0 right-0 w-32 h-32 bg-red-50 rounded-full -mr-16 -mt-16"></div>
             <p className="text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-2">Yanlış Sayısı</p>
             <div className="flex items-end gap-2 relative z-10">
               <span className="text-4xl font-black text-red-500">{result.wrongCount}</span>
               <XCircle className="w-6 h-6 text-red-400 mb-1 opacity-80" />
             </div>
          </div>
          <div className="bg-white border border-slate-200 rounded-2xl p-6 relative overflow-hidden shadow-sm">
             <div className="absolute top-0 right-0 w-32 h-32 bg-slate-100 rounded-full -mr-16 -mt-16"></div>
             <p className="text-slate-500 text-[10px] font-bold uppercase tracking-wider mb-2">Boş Bırakılan</p>
             <div className="flex items-end gap-2 relative z-10">
               <span className="text-4xl font-black text-slate-500">{result.emptyCount}</span>
               <MinusCircle className="w-6 h-6 text-slate-400 mb-1 opacity-80" />
             </div>
          </div>
          <div className="bg-white border border-indigo-200 rounded-2xl p-6 relative overflow-hidden shadow-[0_0_20px_rgba(99,102,241,0.15)] flex flex-col justify-between">
             <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-50/50 rounded-full -mr-16 -mt-16"></div>
             <p className="text-indigo-600 text-[10px] font-bold uppercase tracking-wider mb-2">Sınav Puanı</p>
             <div className="flex items-end gap-2 relative z-10">
               <span className="text-4xl md:text-5xl font-black text-slate-800">{result.score}</span>
               <span className="text-sm font-bold text-slate-400 mb-1.5">/ {ceilingScore}</span>
             </div>
          </div>
        </div>

        {/* Test (Bölüm) Analizi Tablosu */}
        {sectionAnalysis.length > 0 && (
          <div className="bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-sm">
            <div className="p-5 border-b border-slate-100 flex items-center justify-between bg-slate-50">
              <h3 className="text-lg font-bold flex items-center gap-2 text-slate-800">
                <BookOpen className="w-5 h-5 text-indigo-600" /> Test (Bölüm) Analizi
              </h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm whitespace-nowrap">
                <thead className="bg-slate-50/50 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
                  <tr>
                    <th className="px-6 py-4 border-b border-slate-100">Bölüm / Test Adı</th>
                    <th className="px-6 py-4 border-b border-slate-100 text-center">Soru Sayısı</th>
                    <th className="px-6 py-4 border-b border-slate-100 text-center text-emerald-600">Doğru</th>
                    <th className="px-6 py-4 border-b border-slate-100 text-center text-red-500">Yanlış</th>
                    <th className="px-6 py-4 border-b border-slate-100 text-center text-slate-400">Boş</th>
                    <th className="px-6 py-4 border-b border-slate-100 text-center text-blue-600">Net</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {sectionAnalysis.map(sec => (
                    <tr key={sec.id} className="hover:bg-slate-50 transition-colors">
                      <td className="px-6 py-4 font-bold text-slate-700">{sec.title}</td>
                      <td className="px-6 py-4 text-center font-semibold text-slate-500">{sec.count}</td>
                      <td className="px-6 py-4 text-center font-bold text-emerald-600">{sec.correct}</td>
                      <td className="px-6 py-4 text-center font-bold text-red-500">{sec.wrong}</td>
                      <td className="px-6 py-4 text-center font-bold text-slate-400">{sec.empty}</td>
                      <td className="px-6 py-4 text-center font-black text-blue-600 bg-blue-50/30">{sec.net.toFixed(2)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Analiz */}
        {Object.keys(topicAnalysis).length > 0 && (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-sm">
              <div className="p-5 border-b border-slate-100 flex items-center justify-between bg-slate-50">
                <h3 className="text-lg font-bold flex items-center gap-2 text-slate-800">
                  <Activity className="w-5 h-5 text-blue-600" /> Konu (Kazanım) Analizi
                </h3>
              </div>
              <div className="p-6">
                <div className="grid grid-cols-1 gap-4">
                  {Object.entries(topicAnalysis).map(([topic, stats]) => {
                    const total = stats.correct + stats.wrong + stats.empty;
                    const percentage = Math.round((stats.correct / total) * 100);
                    
                    return (
                      <div key={topic} className="flex flex-col md:flex-row md:items-center justify-between p-4 bg-white border border-slate-100 shadow-sm rounded-xl gap-4 hover:border-slate-200 transition-colors">
                        <div className="flex-1">
                          <h4 className="font-bold text-slate-800 text-base mb-1">{topic}</h4>
                          <div className="flex items-center gap-4 text-[10px] font-black uppercase tracking-wider">
                            <span className="text-emerald-600">{stats.correct} D</span>
                            <span className="text-red-500">{stats.wrong} Y</span>
                            <span className="text-slate-400">{stats.empty} B</span>
                          </div>
                        </div>
                        
                        <div className="flex items-center gap-3 w-full md:w-32 shrink-0">
                          <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                            <div className="h-full bg-blue-500 rounded-full" style={{ width: `${percentage}%` }}></div>
                          </div>
                          <span className="font-mono font-bold text-slate-700 w-10 text-right text-sm">{percentage}%</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            {wrongOrEmptyQuestions.length > 0 && (
              <div className="bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-sm h-fit">
                <div className="p-4 border-b border-slate-100 bg-slate-50 flex items-center gap-2">
                  <PlayCircle className="w-5 h-5 text-red-500" />
                  <h3 className="text-sm font-bold text-slate-800">Yanlış/Boş Çözümleri</h3>
                </div>
                <div className="p-4 max-h-[400px] overflow-y-auto custom-scrollbar flex flex-col gap-2">
                  {wrongOrEmptyQuestions.map(k => (
                    <a key={k.id} href={k.videoUrl!} target="_blank" className="flex items-center justify-between p-3 rounded-xl border border-slate-100 hover:border-red-200 hover:bg-red-50/50 transition-colors group">
                      <div>
                        <span className="text-xs font-black text-slate-400 uppercase tracking-wider block mb-0.5">Soru {k.questionNumber}</span>
                        <span className="text-sm font-bold text-slate-700 truncate max-w-[150px] inline-block">{k.topic || 'Genel'}</span>
                      </div>
                      <span className="px-3 py-1.5 bg-red-100 text-red-600 text-[10px] font-bold rounded-lg uppercase tracking-wider group-hover:bg-red-500 group-hover:text-white transition-colors">İzle</span>
                    </a>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}
