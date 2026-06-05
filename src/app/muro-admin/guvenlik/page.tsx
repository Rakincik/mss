"use client";

import { useState, useEffect } from "react";
import { ShieldAlert, Trash2, AlertTriangle, ScreenShare, Presentation, Clock, Maximize, MousePointerClick, CopyX } from "lucide-react";
import { getSecurityLogs, deleteLog, clearAllLogs } from "@/app/actions/logActions";

export default function GuvenlikPage() {
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [pageSize, setPageSize] = useState(25);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [totalPages, setTotalPages] = useState(1);

  const fetchData = async () => {
    setLoading(true);
    const data = await getSecurityLogs(currentPage, pageSize);
    setLogs(data.logs);
    setTotalCount(data.totalCount);
    setTotalPages(data.totalPages);
    setLoading(false);
  };

  useEffect(() => {
    fetchData();
  }, [currentPage, pageSize]);

  const getActionBadge = (type: string) => {
    switch (type) {
      case "BLUR":
        return <span className="flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 text-amber-600 border border-amber-200 rounded-lg text-[10px] font-bold tracking-widest"><ScreenShare className="w-3.5 h-3.5" /> SEKMEYİ TERK ETTİ</span>;
      case "PRINT_SCREEN":
        return <span className="flex items-center gap-1.5 px-3 py-1.5 bg-red-50 text-red-600 border border-red-200 rounded-lg text-[10px] font-bold tracking-widest"><Presentation className="w-3.5 h-3.5" /> EKRAN GÖRÜNTÜSÜ</span>;
      case "DEVTOOLS_OPEN":
        return <span className="flex items-center gap-1.5 px-3 py-1.5 bg-purple-50 text-purple-600 border border-purple-200 rounded-lg text-[10px] font-bold tracking-widest"><AlertTriangle className="w-3.5 h-3.5" /> GELİŞTİRİCİ ARAÇLARI</span>;
      case "FULLSCREEN_EXIT":
        return <span className="flex items-center gap-1.5 px-3 py-1.5 bg-rose-50 text-rose-600 border border-rose-200 rounded-lg text-[10px] font-bold tracking-widest"><Maximize className="w-3.5 h-3.5" /> TAM EKRANDAN ÇIKTI</span>;
      case "MOUSE_LEAVE":
        return <span className="flex items-center gap-1.5 px-3 py-1.5 bg-yellow-50 text-yellow-600 border border-yellow-300 rounded-lg text-[10px] font-bold tracking-widest"><MousePointerClick className="w-3.5 h-3.5" /> FARE EKRANDAN ÇIKTI</span>;
      case "COPY_ATTEMPT":
        return <span className="flex items-center gap-1.5 px-3 py-1.5 bg-neutral-100 text-neutral-800 border border-neutral-300 rounded-lg text-[10px] font-bold tracking-widest"><CopyX className="w-3.5 h-3.5" /> KOPYALAMA GİRİŞİMİ</span>;
      default:
        return <span className="px-3 py-1.5 bg-slate-100 text-slate-600 rounded-lg text-[10px] font-bold tracking-widest">{type || "ŞÜPHELİ HAREKET"}</span>;
    }
  };

  return (
    <div className="max-w-6xl mx-auto text-slate-800 space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2 text-slate-800">
            <ShieldAlert className="w-8 h-8 text-rose-500" /> Güvenlik Logları
          </h1>
          <p className="text-slate-500 mt-2 text-sm">Öğrencilerin sınav sırasındaki ihlalleri, sekme değiştirmeleri ve kopya girişimleri.</p>
        </div>
        
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 bg-white px-4 py-2 border border-slate-200 rounded-xl shadow-sm">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-widest">Göster:</span>
            <select 
              value={pageSize} 
              onChange={(e) => {
                setPageSize(Number(e.target.value));
                setCurrentPage(1);
              }}
              className="bg-slate-50 border border-slate-200 text-slate-700 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block px-2.5 py-1 font-semibold outline-none cursor-pointer"
            >
              <option value="25">25 Log</option>
              <option value="50">50 Log</option>
              <option value="100">100 Log</option>
            </select>
          </div>

          {totalCount > 0 && (
            <button 
              onClick={async () => {
                if (confirm("Tüm güvenlik loglarını kalıcı olarak silmek istediğinize emin misiniz?")) {
                  await clearAllLogs();
                  setCurrentPage(1);
                  fetchData();
                }
              }}
              className="flex items-center gap-2 px-5 py-2.5 bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 rounded-xl transition-colors font-bold text-sm shadow-sm"
            >
              <Trash2 className="w-4 h-4" /> Tümünü Temizle
            </button>
          )}
        </div>
      </div>

      {loading ? (
        <div className="py-20 text-center text-slate-400 font-medium">Loglar yükleniyor...</div>
      ) : (
        <div className="space-y-4">
          <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm">
            <table className="w-full text-sm text-left">
              <thead className="text-[10px] text-slate-500 uppercase tracking-widest bg-slate-50 border-b border-slate-200">
                <tr>
                  <th className="px-6 py-4 font-bold">Tarih / Saat</th>
                  <th className="px-6 py-4 font-bold">Öğrenci</th>
                  <th className="px-6 py-4 font-bold">Sınav</th>
                  <th className="px-6 py-4 font-bold">İhlal Türü</th>
                  <th className="px-6 py-4 font-bold">Detaylar</th>
                  <th className="px-6 py-4 text-right font-bold">İşlem</th>
                </tr>
              </thead>
              <tbody>
                {logs.map(log => (
                  <tr key={log.id} className="border-b border-slate-100 hover:bg-slate-50/80 transition-colors">
                    <td className="px-6 py-4 text-slate-500 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4 text-slate-400" />
                        <span className="font-semibold text-xs text-slate-600">{new Date(log.createdAt).toLocaleString("tr-TR")}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-bold text-slate-800">{log.user.name}</div>
                      <div className="text-[11px] text-slate-500 font-mono mt-0.5">{log.user.email}</div>
                    </td>
                    <td className="px-6 py-4 font-bold text-blue-600 truncate max-w-[200px]" title={log.exam.title}>
                      {log.exam.title}
                    </td>
                    <td className="px-6 py-4">
                      {getActionBadge(log.actionType)}
                    </td>
                    <td className="px-6 py-4 text-slate-500 text-xs font-medium">
                      {log.details || "-"}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button 
                        onClick={async () => { 
                          await deleteLog(log.id); 
                          fetchData(); 
                        }} 
                        title="Logu Sil"
                        className="p-2 bg-white hover:bg-rose-50 text-slate-400 hover:text-rose-600 rounded-lg transition-colors ml-auto border border-slate-200 hover:border-rose-200 shadow-sm"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
                {logs.length === 0 && (
                  <tr>
                    <td colSpan={6} className="px-6 py-16 text-center text-slate-500 bg-slate-50 text-sm font-medium">
                      Sistemde henüz kaydedilmiş bir güvenlik ihlali bulunmuyor. Her şey yolunda! 🛡️
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
          
          {/* Sayfalama Kontrolleri */}
          {totalCount > 0 && (
            <div className="flex items-center justify-between text-sm text-slate-500">
              <span className="font-medium">
                Sistemde toplam <strong className="text-slate-800">{totalCount}</strong> güvenlik logu var.
              </span>
              {totalPages > 1 && (
                <div className="flex gap-2">
                  <button 
                    onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                    className="px-4 py-2 border border-slate-200 bg-white hover:bg-slate-50 disabled:opacity-50 transition rounded-xl font-bold"
                  >
                    Önceki
                  </button>
                  <div className="px-4 py-2 border border-slate-200 bg-slate-50 font-bold text-slate-800 rounded-xl">
                    {currentPage} / {totalPages}
                  </div>
                  <button 
                    onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                    disabled={currentPage === totalPages}
                    className="px-4 py-2 border border-slate-200 bg-white hover:bg-slate-50 disabled:opacity-50 transition rounded-xl font-bold"
                  >
                    Sonraki
                  </button>
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
