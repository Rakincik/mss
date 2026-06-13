"use client";

import { useEffect, useState } from "react";
import { getAccountingStats, getRevenueChartData, refundTransaction } from "@/app/actions/accountingActions";
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell
} from "recharts";
import { TrendingUp, TrendingDown, DollarSign, ShoppingBag, Activity, Download, Calendar, Undo2, AlertCircle } from "lucide-react";
import { useToast } from "@/hooks/useToast";

export default function MuhasebeDashboard() {
  const { showToast } = useToast();
  const [stats, setStats] = useState<any>(null);
  const [chartData, setChartData] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [errorInfo, setErrorInfo] = useState<string | null>(null);
  const [period, setPeriod] = useState<"DAY" | "WEEK" | "MONTH" | "YEAR">("MONTH");
  const [startDate, setStartDate] = useState<string>("");
  const [endDate, setEndDate] = useState<string>("");
  const [isRefunding, setIsRefunding] = useState<string | null>(null);

  const loadData = async () => {
    setLoading(true);
    try {
      const startParam = startDate ? new Date(startDate).toISOString() : undefined;
      let endParam = undefined;
      if (endDate) {
        const d = new Date(endDate);
        d.setHours(23, 59, 59, 999);
        endParam = d.toISOString();
      }

      const [sData, cData] = await Promise.all([
        getAccountingStats(startParam, endParam),
        getRevenueChartData(period, startParam, endParam)
      ]);
      setStats(sData);
      setChartData(cData);
    } catch (err: any) {
      console.error("Muhasebe çekilirken hata:", err);
      setErrorInfo(err?.message || "Bilinmeyen bir hata oluştu.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [period, startDate, endDate]);

  const handleExportCSV = () => {
    if (!stats || !stats.recentTransactions) return;
    
    const headers = ["ID", "Tarih", "İşlem Türü", "Öğrenci Adı", "Öğrenci E-posta", "Tutar (TL)"];
    const rows = stats.recentTransactions.map((tx: any) => [
      tx.id,
      new Date(tx.createdAt).toLocaleString('tr-TR'),
      tx.reason === "GROUP_JOIN" ? "Grup Kaydı" : tx.reason === "EXAM_PURCHASE" ? "Sınav Satın Alımı" : tx.reason === "REFUND" ? "İade" : tx.reason,
      `"${tx.user.name}"`,
      tx.user.email,
      tx.amount
    ]);
    
    const csvContent = [
      headers.join(","),
      ...rows.map((r: any) => r.join(","))
    ].join("\n");
    
    const blob = new Blob(["\uFEFF" + csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `muro_muhasebe_raporu_${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleRefund = async (txId: string) => {
    if (!confirm("Bu işlemi iptal edip iade oluşturmak istediğinize emin misiniz? Bu işlem geri alınamaz ve bakiyeden düşülür.")) return;
    
    setIsRefunding(txId);
    try {
      const res = await refundTransaction(txId);
      if (res.success) {
        showToast("İade işlemi başarıyla oluşturuldu.", "success");
        loadData();
      } else {
        showToast("Hata: " + res.error, "error");
      }
    } catch (err: any) {
      showToast("Hata: " + err.message, "error");
    } finally {
      setIsRefunding(null);
    }
  };

  if (errorInfo) {
    return <div className="py-32 flex justify-center text-red-600 font-bold">Hata: {errorInfo}</div>;
  }

  if (loading || !stats) {
    return <div className="py-32 flex justify-center text-blue-600 font-bold">Finansal veriler derleniyor...</div>;
  }

  const isGrowthPositive = stats.revenueGrowth >= 0;

  return (
    <div className="max-w-6xl mx-auto space-y-8 text-slate-800">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold flex items-center gap-2 text-slate-900">
             <DollarSign className="w-8 h-8 text-emerald-600 p-1.5 bg-emerald-100 rounded-xl" />
             Finans ve Satış Analitiği
          </h1>
          <p className="text-slate-500 mt-2 text-sm max-w-lg">Sınav ve gruplardan elde edilen gelirleri, net kazanç kırılımlarını ve mali hareketleri bu panelden takip edebilirsiniz.</p>
        </div>
        <div className="flex items-center gap-3 bg-white p-2 rounded-2xl border border-slate-200 shadow-sm">
           <div className="flex items-center gap-2 px-3 border-r border-slate-100">
             <Calendar className="w-4 h-4 text-slate-400" />
             <input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} className="text-sm outline-none text-slate-600 font-medium bg-transparent" />
             <span className="text-slate-300">-</span>
             <input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} className="text-sm outline-none text-slate-600 font-medium bg-transparent" />
           </div>
           <button onClick={handleExportCSV} className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white text-sm font-bold rounded-xl flex items-center gap-2 transition-colors">
              <Download className="w-4 h-4" /> CSV İndir
           </button>
        </div>
      </div>

      {/* Top Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        
        <div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm relative overflow-hidden flex flex-col justify-between">
           <div className="absolute top-0 right-0 w-24 h-24 bg-emerald-50 rounded-full blur-xl -mr-10 -mt-10"></div>
           <div>
             <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 relative z-10">Brüt Toplam Ciro</p>
             <h2 className="text-3xl font-black text-slate-800 relative z-10">₺{stats.totalRevenue.toLocaleString("tr-TR")}</h2>
           </div>
           <div className="mt-4 pt-4 border-t border-slate-100 flex justify-between items-center relative z-10">
             <div>
               <p className="text-[10px] uppercase font-bold text-slate-400">Net Kazanç</p>
               <p className="text-sm font-black text-emerald-600">₺{(stats.totalRevenue * 0.8).toLocaleString("tr-TR")}</p>
             </div>
             <div>
               <p className="text-[10px] uppercase font-bold text-slate-400">Vergi (%20 KDV)</p>
               <p className="text-sm font-black text-rose-500">₺{(stats.totalRevenue * 0.2).toLocaleString("tr-TR")}</p>
             </div>
           </div>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm relative overflow-hidden">
           <div className="absolute top-0 right-0 w-24 h-24 bg-blue-50 rounded-full blur-xl -mr-10 -mt-10"></div>
           <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 relative z-10">Toplam Satış (Kayıt)</p>
           <h2 className="text-3xl font-black text-slate-800 relative z-10">{stats.totalSales} <span className="text-sm font-bold text-slate-500">Adet</span></h2>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm relative overflow-hidden">
           <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 relative z-10">Bu Ayki Gelir</p>
           <div className="flex items-end justify-between relative z-10">
              <h2 className="text-3xl font-black text-slate-800">₺{stats.currentMonthRevenue.toLocaleString("tr-TR")}</h2>
           </div>
        </div>

        <div className={`p-6 rounded-3xl border shadow-sm relative overflow-hidden flex flex-col justify-center ${isGrowthPositive ? 'bg-emerald-600 border-emerald-500 text-white' : 'bg-red-600 border-red-500 text-white'}`}>
           <p className={`text-xs font-bold uppercase tracking-widest mb-2 relative z-10 ${isGrowthPositive ? 'text-emerald-200' : 'text-red-200'}`}>Geçen Aya Kıyasla</p>
           <div className="flex items-center gap-2 relative z-10">
              {isGrowthPositive ? <TrendingUp className="w-8 h-8" /> : <TrendingDown className="w-8 h-8" />}
              <h2 className="text-3xl font-black">
                {isGrowthPositive ? '+' : ''}{Math.round(stats.revenueGrowth)}% 
              </h2>
           </div>
        </div>

      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* Ana Grafik */}
        <div className="lg:col-span-2 bg-white border border-slate-200 rounded-3xl p-6 shadow-sm">
          <div className="flex justify-between items-center mb-8">
             <h3 className="text-lg font-bold flex items-center gap-2">
               <Activity className="w-5 h-5 text-blue-600" />
               Zamansal Gelir Eğrisi
             </h3>
             <div className="flex bg-slate-100 p-1 rounded-xl">
               {["DAY", "MONTH", "YEAR"].map((p) => (
                 <button 
                   key={p}
                   onClick={() => setPeriod(p as any)}
                   className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-colors ${period === p ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}
                 >
                   {p === "DAY" ? "Günlük" : p === "MONTH" ? "Aylık" : "Yıllık"}
                 </button>
               ))}
             </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorGelir" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#2563eb" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#2563eb" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="date" tickLine={false} axisLine={false} tick={{fill: '#64748b', fontSize: 12}} dy={10} />
                <YAxis tickLine={false} axisLine={false} tick={{fill: '#64748b', fontSize: 12}} tickFormatter={(value) => `₺${value}`} />
                <Tooltip 
                   contentStyle={{ borderRadius: '16px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                   formatter={(value: any) => [`₺${Number(value || 0).toLocaleString()}`, 'Gelir']}
                />
                <Area type="monotone" dataKey="gelir" stroke="#2563eb" strokeWidth={3} fillOpacity={1} fill="url(#colorGelir)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Pasta Grafik - Ürün Dağılımı */}
        <div className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm flex flex-col">
           <h3 className="text-lg font-bold flex items-center gap-2 mb-6">
             <Activity className="w-5 h-5 text-indigo-600" />
             Ürün Bazlı Gelir Dağılımı
           </h3>
           <div className="flex-1 flex flex-col justify-center relative">
              {stats.productDistribution?.length > 0 ? (
                <>
                  <div className="h-48 w-full">
                    <ResponsiveContainer width="100%" height="100%">
                      <PieChart>
                        <Pie
                          data={stats.productDistribution}
                          cx="50%"
                          cy="50%"
                          innerRadius={60}
                          outerRadius={80}
                          paddingAngle={5}
                          dataKey="value"
                        >
                          {stats.productDistribution.map((entry: any, index: number) => {
                            const colors = ['#3b82f6', '#10b981', '#f59e0b', '#8b5cf6', '#ec4899'];
                            return <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />;
                          })}
                        </Pie>
                        <Tooltip formatter={(val: any) => `₺${Number(val || 0).toLocaleString()}`} />
                      </PieChart>
                    </ResponsiveContainer>
                  </div>
                  <div className="space-y-3 mt-4 h-32 overflow-y-auto custom-scrollbar pr-2">
                    {stats.productDistribution.map((prod: any, idx: number) => {
                      const colors = ['bg-blue-500', 'bg-emerald-500', 'bg-amber-500', 'bg-purple-500', 'bg-pink-500'];
                      return (
                        <div key={idx} className="flex items-center justify-between text-sm">
                          <div className="flex items-center gap-2">
                            <div className={`w-3 h-3 rounded-full ${colors[idx % colors.length]}`}></div>
                            <span className="text-slate-600 font-medium truncate max-w-[120px]" title={prod.name}>{prod.name}</span>
                          </div>
                          <span className="font-bold text-slate-800">₺{prod.value.toLocaleString()}</span>
                        </div>
                      );
                    })}
                  </div>
                </>
              ) : (
                <div className="text-center text-slate-400 py-10 text-sm font-medium">Pasta grafik için yeterli satış verisi bulunamadı.</div>
              )}
           </div>
        </div>

      </div>

      {/* Son Satışlar */}
      <div>
         <h3 className="text-xl font-bold flex items-center gap-2 mb-4">
            <ShoppingBag className="w-5 h-5 text-emerald-600" />
            Son İşlem ve Satışlar
         </h3>
         <div className="bg-white border border-slate-200 rounded-3xl overflow-hidden shadow-sm">
            {stats.recentTransactions.length === 0 ? (
               <div className="p-10 text-center text-slate-400 font-medium">Henüz muhasebe kaydı bulunmuyor.</div>
            ) : (
               <table className="w-full text-sm text-left">
                   <thead className="bg-slate-50 border-b border-slate-200 text-[10px] uppercase font-bold text-slate-500 tracking-widest">
                     <tr>
                       <th className="px-6 py-4">İşlem Özeti</th>
                       <th className="px-6 py-4">Öğrenci Kime Ait</th>
                       <th className="px-6 py-4 text-right">Tutar</th>
                       <th className="px-6 py-4 text-center">Aksiyon</th>
                     </tr>
                  </thead>
                  <tbody>
                     {stats.recentTransactions.map((tx: any) => (
                        <tr key={tx.id} className={`border-b border-slate-100 last:border-0 hover:bg-slate-50/50 ${tx.amount < 0 ? 'opacity-70 bg-rose-50/20' : ''}`}>
                           <td className="px-6 py-4">
                              <span className={`font-bold px-2 py-1 rounded-lg text-xs ml-2 ${tx.amount < 0 ? 'bg-rose-100 text-rose-600' : 'bg-slate-100 text-slate-600'}`}>
                                 {tx.reason === "GROUP_JOIN" ? "Grup Kaydı" : tx.reason === "EXAM_PURCHASE" ? "Sınav Satın Alımı" : tx.reason === "REFUND" ? "İADE İŞLEMİ" : tx.reason}
                              </span>
                              <span className="text-xs text-slate-400 ml-3">{new Date(tx.createdAt).toLocaleDateString('tr-TR', { day: '2-digit', month: 'long', hour: '2-digit', minute: '2-digit' })}</span>
                              {tx.amount > 0 && (tx.group?.name || tx.exam?.title) && (
                                <p className="text-[10px] text-slate-400 mt-1.5 ml-2 pl-2 border-l-2 border-slate-200">Ürün: {tx.group?.name || tx.exam?.title}</p>
                              )}
                           </td>
                           <td className="px-6 py-4 font-bold text-slate-700">
                             {tx.user.name} <span className="font-mono font-normal text-xs text-slate-400 ml-2">{tx.user.email}</span>
                           </td>
                           <td className="px-6 py-4 text-right">
                              <span className={`font-black text-base ${tx.amount < 0 ? 'text-rose-600' : 'text-emerald-600'}`}>
                                {tx.amount < 0 ? '' : '+'}₺{tx.amount.toLocaleString("tr-TR")}
                              </span>
                           </td>
                           <td className="px-6 py-4 text-center">
                              {tx.amount > 0 && (
                                <button 
                                  onClick={() => handleRefund(tx.id)}
                                  disabled={isRefunding === tx.id}
                                  className="px-3 py-1.5 bg-white border border-slate-200 hover:border-rose-300 hover:bg-rose-50 text-rose-600 text-xs font-bold rounded-lg inline-flex items-center gap-1.5 shadow-sm transition-colors disabled:opacity-50"
                                >
                                  {isRefunding === tx.id ? <Activity className="w-3.5 h-3.5 animate-spin" /> : <Undo2 className="w-3.5 h-3.5" />}
                                  İade Et
                                </button>
                              )}
                              {tx.amount < 0 && (
                                <span className="text-[10px] font-bold text-rose-500 uppercase tracking-widest flex items-center justify-center gap-1">
                                  <AlertCircle className="w-3 h-3" /> İade Edildi
                                </span>
                              )}
                           </td>
                        </tr>
                     ))}
                  </tbody>
               </table>
            )}
         </div>
      </div>

    </div>
  );
}
