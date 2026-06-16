import { getCurrentUserWithGroups, logoutUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import Link from "next/link";
import { BookOpen, Activity, PlaySquare, FileText, UserCircle2, LogOut, LayoutDashboard, Target } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function StudentPanelLayout({ children }: { children: React.ReactNode }) {
  const student = await getCurrentUserWithGroups();
  
  if (!student || student.role !== "STUDENT") {
    redirect("/login");
  }

  return (
    <div className="flex h-screen print:h-auto bg-slate-50 font-sans text-slate-800 overflow-hidden print:overflow-visible">
      {/* Sidebar */}
      <aside className="w-72 bg-white flex flex-col border-r border-slate-200 shrink-0 shadow-sm z-20 relative print:hidden">
        {/* Logo & Brand */}
        <div className="h-24 flex items-center px-8 shrink-0">
          <Link href="/ogrenci/dashboard" className="flex items-center gap-3 group">
            {process.env.NEXT_PUBLIC_LOGO_PATH && process.env.NEXT_PUBLIC_LOGO_PATH !== "/muro-logo.png" ? (
              <div className="w-10 h-10 flex items-center justify-center shrink-0">
                <img 
                  src={process.env.NEXT_PUBLIC_LOGO_PATH} 
                  alt="Kurum Logosu" 
                  className="max-w-full max-h-full object-contain"
                />
              </div>
            ) : (
              <div className="w-10 h-10 bg-blue-50 border border-blue-100 rounded-xl flex items-center justify-center text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition-all shadow-sm shrink-0">
                <BookOpen className="w-5 h-5" />
              </div>
            )}
            <div>
              <h1 className="text-xl font-black text-slate-800 tracking-tight leading-none">
                {process.env.NEXT_PUBLIC_SITE_NAME?.split(' ')[0] || 'Muro'} <span className="text-blue-700">Öğrenci</span>
              </h1>
              <p className="text-[10px] text-slate-500 font-mono tracking-widest uppercase mt-0.5">
                {process.env.NEXT_PUBLIC_SITE_NAME?.split(' ').slice(1).join(' ') || 'Sınav Sistemi'}
              </p>
            </div>
          </Link>
        </div>

        {/* Student Profile Overview */}
        <div className="px-6 mb-6">
          <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-600 flex items-center justify-center font-bold text-lg text-white shadow-md shadow-blue-600/20 border border-blue-500">
              {student.name?.charAt(0).toUpperCase() || "Ö"}
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="font-bold text-sm text-slate-900 truncate">{student.name}</h3>
              <p className="text-xs text-slate-500 flex items-center gap-1.5 mt-1">
                <Target className="w-3 h-3 text-emerald-500" /> {student.groups && student.groups.length > 0 ? student.groups.map((g: any) => g.name).join(", ") : "Kayıtsız"}
              </p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-4 space-y-1 overflow-y-auto custom-scrollbar pt-2">
          <div className="px-4 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Ana Menü</div>
          <Link 
            href="/ogrenci/dashboard" 
            className="flex items-center gap-3 px-4 py-3.5 rounded-xl text-sm font-semibold transition-all text-slate-600 hover:bg-blue-50 hover:text-blue-700 group"
          >
            <PlaySquare className="w-5 h-5 text-blue-500 group-hover:scale-110 transition-transform" />
            Aktif Sınavlarım
          </Link>
          <Link 
            href="/ogrenci/karneler" 
            className="flex items-center gap-3 px-4 py-3.5 rounded-xl text-sm font-semibold transition-all text-slate-600 hover:bg-emerald-50 hover:text-emerald-700 group"
          >
            <FileText className="w-5 h-5 text-emerald-500 group-hover:scale-110 transition-transform" />
            Geçmiş Karnelerim
          </Link>
          
          <div className="px-4 pt-6 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Hesap</div>
          <Link 
            href="/ogrenci/profil" 
            className="flex items-center gap-3 px-4 py-3.5 rounded-xl text-sm font-semibold transition-all text-slate-600 hover:bg-indigo-50 hover:text-indigo-700 group"
          >
            <UserCircle2 className="w-5 h-5 text-indigo-500 group-hover:scale-110 transition-transform" />
            Profil
          </Link>
        </nav>

        {/* Logout */}
        <div className="p-6 border-t border-slate-100 shrink-0">
          <form action={logoutUser} className="w-full">
            <button type="submit" className="w-full flex items-center justify-between px-4 py-3 text-sm font-bold text-red-500 bg-red-50 hover:bg-red-100 hover:text-red-700 rounded-xl transition-all group">
              <span className="flex items-center gap-3">
                <LogOut className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
                Güvenli Çıkış
              </span>
            </button>
          </form>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col bg-slate-50 print:bg-white relative overflow-y-auto print:overflow-visible">
        <div className="relative z-10 p-4 md:p-8 min-h-full">
          {children}
        </div>
      </main>
    </div>
  );
}
