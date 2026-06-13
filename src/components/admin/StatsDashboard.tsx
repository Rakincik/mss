"use client";

import { useState } from 'react';
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { Download, FileSpreadsheet, TrendingUp, Users, Target, Activity, Award, Search, ChevronLeft, ChevronRight } from 'lucide-react';
import * as XLSX from 'xlsx';

interface StatsDashboardProps {
  heroStats: {
    totalStudents: number;
    totalExams: number;
    totalParticipation: number;
    totalQuestionsSolved: number;
    averageScore: number;
  };
  trendData: { name: string; Katilim: number }[];
  rankings: { name: string; average: string; participants: number }[];
  leaderboard: { id: string; name: string; average: number; examsTaken: number; email: string }[];
  exams: { id: string; title: string; participants: number; average: number; difficulty: string; date: Date }[];
}

export function StatsDashboard({ heroStats, trendData, rankings, leaderboard, exams }: StatsDashboardProps) {

  const [searchTerm, setSearchTerm] = useState("");
  const [sortBy, setSortBy] = useState("newest");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  let filteredExams = exams.filter(e => e.title.toLowerCase().includes(searchTerm.toLowerCase()));
  
  // Sıralama mantığı
  filteredExams = filteredExams.sort((a, b) => {
    if (sortBy === "newest") return new Date(b.date).getTime() - new Date(a.date).getTime();
    if (sortBy === "oldest") return new Date(a.date).getTime() - new Date(b.date).getTime();
    if (sortBy === "highest_participation") return b.participants - a.participants;
    if (sortBy === "highest_average") return b.average - a.average;
    return 0;
  });

  const totalPages = Math.ceil(filteredExams.length / itemsPerPage);
  const currentExams = filteredExams.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

  const exportToExcel = () => {
    // Kurum Genel Özeti
    const summarySheet = XLSX.utils.json_to_sheet([{
      "Toplam Öğrenci": heroStats.totalStudents,
      "Toplam Sınav": heroStats.totalExams,
      "Sınavlara Toplam Katılım": heroStats.totalParticipation,
      "Çözülen Soru Hacmi": heroStats.totalQuestionsSolved,
      "Kurum Puan Ortalaması": heroStats.averageScore
    }]);

    // Sınav Listesi
    const examsSheet = XLSX.utils.json_to_sheet(exams.map(e => ({
      "Sınav Adı": e.title,
      "Tarih": new Date(e.date).toLocaleDateString("tr-TR"),
      "Katılımcı": e.participants,
      "Ortalama Puan": e.average,
      "Zorluk Etiketi": e.difficulty
    })));

    // Onur Tablosu
    const leaderSheet = XLSX.utils.json_to_sheet(leaderboard.map((l, index) => ({
      "Sıra": index + 1,
      "Öğrenci Adı": l.name,
      "E-Posta": l.email,
      "Girdiği Sınav": l.examsTaken,
      "Genel Ortalama": l.average
    })));

    const wb = XLSX.utils.book_new();

    // Kolon Genişlikleri Ekle
    summarySheet['!cols'] = [{wch: 18}, {wch: 15}, {wch: 25}, {wch: 22}, {wch: 22}];
    examsSheet['!cols'] = [{wch: 40}, {wch: 15}, {wch: 15}, {wch: 15}, {wch: 15}];
    leaderSheet['!cols'] = [{wch: 8}, {wch: 25}, {wch: 30}, {wch: 15}, {wch: 15}];

    XLSX.utils.book_append_sheet(wb, summarySheet, "Kurum Özeti");
    XLSX.utils.book_append_sheet(wb, examsSheet, "Sınav Karneleri");
    XLSX.utils.book_append_sheet(wb, leaderSheet, "Onur Tablosu");

    XLSX.writeFile(wb, `Kurum_Raporu_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

  return (
    <div className="space-y-6">
      
      {/* YAZDIRMA (PRINT) İÇİN GİZLİ BAŞLIK */}
      <div className="hidden print:block mb-8 text-center border-b pb-4">
        <h1 className="text-3xl font-black text-gray-900">Kurum Sınav İstatistik Raporu</h1>
        <p className="text-gray-500 mt-2">Rapor Tarihi: {new Date().toLocaleDateString('tr-TR')}</p>
      </div>

      {/* BAŞLIK & İHRACAT */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 bg-white/70 backdrop-blur-xl p-5 rounded-2xl border border-gray-100 shadow-sm print:hidden">
        <div>
          <h1 className="text-2xl font-black text-gray-900 tracking-tight">Kurum Sınav İstatistikleri</h1>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={exportToExcel}
            className="flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded-xl text-sm font-semibold transition-all shadow-md hover:shadow-lg"
          >
            <FileSpreadsheet className="w-4 h-4" /> Excel Raporu İndir
          </button>
          <button 
            onClick={() => window.print()}
            className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-xl text-sm font-semibold transition-all shadow-md hover:shadow-lg"
          >
            <Download className="w-4 h-4" /> PDF Olarak Yazdır
          </button>
        </div>
      </div>

      {/* TEPE METRİKLER (Hero Stats) - Glassmorphism */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { title: "Aktif Öğrenci", value: heroStats.totalStudents, icon: Users, color: "text-blue-600", bg: "bg-blue-50" },
          { title: "Çözülen Soru", value: heroStats.totalQuestionsSolved.toLocaleString(), icon: Target, color: "text-purple-600", bg: "bg-purple-50" },
          { title: "Toplam Katılım", value: heroStats.totalParticipation, icon: Activity, color: "text-emerald-600", bg: "bg-emerald-50" },
          { title: "Kurum Ortalaması", value: heroStats.averageScore, icon: TrendingUp, color: "text-orange-600", bg: "bg-orange-50" }
        ].map((stat, i) => (
          <div key={i} className="bg-white/80 backdrop-blur-md p-6 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4 hover:scale-[1.02] transition-transform">
            <div className={`p-4 rounded-xl ${stat.bg} ${stat.color}`}>
              <stat.icon className="w-8 h-8" />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-500">{stat.title}</p>
              <h3 className="text-2xl font-bold text-gray-900">{stat.value}</h3>
            </div>
          </div>
        ))}
      </div>

      {/* GRAFİKLER BÖLÜMÜ */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 print:block">
        
        {/* Trend Grafiği */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm print:break-inside-avoid">
          <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-blue-500" /> Sınav Katılım Trendi (Aylık)
          </h3>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={trendData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  cursor={{stroke: '#e2e8f0', strokeWidth: 2}}
                  formatter={(val: any) => [val, 'Katılım']}
                />
                <Line 
                  type="monotone" 
                  dataKey="Katilim" 
                  stroke="#3b82f6" 
                  strokeWidth={4} 
                  dot={{r: 6, fill: '#3b82f6', strokeWidth: 3, stroke: '#fff'}} 
                  activeDot={{r: 8}}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Şube Rekabeti */}
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm print:break-inside-avoid">
          <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
            <Award className="w-5 h-5 text-purple-500" /> Şubeler Arası Başarı Rekabeti (Ortalama Puan)
          </h3>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={rankings} layout="vertical" margin={{ left: 40 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" />
                <XAxis type="number" axisLine={false} tickLine={false} tick={{fill: '#64748b'}} />
                <YAxis dataKey="name" type="category" axisLine={false} tickLine={false} tick={{fill: '#475569', fontWeight: 600}} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  cursor={{fill: '#f8fafc'}}
                  formatter={(val: any) => [val, 'Ortalama Puan']}
                />
                <Bar dataKey="average" radius={[0, 6, 6, 0]}>
                  {rankings.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* ALT TABLOLAR */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 print:block">
        
        {/* Onur Tablosu (İlk 10) */}
        <div className="lg:col-span-1 bg-white p-6 rounded-2xl border border-gray-100 shadow-sm print:break-inside-avoid">
          <h3 className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
            <Award className="w-5 h-5 text-amber-500" /> Kurum Onur Tablosu (İlk 10)
          </h3>
          <div className="space-y-4">
            {leaderboard.length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-4">Henüz yeterli veri yok.</p>
            ) : leaderboard.map((l, i) => (
              <div key={l.id} className="flex items-center justify-between p-3 rounded-xl bg-gray-50/50 border border-gray-100 hover:bg-gray-100 transition-colors">
                <div className="flex items-center gap-3">
                  <span className={`flex items-center justify-center w-8 h-8 rounded-full font-bold text-sm ${
                    i === 0 ? 'bg-amber-100 text-amber-600' : 
                    i === 1 ? 'bg-gray-200 text-gray-600' : 
                    i === 2 ? 'bg-orange-100 text-orange-600' : 'bg-blue-50 text-blue-600'
                  }`}>
                    {i + 1}
                  </span>
                  <div>
                    <p className="font-semibold text-gray-800 text-sm">{l.name}</p>
                    <p className="text-xs text-gray-500">{l.examsTaken} Sınav</p>
                  </div>
                </div>
                <div className="text-right">
                  <span className="font-bold text-blue-600">{l.average.toFixed(1)}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Yapılan Sınavların Karnesi */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl border border-gray-100 shadow-sm print:break-inside-avoid">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-4 gap-4">
            <h3 className="text-lg font-bold text-gray-800 flex items-center gap-2">
              <FileSpreadsheet className="w-5 h-5 text-emerald-500" /> Kurum Başarı Tablosu
            </h3>
            <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto print:hidden">
              <select 
                className="block w-full sm:w-48 pl-3 pr-10 py-2 text-sm border border-gray-200 rounded-xl focus:ring-blue-500 focus:border-blue-500 bg-gray-50/50 appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23131313%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:12px_12px] bg-[right_12px_center] bg-no-repeat"
                value={sortBy}
                onChange={(e) => { setSortBy(e.target.value); setCurrentPage(1); }}
              >
                <option value="newest">En Yeni Eklenenler</option>
                <option value="oldest">En Eski Eklenenler</option>
                <option value="highest_participation">Katılımı Yüksek Olanlar</option>
                <option value="highest_average">Ortalaması Yüksek Olanlar</option>
              </select>
              <div className="relative w-full sm:w-56">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Search className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="text"
                  className="block w-full pl-10 pr-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-blue-500 focus:border-blue-500 bg-gray-50/50"
                  placeholder="Sınav ara..."
                  value={searchTerm}
                  onChange={(e) => { setSearchTerm(e.target.value); setCurrentPage(1); }}
                />
              </div>
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-gray-600">
              <thead className="bg-gray-50 text-gray-700 uppercase text-xs">
                <tr>
                  <th className="px-4 py-3 rounded-l-lg">Sınav Adı</th>
                  <th className="px-4 py-3">Tarih</th>
                  <th className="px-4 py-3 text-center">Katılım</th>
                  <th className="px-4 py-3 text-center">Ortalama</th>
                  <th className="px-4 py-3 rounded-r-lg text-center">Zorluk</th>
                </tr>
              </thead>
              <tbody>
                {currentExams.length === 0 ? (
                  <tr><td colSpan={5} className="text-center py-6">Sonuç bulunamadı.</td></tr>
                ) : currentExams.map((exam) => (
                  <tr key={exam.id} className="border-b border-gray-50 last:border-0 hover:bg-gray-50/50">
                    <td className="px-4 py-3 font-medium text-gray-900">{exam.title}</td>
                    <td className="px-4 py-3 text-xs">{new Date(exam.date).toLocaleDateString("tr-TR")}</td>
                    <td className="px-4 py-3 text-center font-semibold">{exam.participants}</td>
                    <td className="px-4 py-3 text-center font-bold text-blue-600">{exam.average}</td>
                    <td className="px-4 py-3 text-center">
                      <span className={`px-2 py-1 text-xs rounded-full font-medium ${
                        exam.difficulty === 'Zor' ? 'bg-red-100 text-red-600' :
                        exam.difficulty === 'Kolay' ? 'bg-emerald-100 text-emerald-600' :
                        exam.difficulty === '-' ? 'bg-gray-100 text-gray-600' :
                        'bg-amber-100 text-amber-600'
                      }`}>
                        {exam.difficulty}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          
          {totalPages > 1 && (
            <div className="flex items-center justify-between mt-4 px-2 print:hidden">
              <span className="text-sm text-gray-500">
                Toplam <strong>{filteredExams.length}</strong> sınav
              </span>
              <div className="flex gap-1">
                <button 
                  disabled={currentPage === 1}
                  onClick={() => setCurrentPage(p => p - 1)}
                  className="p-1.5 rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-50"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
                <button 
                  disabled={currentPage === totalPages}
                  onClick={() => setCurrentPage(p => p + 1)}
                  className="p-1.5 rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-50"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          )}
        </div>

      </div>
    </div>
  );
}
