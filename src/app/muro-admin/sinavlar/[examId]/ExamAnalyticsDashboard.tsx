"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import { Trophy, Users, FileText, AlertTriangle, ShieldAlert, BarChart3, LineChart, Target, EyeOff, Download } from "lucide-react";
import * as xlsx from "xlsx";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Cell } from "recharts";

type ExamAnalyticsProps = {
  exam: any;
  parsedSections: any[];
  calculatedResults: any[];
  securityLogs: any[];
};

export default function ExamAnalyticsDashboard({ exam, parsedSections, calculatedResults, securityLogs }: ExamAnalyticsProps) {
  const [activeTab, setActiveTab] = useState<"LEADERBOARD" | "STATS" | "ITEM_ANALYSIS" | "SECURITY">("LEADERBOARD");

  // --- EXCEL EXPORT ---
  const exportToExcel = () => {
    if (calculatedResults.length === 0) return;

    const penaltyRatio = exam.penaltyRatio || 0.25;

    // Ana sonuç verisi
    const rows = calculatedResults.map((r: any, idx: number) => {
      const totalNet = r.correctCount - (r.wrongCount * penaltyRatio);
      const row: Record<string, any> = {
        'Sıra': idx + 1,
        'Ad Soyad': r.user.name || 'İsimsiz',
        'E-posta': r.user.email || '-',
        'Doğru': r.correctCount,
        'Yanlış': r.wrongCount,
        'Boş': r.emptyCount,
        'Genel Net': Number(totalNet.toFixed(2)),
      };

      // Bölüm bazlı netler
      if (r.sectionNets && r.sectionNets.length > 0) {
        r.sectionNets.forEach((sn: any) => {
          row[`${sn.title} D`] = sn.correct;
          row[`${sn.title} Y`] = sn.wrong;
          row[`${sn.title} B`] = sn.empty;
          row[`${sn.title} Net`] = Number(sn.net.toFixed(2));
        });
      }

      row['Puan'] = Number(r.score.toFixed(2));
      row['Durum'] = r.isFinished ? 'Tamamlandı' : 'Devam Ediyor';
      return row;
    });

    // Worksheet oluştur
    const ws = xlsx.utils.json_to_sheet(rows);

    // Kolon genişlikleri
    const colKeys = Object.keys(rows[0] || {});
    ws['!cols'] = colKeys.map(key => ({
      wch: Math.max(key.length + 2, 12)
    }));

    // Workbook oluştur
    const wb = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(wb, ws, 'Sonuçlar');

    // İstatistik sayfası
    const finishedResults = calculatedResults.filter((r: any) => r.isFinished);
    if (finishedResults.length > 0) {
      const scores = finishedResults.map((r: any) => r.score).sort((a: number, b: number) => a - b);
      const avg = scores.reduce((a: number, b: number) => a + b, 0) / scores.length;
      const statsRows = [
        { 'İstatistik': 'Sınav Adı', 'Değer': exam.title },
        { 'İstatistik': 'Toplam Katılımcı', 'Değer': finishedResults.length },
        { 'İstatistik': 'Toplam Soru', 'Değer': exam.questionCount },
        { 'İstatistik': 'Ortalama Puan', 'Değer': Number(avg.toFixed(2)) },
        { 'İstatistik': 'En Yüksek Puan', 'Değer': scores[scores.length - 1] },
        { 'İstatistik': 'En Düşük Puan', 'Değer': scores[0] },
        { 'İstatistik': 'Medyan Puan', 'Değer': scores[Math.floor(scores.length / 2)] },
        { 'İstatistik': 'Yanlış Cezası', 'Değer': `${penaltyRatio} (Her ${Math.round(1/penaltyRatio)} yanlış 1 doğruyu götürür)` },
        { 'İstatistik': 'Rapor Tarihi', 'Değer': new Date().toLocaleString('tr-TR') },
      ];
      const statsWs = xlsx.utils.json_to_sheet(statsRows);
      statsWs['!cols'] = [{ wch: 22 }, { wch: 40 }];
      xlsx.utils.book_append_sheet(wb, statsWs, 'İstatistikler');
    }

    // Dosya adını Türkçe dostu yap
    const safeName = exam.title
      .replace(/[^a-zA-Z0-9ğüşıöçĞÜŞİÖÇ\s-]/g, '')
      .replace(/\s+/g, '_')
      .substring(0, 50);
    const dateStr = new Date().toISOString().slice(0, 10);

    // UTF-8 BOM ile yaz (Türkçe karakter desteği)
    xlsx.writeFile(wb, `${safeName}_Sonuclar_${dateStr}.xlsx`, {
      bookType: 'xlsx',
      type: 'binary',
    });
  };

  // --- 1. İSTATİSTİK HESAPLAMALARI ---
  const statsData = useMemo(() => {
    if (calculatedResults.length === 0) return null;
    let scores = calculatedResults.map(r => r.score).sort((a,b) => a-b);
    let avgScore = scores.reduce((a,b) => a+b, 0) / scores.length;
    let maxScore = scores[scores.length - 1];
    let minScore = scores[0];
    let median = scores[Math.floor(scores.length / 2)];

    // Çan Eğrisi / Histogram Verisi (10'ar puanlık dilimler)
    const buckets = new Array(11).fill(0); // 0-9, 10-19 ... 90-99, 100
    scores.forEach(s => {
      let bucketIdx = Math.floor(s / 10);
      if (bucketIdx > 10) bucketIdx = 10;
      if (bucketIdx < 0) bucketIdx = 0;
      buckets[bucketIdx]++;
    });

    const chartData = buckets.map((count, i) => ({
      name: i === 10 ? "100" : `${i * 10}-${i * 10 + 9}`,
      kisiSayisi: count
    }));

    return { avgScore, maxScore, minScore, median, chartData };
  }, [calculatedResults]);

  // --- 2. SORU/MADDE ANALİZİ HESAPLAMALARI ---
  const itemAnalysisData = useMemo(() => {
    if (!exam.keys || exam.keys.length === 0 || calculatedResults.length === 0) return [];
    
    // Her soru için istatistik çıkar
    const analysis = exam.keys.map((key: any) => {
      let aCount = 0, bCount = 0, cCount = 0, dCount = 0, eCount = 0, emptyCount = 0;
      
      calculatedResults.forEach(res => {
         // Öğrencinin bu soruya verdiği cevabı bul
         const ans = res.answers?.find((a: any) => a.questionNumber === key.questionNumber);
         if (!ans || !ans.selectedOption) emptyCount++;
         else if (ans.selectedOption === "A") aCount++;
         else if (ans.selectedOption === "B") bCount++;
         else if (ans.selectedOption === "C") cCount++;
         else if (ans.selectedOption === "D") dCount++;
         else if (ans.selectedOption === "E") eCount++;
      });

      const totalParticipants = calculatedResults.length;
      const correctOption = key.correctOption;
      
      // Çeldiricileri bul (> %25 seçilen VEYA doğru şıktan daha fazla seçilen yanlış şık)
      const options = [
        { opt: "A", count: aCount },
        { opt: "B", count: bCount },
        { opt: "C", count: cCount },
        { opt: "D", count: dCount },
        { opt: "E", count: eCount }
      ];

      // Doğru sayısını bul
      const correctCount = options.find(o => o.opt === correctOption)?.count || 0;
      const correctRate = (correctCount / totalParticipants) * 100;

      let strongDistractor = null;
      let isMisconception = false;

      options.forEach(o => {
         if (o.opt !== correctOption && o.opt !== "IPTAL") {
            const selectRate = (o.count / totalParticipants) * 100;
            if (selectRate > 25 || o.count > correctCount) {
               strongDistractor = o.opt;
               isMisconception = true;
            }
         }
      });

      // Zorluk Derecesi
      let difficulty = "NORMAL";
      let difficultyColor = "bg-blue-100 text-blue-700";
      if (correctRate > 75) { difficulty = "KOLAY"; difficultyColor = "bg-emerald-100 text-emerald-700"; }
      else if (correctRate < 35) { difficulty = "ZOR"; difficultyColor = "bg-rose-100 text-rose-700"; }

      return {
         ...key,
         stats: { aCount, bCount, cCount, dCount, eCount, emptyCount, totalParticipants, correctRate },
         options,
         strongDistractor,
         isMisconception,
         difficulty,
         difficultyColor
      };
    });

    return analysis;
  }, [exam, calculatedResults]);

  // --- 3. GÜVENLİK RADARI HESAPLAMALARI ---
  const securityStats = useMemo(() => {
    if (!securityLogs || securityLogs.length === 0) return [];
    
    // Öğrenci ID'ye göre grupla
    const map = new Map();
    securityLogs.forEach(log => {
      if (!map.has(log.userId)) {
        map.set(log.userId, { user: log.user, actionCount: 0, actions: [] });
      }
      const data = map.get(log.userId);
      data.actionCount++;
      data.actions.push(log);
    });

    const arr = Array.from(map.values()).sort((a,b) => b.actionCount - a.actionCount);
    return arr;
  }, [securityLogs]);

  return (
    <div className="bg-white border border-slate-200 rounded-3xl shadow-sm overflow-hidden mt-6">
      
      {/* TABS HEADER */}
      <div className="flex items-center overflow-x-auto custom-scrollbar border-b border-slate-100 bg-slate-50/50 p-2">
        <button 
          onClick={() => setActiveTab("LEADERBOARD")} 
          className={`px-5 py-3 text-sm font-bold rounded-xl transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === "LEADERBOARD" ? "bg-white text-blue-600 shadow-sm border border-slate-200" : "text-slate-500 hover:bg-slate-100"}`}
        >
          <Trophy className="w-4 h-4" /> Sıralama Paneli
        </button>
        <button 
          onClick={() => setActiveTab("STATS")} 
          className={`px-5 py-3 text-sm font-bold rounded-xl transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === "STATS" ? "bg-white text-indigo-600 shadow-sm border border-slate-200" : "text-slate-500 hover:bg-slate-100"}`}
        >
          <BarChart3 className="w-4 h-4" /> Çan Eğrisi & İstatistikler
        </button>
        <button 
          onClick={() => setActiveTab("ITEM_ANALYSIS")} 
          className={`px-5 py-3 text-sm font-bold rounded-xl transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === "ITEM_ANALYSIS" ? "bg-white text-emerald-600 shadow-sm border border-slate-200" : "text-slate-500 hover:bg-slate-100"}`}
        >
          <Target className="w-4 h-4" /> Madde / Soru Analizi
        </button>
        <button 
          onClick={() => setActiveTab("SECURITY")} 
          className={`px-5 py-3 text-sm font-bold rounded-xl transition-all flex items-center gap-2 whitespace-nowrap ${activeTab === "SECURITY" ? "bg-white text-rose-600 shadow-sm border border-slate-200" : "text-slate-500 hover:bg-slate-100"}`}
        >
          <ShieldAlert className="w-4 h-4" /> Güvenlik Radarı (Kopya)
        </button>

        {/* Excel Export Butonu */}
        <div className="ml-auto pl-4">
          <button
            onClick={exportToExcel}
            disabled={calculatedResults.length === 0}
            className="flex items-center gap-2 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 disabled:opacity-40 disabled:cursor-not-allowed text-white font-bold rounded-xl transition-colors shadow-sm text-sm active:scale-95 whitespace-nowrap"
          >
            <Download className="w-4 h-4" /> Excel İndir
          </button>
        </div>
      </div>

      {/* TABS CONTENT */}
      <div className="p-0">

        {/* --- 1. LEADERBOARD --- */}
        {activeTab === "LEADERBOARD" && (
          <div className="overflow-x-auto custom-scrollbar">
            <table className="w-full text-left text-sm whitespace-nowrap">
              <thead className="bg-[#f8fafc] text-slate-500 font-bold uppercase tracking-wider text-[10px]">
                <tr>
                  <th className="px-6 py-4 border-b border-slate-200">Sıra</th>
                  <th className="px-6 py-4 border-b border-slate-200">Öğrenci Adı</th>
                  <th className="px-6 py-4 border-b border-slate-200 text-center">Genel D/Y/B</th>
                  <th className="px-6 py-4 border-b border-slate-200 text-center text-blue-600 border-x border-slate-100">Genel Net</th>
                  {parsedSections.map(s => (
                    <th key={s.id} className="px-6 py-4 border-b border-slate-200 text-center bg-indigo-50/50 text-indigo-600/70 border-r border-indigo-100/50">
                      <span className="block truncate max-w-[120px]" title={s.title}>{s.title}</span>
                      <span className="text-[9px] text-indigo-400">Net</span>
                    </th>
                  ))}
                  <th className="px-6 py-4 border-b border-slate-200 text-center text-emerald-600 border-l border-slate-100 shadow-[-5px_0_10px_rgba(0,0,0,0.02)]">Sınav Puanı</th>
                  <th className="px-6 py-4 border-b border-slate-200 text-right">İşlem</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {calculatedResults.map((r, idx) => {
                  const totalNet = r.correctCount - (r.wrongCount * exam.penaltyRatio);
                  return (
                    <tr key={r.id} className="hover:bg-blue-50/30 transition-colors group">
                      <td className="px-6 py-4">
                        {idx === 0 ? <span className="w-8 h-8 flex items-center justify-center bg-amber-100 text-amber-600 font-black rounded-lg">1</span> :
                         idx === 1 ? <span className="w-8 h-8 flex items-center justify-center bg-slate-200 text-slate-600 font-black rounded-lg">2</span> :
                         idx === 2 ? <span className="w-8 h-8 flex items-center justify-center bg-orange-100 text-orange-600 font-black rounded-lg">3</span> :
                         <span className="w-8 h-8 flex items-center justify-center font-bold text-slate-400">{idx + 1}</span>}
                      </td>
                      <td className="px-6 py-4">
                        <p className="font-bold text-slate-800">{r.user.name || "İsimsiz Kullanıcı"}</p>
                        <p className="text-[10px] uppercase font-bold text-slate-400 mt-0.5">{r.user.email}</p>
                      </td>
                      <td className="px-6 py-4 text-center">
                         <div className="flex items-center justify-center gap-2 text-xs font-bold">
                           <span className="text-emerald-500">{r.correctCount}</span>
                           <span className="text-slate-300">/</span>
                           <span className="text-red-500">{r.wrongCount}</span>
                           <span className="text-slate-300">/</span>
                           <span className="text-slate-400">{r.emptyCount}</span>
                         </div>
                      </td>
                      <td className="px-6 py-4 text-center border-x border-slate-100 text-blue-600 bg-blue-50/10 group-hover:bg-blue-50/50">
                        <span className="font-black text-base">{totalNet.toFixed(2)}</span>
                      </td>
                      
                      {/* Section Nets */}
                      {r.sectionNets.map((sn: any) => (
                        <td key={sn.id} className="px-6 py-4 text-center font-black text-indigo-600 bg-indigo-50/10 border-r border-indigo-50/50">
                          {sn.net.toFixed(2)}
                        </td>
                      ))}

                      <td className="px-6 py-4 text-center border-l border-slate-100 bg-emerald-50/10 shadow-[-5px_0_10px_rgba(0,0,0,0.01)] group-hover:bg-emerald-50/30">
                        <span className="px-3 py-1 font-black text-emerald-700 text-base">{r.score.toFixed(2)}</span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <Link href={`/muro-admin/karne/${r.id}`} target="_blank" className="inline-flex items-center justify-center gap-1.5 px-3 py-2 bg-white border border-slate-200 hover:border-blue-300 hover:bg-blue-50 text-blue-600 rounded-lg text-[11px] uppercase tracking-wider font-bold transition-all shadow-sm">
                          <FileText className="w-3.5 h-3.5" /> Karne İncele
                        </Link>
                      </td>
                    </tr>
                  );
                })}
                {calculatedResults.length === 0 && (
                  <tr>
                    <td colSpan={10} className="px-6 py-16 text-center">
                       <Users className="w-10 h-10 text-slate-300 mx-auto mb-3" />
                       <p className="text-slate-500 font-bold mb-1">Henüz Katılım Yok</p>
                       <p className="text-slate-400 text-xs">Bu sınavı tamamlayan hiçbir öğrenci bulunmuyor.</p>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* --- 2. İSTATİSTİKLER --- */}
        {activeTab === "STATS" && (
          <div className="p-8">
            {statsData ? (
               <div className="space-y-10">
                 <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                   <div className="p-5 bg-blue-50 border border-blue-100 rounded-2xl flex flex-col justify-center items-center">
                     <span className="text-xs font-bold text-blue-400 uppercase tracking-widest mb-1">Ortalama</span>
                     <span className="text-3xl font-black text-blue-700">{statsData.avgScore.toFixed(1)}</span>
                   </div>
                   <div className="p-5 bg-emerald-50 border border-emerald-100 rounded-2xl flex flex-col justify-center items-center">
                     <span className="text-xs font-bold text-emerald-400 uppercase tracking-widest mb-1">En Yüksek</span>
                     <span className="text-3xl font-black text-emerald-700">{statsData.maxScore.toFixed(1)}</span>
                   </div>
                   <div className="p-5 bg-rose-50 border border-rose-100 rounded-2xl flex flex-col justify-center items-center">
                     <span className="text-xs font-bold text-rose-400 uppercase tracking-widest mb-1">En Düşük</span>
                     <span className="text-3xl font-black text-rose-700">{statsData.minScore.toFixed(1)}</span>
                   </div>
                   <div className="p-5 bg-indigo-50 border border-indigo-100 rounded-2xl flex flex-col justify-center items-center">
                     <span className="text-xs font-bold text-indigo-400 uppercase tracking-widest mb-1">Medyan</span>
                     <span className="text-3xl font-black text-indigo-700">{statsData.median.toFixed(1)}</span>
                   </div>
                 </div>

                 <div className="bg-white border text-center border-slate-100 p-6 rounded-3xl shadow-sm">
                   <h3 className="text-lg font-bold text-slate-800 mb-6 flex items-center justify-center gap-2"><LineChart className="w-5 h-5 text-indigo-500"/> Puan Dağılım Çan Eğrisi (Yığılma)</h3>
                   <div className="h-[300px] w-full">
                     <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={statsData.chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                          <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748b', fontSize: 12}} />
                          <YAxis allowDecimals={false} axisLine={false} tickLine={false} tick={{fill: '#64748b', fontSize: 12}} />
                          <Tooltip 
                            cursor={{fill: '#f1f5f9'}}
                            contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)', fontWeight: 'bold', color: '#1e293b' }}
                            formatter={(val) => [`${val} Öğrenci`, 'Kişi Sayısı']}
                            labelFormatter={(label) => `${label} Puan Aralığı`}
                          />
                          <Bar dataKey="kisiSayisi" fill="#6366f1" radius={[6, 6, 0, 0]} barSize={40}>
                            {statsData.chartData.map((entry, index) => (
                              <Cell key={`cell-${index}`} fill={entry.kisiSayisi > Math.max(...statsData.chartData.map(d=>d.kisiSayisi))*0.8 ? "#4f46e5" : "#818cf8"} />
                            ))}
                          </Bar>
                        </BarChart>
                     </ResponsiveContainer>
                   </div>
                 </div>
               </div>
            ) : (
               <div className="text-center text-slate-400 py-10">İstatistik oluşturmak için yeterli veri yok.</div>
            )}
          </div>
        )}

        {/* --- 3. SORU VE MADDE ANALİZİ --- */}
        {activeTab === "ITEM_ANALYSIS" && (
           <div className="p-8">
              {itemAnalysisData.length > 0 ? (
                 <div className="space-y-6">
                    <p className="text-slate-500 font-medium mb-6">Her bir sorunun analizini, seçenek tercih oranlarını ve tespit edilen kafa karışıklıklarını aşağıdan inceleyebilirsiniz.</p>
                    
                    <div className="grid grid-cols-1 gap-4">
                      {itemAnalysisData.map((item: any, idx: number) => (
                         <div key={idx} className="bg-white border border-slate-200 rounded-2xl p-5 shadow-[0_2px_10px_rgba(0,0,0,0.02)] flex flex-col md:flex-row md:items-center gap-6">
                            
                            {/* Sol: Soru No ve Rozetler */}
                            <div className="flex flex-col md:w-48 shrink-0">
                               <div className="flex items-center gap-3 mb-2">
                                  <span className="text-2xl font-black text-slate-800">Soru {item.questionNumber}</span>
                                  <span className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase tracking-wider ${item.difficultyColor}`}>{item.difficulty}</span>
                               </div>
                               <span className="text-xs font-bold text-slate-400">Doğru: {item.correctOption} | Konu: {item.topic || 'Belirtilmemiş'}</span>
                            </div>

                            {/* Orta: Renkli Çubuk Haritası */}
                            <div className="flex-1 flex flex-col gap-2">
                               <div className="flex h-6 rounded-lg overflow-hidden border border-slate-200/50 bg-slate-50">
                                  {item.options.map((opt: any) => {
                                     const pct = item.stats.totalParticipants > 0 ? Math.round((opt.count / item.stats.totalParticipants) * 100) : 0;
                                     if (pct === 0) return null;
                                     
                                     // Renk Tespiti
                                     let bg = "bg-slate-300";
                                     if (opt.opt === item.correctOption) bg = "bg-emerald-500 shadow-[inset_0_0_10px_rgba(0,0,0,0.1)]"; // Doğru
                                     else if (opt.opt === item.strongDistractor) bg = "bg-rose-500/80"; // Güçlü Çeldirici
                                     else bg = "bg-slate-400"; // Standart Yanlış

                                     return (
                                       <div key={opt.opt} style={{ width: `${pct}%` }} className={`h-full ${bg} flex items-center justify-center overflow-hidden group relative cursor-help transition-all hover:brightness-110`}>
                                          <span className={`text-[10px] font-black text-white px-1 ${pct < 5 ? 'hidden' : 'block'}`}>{opt.opt}</span>
                                          {/* Tooltip Hover */}
                                          <div className="absolute opacity-0 group-hover:opacity-100 -top-8 left-1/2 -translate-x-1/2 bg-slate-800 text-white text-[10px] px-2 py-1 rounded font-bold whitespace-nowrap pointer-events-none z-10 transition-opacity">
                                            Şık {opt.opt}: %{pct} ({opt.count} kişi)
                                          </div>
                                       </div>
                                     );
                                  })}
                                  {item.stats.emptyCount > 0 && (
                                    <div 
                                      style={{ width: `${Math.round((item.stats.emptyCount / item.stats.totalParticipants) * 100)}%` }} 
                                      className="h-full bg-slate-100 flex items-center justify-center overflow-hidden border-l border-white group relative"
                                    >
                                      <span className="text-[10px] font-bold text-slate-400">Boş</span>
                                      <div className="absolute opacity-0 group-hover:opacity-100 -top-8 left-1/2 -translate-x-1/2 bg-slate-800 text-white text-[10px] px-2 py-1 rounded font-bold whitespace-nowrap pointer-events-none z-10">
                                        Boş: %{Math.round((item.stats.emptyCount / item.stats.totalParticipants) * 100)} ({item.stats.emptyCount} kişi)
                                      </div>
                                    </div>
                                  )}
                               </div>
                               <div className="flex gap-4 text-[10px] font-bold text-slate-500 uppercase tracking-wider">
                                  <span className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 bg-emerald-500 rounded-sm"></div> Doğru Cevap</span>
                                  <span className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 bg-slate-400 rounded-sm"></div> Diğer Seçenekler</span>
                                  <span className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 bg-slate-100 border border-slate-200 rounded-sm"></div> Boş</span>
                               </div>
                            </div>

                            {/* Sağ: İkaz / Analiz */}
                            <div className="md:w-64 shrink-0 border-l border-slate-100 pl-6 flex flex-col justify-center">
                               {item.isMisconception ? (
                                  <div className="flex gap-3 text-rose-600 bg-rose-50 p-3 rounded-xl border border-rose-100">
                                     <AlertTriangle className="w-6 h-6 shrink-0" />
                                     <div>
                                        <h4 className="text-xs font-black uppercase tracking-wider mb-0.5">Güçlü Çeldirici: {item.strongDistractor}</h4>
                                        <p className="text-[10px] font-medium opacity-80 leading-snug">Bu şık doğrulardan bile daha fazla seçilmiş. Kavram yanılgısı riski yüksek.</p>
                                     </div>
                                  </div>
                               ) : (
                                  <div className="flex items-center gap-2 text-slate-400">
                                     <div className="w-1.5 h-1.5 rounded-full bg-emerald-400"></div>
                                     <span className="text-xs font-bold">Riskli çeldirici bulunamadı. Soru dengeli işliyor.</span>
                                  </div>
                               )}
                            </div>

                         </div>
                      ))}
                    </div>

                 </div>
              ) : (
                 <div className="text-center text-slate-400 py-10">Seçenek cevaplarını eşleştirecek bir data bulunmuyor.</div>
              )}
           </div>
        )}

        {/* --- 4. GÜVENLİK RADARI --- */}
        {activeTab === "SECURITY" && (
           <div className="p-8">
             <div className="bg-amber-50 border border-amber-200 p-4 rounded-2xl flex gap-3 mb-6">
                <ShieldAlert className="w-6 h-6 text-amber-600 shrink-0" />
                <div>
                  <h3 className="font-bold text-amber-800">Sınav Güvenlik Logları (Sekme İhlalleri)</h3>
                  <p className="text-sm font-medium text-amber-700 opacity-80">Bu sekmeyi kullanarak sınav anında arka plana geçen, tam ekrandan çıkan veya şüpheli davranış sergileyen öğrencilerin loglarını inceleyebilirsiniz. En sık ihlal yapan öğrenci en üstte listelenir.</p>
                </div>
             </div>

             {securityStats.length > 0 ? (
                <div className="space-y-4">
                  {securityStats.map((statItem: any, idx: number) => (
                    <div key={idx} className="bg-white border flex flex-col border-slate-200 rounded-2xl overflow-hidden">
                       {/* Header */}
                       <div className="p-4 bg-slate-50 border-b border-slate-100 flex items-center justify-between">
                          <div className="flex items-center gap-3">
                             <div className="w-10 h-10 rounded-full bg-rose-100 text-rose-600 font-black flex items-center justify-center text-lg">{idx + 1}</div>
                             <div>
                               <h4 className="font-black text-slate-800">{statItem.user.name}</h4>
                               <p className="text-[11px] font-bold text-slate-400 uppercase">{statItem.user.email}</p>
                             </div>
                          </div>
                          <div className="bg-white px-3 py-1.5 rounded-lg font-black text-rose-600 border border-rose-100 text-sm shadow-sm flex items-center gap-1">
                             <EyeOff className="w-4 h-4"/> {statItem.actionCount} İhlal Tespit Edildi
                          </div>
                       </div>
                       {/* Table of logs */}
                       <div className="p-0">
                         <table className="w-full text-left text-xs bg-white">
                           <thead className="bg-[#f8fafc] text-slate-400 border-b border-slate-100">
                             <tr>
                               <th className="py-2 px-6 font-bold uppercase tracking-wider w-1/4">Tarih</th>
                               <th className="py-2 px-6 font-bold uppercase tracking-wider w-1/4">Eylem / Tür</th>
                               <th className="py-2 px-6 font-bold uppercase tracking-wider w-1/2">Sistem Detayları</th>
                             </tr>
                           </thead>
                           <tbody className="divide-y divide-slate-100">
                              {statItem.actions.map((act: any) => (
                                <tr key={act.id} className="hover:bg-slate-50 transition-colors">
                                   <td className="py-3 px-6 font-bold text-slate-500 whitespace-nowrap">{new Date(act.createdAt).toLocaleString('tr-TR')}</td>
                                   <td className="py-3 px-6"><span className="bg-rose-50 text-rose-600 px-2 py-0.5 rounded font-bold border border-rose-100 whitespace-nowrap">{
                                     act.actionType === "BLUR" ? "Odak Kaybı" :
                                     act.actionType === "FULLSCREEN_EXIT" ? "Ekrandan Çıkış" :
                                     act.actionType === "VISIBILITY_HIDDEN" ? "Sekme Gizleme" : act.actionType
                                   }</span></td>
                                   <td className="py-3 px-6 font-medium text-slate-500 truncate max-w-[200px]" title={act.details}>{act.details}</td>
                                </tr>
                              ))}
                           </tbody>
                         </table>
                       </div>
                    </div>
                  ))}
                </div>
             ) : (
                <div className="text-center text-slate-400 py-16 bg-slate-50 rounded-2xl border border-slate-100 border-dashed">
                   <ShieldAlert className="w-12 h-12 text-slate-300 mx-auto mb-3" />
                   <h4 className="font-bold text-slate-600 text-lg mb-1">Güvenlik Logu Bulunmuyor</h4>
                   <p className="text-sm">Öğrenciler bu sınavda şüpheli bir sekme değişimi yapmamış veya telemetri kaydı tutulmamıştır.</p>
                </div>
             )}
           </div>
        )}

      </div>
    </div>
  );
}
