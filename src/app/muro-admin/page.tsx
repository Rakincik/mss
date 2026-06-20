import { Activity, Users, BookOpen, ShieldAlert, Sparkles, TrendingUp, Clock } from "lucide-react";
import { getCurrentUser } from "@/app/actions/authActions";
import { prisma } from "@/lib/prisma";
import Link from "next/link";
import { DashboardCharts } from "@/components/admin/DashboardCharts";

export const dynamic = "force-dynamic";

export default async function AdminDashboard() {
  const currentUser = await getCurrentUser();
  const whereClause: any = {};
  if (currentUser?.role !== "SUPERADMIN" && currentUser?.institutionId) {
    whereClause.institutionId = currentUser.institutionId;
  }
  
  // Güvenlik logları için where
  const whereLogClause: any = {};
  if (currentUser?.role !== "SUPERADMIN" && currentUser?.institutionId) {
    whereLogClause.exam = { institutionId: currentUser.institutionId };
  }
  else if (currentUser?.role !== "SUPERADMIN") {
    // ADMIN but no institutionId (fallback)
    whereLogClause.exam = { institutionId: null };
  }

  // Gerçek veriler — paralel sorgular
  const [examCount, activeStudentCount, passiveStudentCount, logCount, recentExams, recentLogs] = await Promise.all([
    prisma.exam.count({ where: { isActive: true, ...whereClause } }),
    prisma.user.count({ where: { role: "STUDENT", isActive: true, ...whereClause } }),
    prisma.user.count({ where: { role: "STUDENT", isActive: false, ...whereClause } }),
    prisma.securityLog.count({ where: whereLogClause }),
    prisma.exam.findMany({
      where: whereClause,
      orderBy: { createdAt: "desc" },
      take: 5,
      select: { id: true, title: true, isActive: true, createdAt: true, questionCount: true, _count: { select: { results: true } } }
    }),
    prisma.securityLog.findMany({
      where: whereLogClause,
      orderBy: { createdAt: "desc" },
      take: 5,
      select: {
        id: true,
        actionType: true,
        createdAt: true,
        user: { select: { name: true } }
      }
    })
  ]);

  const formatTimeAgo = (date: Date) => {
    const mins = Math.floor((Date.now() - new Date(date).getTime()) / 60000);
    if (mins < 1) return "Şimdi";
    if (mins < 60) return `${mins} dk önce`;
    if (mins < 1440) return `${Math.floor(mins / 60)} saat önce`;
    return `${Math.floor(mins / 1440)} gün önce`;
  };

  const actionLabels: Record<string, string> = {
    BLUR: "Sekme Değiştirdi",
    PRINT_SCREEN: "Ekran Görüntüsü",
    COPY_ATTEMPT: "Kopyalama Denemesi",
    DEVTOOLS_OPEN: "Geliştirici Araçları",
    FOCUS: "Geri Döndü",
    KEYBOARD_SHORTCUT: "Kısayol Denemesi",
  };

  return (
    <div className="max-w-6xl mx-auto space-y-8 text-slate-800">
      
      {/* Stats Grid — GERÇEK VERİLER */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: "Aktif Sınavlar", value: examCount.toString(), icon: BookOpen, color: "text-blue-600", bg: "bg-blue-100", cardBg: "from-blue-50/50 to-white" },
          { label: "Aktif Öğrenci", value: activeStudentCount.toLocaleString("tr-TR"), icon: Users, color: "text-cyan-600", bg: "bg-cyan-100", cardBg: "from-cyan-50/50 to-white" },
          { label: "Pasif Öğrenci", value: passiveStudentCount.toLocaleString("tr-TR"), icon: Users, color: "text-slate-600", bg: "bg-slate-100", cardBg: "from-slate-50/50 to-white" },
          { label: "Güvenlik Kayıtları", value: logCount.toLocaleString("tr-TR"), icon: ShieldAlert, color: "text-rose-600", bg: "bg-rose-100", cardBg: "from-rose-50/50 to-white" },
        ].map((stat, i) => (
          <div key={i} className={`p-5 bg-gradient-to-br ${stat.cardBg} border border-slate-200 rounded-2xl shadow-sm hover:shadow-md transition-shadow group cursor-default`}>
            <div className="flex items-start justify-between mb-3">
              <div className={`p-2.5 rounded-xl ${stat.bg} ${stat.color}`}>
                <stat.icon className="w-5 h-5" />
              </div>
              <TrendingUp className="w-4 h-4 text-slate-300 group-hover:text-slate-400 transition-colors" />
            </div>
            <div>
              <h3 className="text-3xl font-bold text-slate-800">{stat.value}</h3>
              <p className="text-xs font-medium text-slate-500 mt-1">{stat.label}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Dinamik Veri Grafikleri */}
      <DashboardCharts examsData={recentExams.map(e => ({ title: e.title, results: e._count.results }))} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Son Eklenen Sınavlar — GERÇEK VERİLER */}
        <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-6 text-slate-800">
             <BookOpen className="w-5 h-5 text-blue-500" />
             <h2 className="text-lg font-bold">Son Eklenen Sınavlar</h2>
          </div>
          <div className="space-y-3">
            {recentExams.length === 0 ? (
              <p className="text-slate-400 text-sm text-center py-6">Henüz sınav eklenmemiş.</p>
            ) : recentExams.map(exam => (
              <Link key={exam.id} href={`/muro-admin/sinavlar/${exam.id}`} className="flex items-center justify-between p-4 bg-slate-50 hover:bg-slate-100 transition-colors rounded-xl border border-slate-100 group">
                <div>
                  <h4 className="font-bold text-slate-800 text-sm group-hover:text-blue-600 transition-colors">{exam.title}</h4>
                  <p className="text-[11px] font-semibold text-slate-500 mt-0.5">{new Date(exam.createdAt).toLocaleDateString("tr-TR")} · {exam.questionCount} Soru · {exam._count.results} Katılımcı</p>
                </div>
                <span className={`px-3 py-1 rounded-lg text-[10px] font-bold uppercase tracking-wider ${
                  exam.isActive 
                    ? 'bg-emerald-100 text-emerald-700 border border-emerald-200' 
                    : 'bg-slate-200 text-slate-600 border border-slate-300'
                }`}>
                  {exam.isActive ? 'Aktif' : 'Pasif'}
                </span>
              </Link>
            ))}
          </div>
        </div>

        {/* Son Güvenlik İhlalleri — GERÇEK VERİLER */}
        <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-2 text-slate-800">
               <ShieldAlert className="w-5 h-5 text-rose-500" />
               <h2 className="text-lg font-bold">Son Güvenlik İhlalleri</h2>
            </div>
            <Link href="/muro-admin/guvenlik" className="text-[10px] text-red-600 font-bold bg-red-50 border border-red-100 px-3 py-1 rounded-lg flex items-center gap-1.5 uppercase tracking-wider hover:bg-red-100 transition-colors">
               <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span> Tümünü Gör
            </Link>
          </div>
          <div className="space-y-3">
            {recentLogs.length === 0 ? (
              <p className="text-slate-400 text-sm text-center py-6">Henüz güvenlik kaydı yok.</p>
            ) : recentLogs.map(log => (
              <div key={log.id} className="flex font-mono items-center gap-4 text-xs p-3.5 bg-rose-50/30 hover:bg-rose-50 transition-colors border border-rose-100 rounded-xl">
                <span className="text-slate-500 font-semibold w-16 shrink-0">{formatTimeAgo(log.createdAt)}</span>
                <span className="font-bold text-slate-800 w-24 truncate">{log.user?.name || "Bilinmiyor"}</span>
                <span className="text-rose-600 font-semibold flex-1">{actionLabels[log.actionType] || log.actionType}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
