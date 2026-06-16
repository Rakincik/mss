import { getCurrentUserWithGroups } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { BookOpen, Clock, Activity, Zap, CheckCircle2, Target, PlayCircle, Lock } from "lucide-react";
import Link from "next/link";
import dayjs from "dayjs";
import 'dayjs/locale/tr';
dayjs.locale('tr');

export const dynamic = "force-dynamic";

export default async function StudentDashboardPage() {
  const student = await getCurrentUserWithGroups();
  if (!student) {
    redirect("/login");
  }

  if (!student.isActive) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6 text-center">
         <div className="bg-white border border-red-200 rounded-3xl p-10 max-w-lg w-full shadow-sm">
            <h2 className="text-3xl font-bold text-red-600 mb-4">Hesabınız Pasife Alınmış</h2>
            <p className="text-slate-500 font-medium mb-8">Erişiminiz sistem yöneticisi tarafından dondurulmuştur. Sınavlara ve karnelerinize ulaşmak için kurum yetkilileri ile iletişime geçin.</p>
         </div>
      </div>
    );
  }

  // Tekil Sınavlar (Pakete bağlı OLMAYANLAR)
  const singleExams = await prisma.exam.findMany({
    where: {
      isActive: true,
      packageId: null, // Sadece tekil sınavlar
      AND: [
        {
          OR: [
            { endTime: null },
            { endTime: { gt: new Date() } }
          ]
        },
        {
          OR: [
            {
              groups: { 
                some: { 
                  id: { in: ((student as any).groups || []).map((g: any) => g.id).concat("NO_GROUP") },
                  isActive: true,
                  OR: [
                    { expireAt: null },
                    { expireAt: { gt: new Date() } }
                  ]
                } 
              }
            },
            {
              directUsers: { 
                some: { id: student.id } 
              }
            }
          ]
        }
      ]
    },
    include: {
      results: { where: { userId: student.id } }
    },
    orderBy: { createdAt: "desc" }
  });

  // Paket Sınavlar (İçinde öğrencinin yetkili olduğu en az 1 sınav barındıran paketler)
  const packages = await prisma.examPackage.findMany({
    where: {
      isActive: true,
      exams: {
        some: {
          isActive: true,
          OR: [
            {
              groups: { 
                some: { 
                  id: { in: ((student as any).groups || []).map((g: any) => g.id).concat("NO_GROUP") },
                  isActive: true,
                  OR: [
                    { expireAt: null },
                    { expireAt: { gt: new Date() } }
                  ]
                } 
              }
            },
            {
              directUsers: { 
                some: { id: student.id } 
              }
            }
          ]
        }
      }
    },
    include: {
      exams: {
        orderBy: { startTime: 'asc' },
        include: {
          results: { where: { userId: student.id } }
        }
      },
      results: { where: { userId: student.id } } // PackageResult
    },
    orderBy: { createdAt: "desc" }
  });

  return (
    <div className="font-sans text-slate-800 flex flex-col space-y-6">
      <main className="flex-1 w-full max-w-6xl mx-auto space-y-6">
        
        {/* Welcome Banner matched with Soru Bankası */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 text-white p-6 shadow-md">
            <div className="absolute top-0 right-0 w-64 h-64 bg-blue-500/10 rounded-full -mr-32 -mt-32" />
            <div className="absolute bottom-0 left-0 w-48 h-48 bg-emerald-500/10 rounded-full -ml-24 -mb-24" />
            
            <div className="relative flex items-center justify-between flex-wrap gap-4">
                <div className="space-y-1">
                    <div className="flex items-center gap-2 text-white/60 text-sm">
                        İyi çalışmalar
                    </div>
                    <h1 className="text-2xl font-bold">{student.name}, bugün hangi denemeyi çözelim?</h1>
                </div>
            
                <div className="flex items-center gap-3 flex-wrap">
                    <div className="flex items-center gap-3 bg-white/10 backdrop-blur-sm rounded-xl px-4 py-2.5">
                        <div className="p-1.5 bg-blue-500/30 rounded-lg">
                             <BookOpen className="h-4 w-4 text-blue-300" />
                        </div>
                        <div>
                             <p className="text-[10px] text-white/50 uppercase tracking-widest">Tanımlanan</p>
                             <p className="text-sm font-bold">{singleExams.length + packages.length} İçerik</p>
                        </div>
                    </div>
                    <div className="flex items-center gap-3 bg-white/10 backdrop-blur-sm rounded-xl px-4 py-2.5">
                        <div className="p-1.5 bg-emerald-500/30 rounded-lg">
                             <CheckCircle2 className="h-4 w-4 text-emerald-300" />
                        </div>
                        <div>
                             <p className="text-[10px] text-white/50 uppercase tracking-widest">Tamamlanan</p>
                             <p className="text-sm font-bold">{singleExams.filter(e => e.results[0]?.isFinished).length + packages.filter(p => p.results.length > 0).length} Adet</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {packages.length > 0 && (
          <div className="mb-12">
            <h2 className="text-xl font-bold flex items-center gap-2 text-slate-800 mb-6">
              <BookOpen className="w-5 h-5 text-indigo-600" /> Oturum Bazlı (Paket) Sınavlar
            </h2>
            <div className="grid grid-cols-1 gap-6">
              {packages.map(pkg => {
                const isComputed = pkg.results && pkg.results.length > 0 && pkg.results[0].isComputed;
                const isResultsPublished = !pkg.showResultsTime || new Date() >= new Date(pkg.showResultsTime);
                const canSeeResults = isComputed && isResultsPublished;
                
                return (
                  <div key={pkg.id} className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <span className="px-3 py-1 bg-indigo-50 text-indigo-600 border border-indigo-100 rounded-lg text-[10px] font-bold tracking-widest uppercase mb-3 inline-block">Çoklu Oturum</span>
                        <h3 className="text-2xl font-bold text-slate-800">{pkg.title}</h3>
                        <p className="text-sm text-slate-500 mt-1">{pkg.description || "Bu paket için açıklama bulunmuyor."}</p>
                        
                        {pkg.exams.filter((e:any) => e.results[0]?.isFinished).length > 0 && 
                         pkg.exams.filter((e:any) => e.results[0]?.isFinished).length < pkg.exams.length && 
                         !isComputed && (
                          <div className="mt-3 px-4 py-2 bg-amber-50 border border-amber-200 rounded-lg text-amber-700 text-xs font-bold inline-block">
                            ⚠️ Resmi puanınızın hesaplanabilmesi için tüm oturumları tamamlamanız gerekmektedir.
                          </div>
                        )}
                      </div>
                      {isComputed && !isResultsPublished && (
                        <div className="flex flex-col items-end">
                           <span className="px-4 py-1.5 bg-amber-100 text-amber-700 border border-amber-200 rounded-lg font-bold tracking-wider mb-2 text-[10px] uppercase">Sonuçlar Bekleniyor</span>
                           <span className="px-5 py-2 bg-slate-100 text-slate-500 rounded-lg text-xs font-bold shadow-sm">
                             {dayjs(pkg.showResultsTime).format("DD MMM HH:mm")}'de Açıklanacak
                           </span>
                        </div>
                      )}
                      {canSeeResults && (
                        <div className="flex flex-col items-end">
                           <span className="px-4 py-1.5 bg-emerald-100 text-emerald-700 border border-emerald-200 rounded-lg font-bold tracking-wider mb-2 text-[10px] uppercase">Karneniz Hazır</span>
                           <Link href={`/ogrenci/karneler/paket/${pkg.id}`} className="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-sm font-bold transition shadow-sm">Sonuç Karnemi Gör</Link>
                        </div>
                      )}
                    </div>
                    
                    <div className="bg-slate-50 rounded-xl border border-slate-100 p-4 mt-6">
                      <h4 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-4">Oturumlar (Sınav Detayları)</h4>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {pkg.exams.map((exam: any, idx: number) => {
                          const result = exam.results[0];
                          const isFinished = result?.isFinished;
                          const isUpcoming = exam.startTime && new Date(exam.startTime) > new Date();
                          
                          let isLockedBySequence = false;
                          if (pkg.isSequential && idx > 0) {
                            const prevExamResult = pkg.exams[idx - 1].results[0];
                            if (!prevExamResult?.isFinished) {
                              isLockedBySequence = true;
                            }
                          }

                          return (
                            <div key={exam.id} className="bg-white border border-slate-200 rounded-xl p-4 flex items-center justify-between">
                              <div>
                                <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest block mb-1">{idx + 1}. Oturum</span>
                                <h5 className="font-bold text-slate-800">{exam.title}</h5>
                                {exam.startTime && (
                                  <p className="text-xs text-slate-500 mt-1 flex items-center gap-1"><Clock className="w-3 h-3"/> {dayjs(exam.startTime).format("DD MMM HH:mm")}</p>
                                )}
                              </div>
                              <div>
                                {isFinished ? (
                                  <Link href={`/ogrenci/karne/${result.id}`} className="px-3 py-1.5 bg-emerald-50 text-emerald-700 border border-emerald-200 rounded-lg text-xs font-bold">Sonuç</Link>
                                ) : isLockedBySequence ? (
                                  <span className="px-3 py-1.5 bg-slate-50 text-slate-400 border border-slate-200 rounded-lg text-xs font-bold flex items-center gap-1 cursor-not-allowed" title="Önceki oturumu bitirmelisiniz"><Lock className="w-3 h-3"/> Kilitli</span>
                                ) : isUpcoming ? (
                                  <span className="px-3 py-1.5 bg-slate-100 text-slate-500 rounded-lg text-xs font-bold">Bekleniyor</span>
                                ) : (
                                  <Link href={`/ogrenci/sinav/${exam.id}`} className="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-xs font-bold">Başla</Link>
                                )}
                              </div>
                            </div>
                          )
                        })}
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        )}

        <div>
          <h2 className="text-xl font-bold flex items-center gap-2 text-slate-800">
            <Activity className="w-5 h-5 text-blue-600" /> Bireysel Sınavlarım
          </h2>
        </div>

        {singleExams.length === 0 ? (
          <div className="py-20 text-center border-2 border-dashed border-slate-200 rounded-3xl bg-white shadow-sm mt-6">
            <BookOpen className="w-12 h-12 text-slate-300 mx-auto mb-4" />
            <h3 className="text-xl font-bold text-slate-700">Bekleyen sınav yok!</h3>
            <p className="text-slate-500 mt-2 max-w-md mx-auto text-sm">Şu an atanmış aktif bir bireysel deneme görünmüyor.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6 mt-6">
            {singleExams.map(exam => {
              const result = exam.results[0];
              const isFinished = result?.isFinished;
              const isUpcoming = exam.startTime && new Date(exam.startTime) > new Date();
              
              return (
                <div key={exam.id} className="relative bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all flex flex-col group">
                  {isFinished && <div className="absolute inset-0 bg-white/80 backdrop-blur-sm z-10 flex flex-col items-center justify-center rounded-2xl">
                    <span className="px-4 py-1.5 bg-emerald-100 text-emerald-700 border border-emerald-200 rounded-lg font-bold tracking-wider mb-3 text-[10px] uppercase">Sınav Tamamlandı</span>
                    <Link href={`/ogrenci/karne/${result.id}`} className="px-6 py-2 bg-white hover:bg-slate-50 text-slate-700 border border-slate-300 rounded-lg text-sm font-bold transition shadow-sm">Karnemi Görüntüle</Link>
                  </div>}

                  <div className="p-6 flex-1">
                    <div className="flex justify-between items-start mb-4">
                      <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center">
                        <BookOpen className="w-6 h-6" />
                      </div>
                      <div className="flex flex-col items-end gap-1">
                        {isUpcoming && (
                          <span className="px-2.5 py-1 bg-amber-50 text-amber-600 border border-amber-200 rounded-lg text-[10px] font-bold uppercase tracking-wider">
                            Yaklaşan Sınav
                          </span>
                        )}
                        <span className="px-3 py-1 bg-slate-50 border border-slate-200 rounded-lg text-[10px] font-bold text-slate-500 flex items-center gap-1.5 uppercase tracking-wider">
                          <Clock className="w-3.5 h-3.5" /> {exam.durationMinutes || 0} Dakika
                        </span>
                      </div>
                    </div>
                    
                    <h3 className="text-lg font-bold mb-2 text-slate-800 line-clamp-2">{exam.title}</h3>
                    <p className="text-slate-500 text-xs line-clamp-2 min-h-[32px] mb-6">{exam.description || "Bu sınav için bir açıklama girilmedi."}</p>
                    
                    <div className="flex items-center gap-4 text-sm font-medium">
                      <div className="px-3 py-2 bg-slate-50 rounded-lg border border-slate-100 w-full flex flex-col gap-1">
                        <div className="flex items-center justify-between">
                          <span className="text-slate-500 text-[10px] uppercase tracking-widest font-bold">Soru Sayısı</span>
                          <span className="text-slate-800 font-bold">{exam.questionCount} Soru</span>
                        </div>
                        {isUpcoming && exam.startTime && (
                          <div className="flex items-center justify-between mt-1 pt-1 border-t border-slate-200">
                            <span className="text-slate-500 text-[10px] uppercase tracking-widest font-bold">Başlama Saati</span>
                            <span className="text-amber-600 font-bold text-xs">{dayjs(exam.startTime).format("DD MMM YYYY, HH:mm")}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  <div className="p-4 border-t border-slate-100 bg-slate-50/50 flex justify-end">
                    {isUpcoming ? (
                      <button 
                        disabled
                        className="w-full text-center px-4 py-2.5 bg-slate-200 text-slate-500 font-bold rounded-xl cursor-not-allowed text-sm"
                      >
                        Sınav Saati Bekleniyor
                      </button>
                    ) : (
                      <Link 
                        href={`/ogrenci/sinav/${exam.id}`}
                        className="w-full text-center px-4 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl shadow-sm transition-all text-sm"
                      >
                        Sınava Başla
                      </Link>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Dahil Olduğum Paketler / Sınıflar */}
        <div className="mt-12">
          <h2 className="text-xl font-bold flex items-center gap-2 text-slate-800 mb-6">
            <Target className="w-5 h-5 text-emerald-600" /> Dahil Olduğum Paketler / Sınıflar
          </h2>
          {student.groups && student.groups.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {student.groups.map((group: any) => (
                <div key={group.id} className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col justify-between">
                   <div>
                     <span className="px-3 py-1 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-lg text-[10px] font-bold tracking-widest uppercase mb-4 inline-block">Aktif Paket</span>
                     <h3 className="text-lg font-bold text-slate-800 mb-2">{group.name}</h3>
                     <p className="text-slate-500 text-xs mb-4">{group.description || "Bu pakete ait bir açıklama bulunmuyor."}</p>
                   </div>
                   <div className="pt-4 border-t border-slate-100">
                     <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Sona Erme Tarihi</span>
                     <p className="text-slate-700 font-medium text-sm mt-1">
                       {group.expireAt ? dayjs(group.expireAt).format("DD MMM YYYY") : "Süresiz Erişim"}
                     </p>
                   </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="py-12 text-center border-2 border-dashed border-slate-200 rounded-3xl bg-white shadow-sm">
              <p className="text-slate-500 text-sm">Şu an aktif olduğunuz herhangi bir paket veya sınıf bulunmuyor.</p>
            </div>
          )}
        </div>

      </main>
    </div>
  );
}
