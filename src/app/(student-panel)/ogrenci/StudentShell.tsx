"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookOpen, PlaySquare, FileText, UserCircle2, LogOut, Menu, X, Target } from "lucide-react";
import { ReactNode, useState } from "react";
import { logoutUser } from "@/app/actions/authActions";

interface StudentShellProps {
  children: ReactNode;
  student: any;
}

export default function StudentShell({ children, student }: StudentShellProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const pathname = usePathname();

  const NavItem = ({ href, icon: Icon, label, color }: any) => {
    const isActive = pathname === href || pathname?.startsWith(href + '/');
    const activeBgClass = color.replace('text-', 'bg-').replace('500', '50');
    const activeTextClass = color.replace('500', '700');

    return (
      <Link 
        href={href} 
        onClick={() => setSidebarOpen(false)} 
        className={`flex items-center gap-3 px-4 py-3.5 rounded-xl text-sm font-semibold transition-all group ${
          isActive 
            ? `${activeBgClass} ${activeTextClass}` 
            : `text-slate-600 hover:${activeBgClass} hover:${activeTextClass}`
        }`}
      >
        <Icon className={`w-5 h-5 transition-transform ${isActive ? color : `text-slate-400 group-hover:scale-110 group-hover:${color}`}`} />
        {label}
      </Link>
    );
  };

  return (
    <div className="flex h-screen print:h-auto bg-slate-50 font-sans text-slate-800 overflow-hidden print:overflow-visible">
      
      {/* Mobile Overlay */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`fixed lg:static inset-y-0 left-0 z-50 w-72 bg-white flex flex-col border-r border-slate-200 shrink-0 shadow-sm transform transition-transform duration-300 ease-in-out print:hidden ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
        
        {/* Logo & Brand */}
        <div className="h-20 flex items-center justify-between px-6 shrink-0 border-b border-slate-100">
          <Link href="/ogrenci/dashboard" className="flex items-center gap-3 group w-full max-w-[240px]">
            {process.env.NEXT_PUBLIC_LOGO_PATH && process.env.NEXT_PUBLIC_LOGO_PATH !== "/muro-logo.png" ? (
              <img 
                src={process.env.NEXT_PUBLIC_LOGO_PATH} 
                alt="Kurum Logosu" 
                className="h-16 w-auto max-w-full object-contain"
              />
            ) : (
              <>
                <div className="w-10 h-10 bg-blue-50 border border-blue-100 rounded-xl flex items-center justify-center text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition-all shadow-sm shrink-0">
                  <BookOpen className="w-5 h-5" />
                </div>
                <div>
                  <h1 className="text-xl font-black text-slate-800 tracking-tight leading-none">
                    {process.env.NEXT_PUBLIC_SITE_NAME?.split(' ')[0] || 'Muro'} <span className="text-blue-700">Öğrenci</span>
                  </h1>
                  <p className="text-[10px] text-slate-500 font-mono tracking-widest uppercase mt-0.5">
                    {process.env.NEXT_PUBLIC_SITE_NAME?.split(' ').slice(1).join(' ') || 'Sınav Sistemi'}
                  </p>
                </div>
              </>
            )}
          </Link>
          <button 
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Student Profile Overview */}
        <div className="px-6 my-6">
          <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-blue-600 flex items-center justify-center font-bold text-lg text-white shadow-md shadow-blue-600/20 border border-blue-500 shrink-0">
              {student.name?.charAt(0).toUpperCase() || "Ö"}
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="font-bold text-sm text-slate-900 truncate">{student.name}</h3>
              <p className="text-xs text-slate-500 flex items-center gap-1.5 mt-1">
                <Target className="w-3 h-3 text-emerald-500 shrink-0" /> 
                <span className="truncate">{student.groups && student.groups.length > 0 ? student.groups.map((g: any) => g.name).join(", ") : "Kayıtsız"}</span>
              </p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-4 space-y-1 overflow-y-auto custom-scrollbar">
          <div className="px-4 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Ana Menü</div>
          <NavItem href="/ogrenci/dashboard" icon={PlaySquare} label="Aktif Sınavlarım" color="text-blue-500" />
          <NavItem href="/ogrenci/karneler" icon={FileText} label="Geçmiş Karnelerim" color="text-emerald-500" />
          
          <div className="px-4 pt-6 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Hesap</div>
          <NavItem href="/ogrenci/profil" icon={UserCircle2} label="Profil" color="text-indigo-500" />
        </nav>

        {/* Logout */}
        <div className="absolute bottom-0 w-full p-4 border-t border-slate-100 bg-white group">
          <button 
            type="button" 
            onClick={async () => { await logoutUser(); window.location.href = "/login"; }} 
            className="w-full flex items-center gap-3 px-4 py-3 text-sm font-bold text-rose-600 hover:text-rose-700 hover:bg-rose-50 rounded-2xl transition-all"
          >
            <div className="w-10 h-10 rounded-xl bg-rose-50 group-hover:bg-rose-100 flex items-center justify-center transition-colors">
              <LogOut className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
            </div>
            <span>Güvenli Çıkış</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 flex flex-col bg-slate-50 print:bg-white relative overflow-y-auto print:overflow-visible">
        
        {/* Mobile Header */}
        <header className="lg:hidden h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 shrink-0 z-10 print:hidden">
          <div className="flex items-center gap-3 w-full max-w-[240px]">
            {process.env.NEXT_PUBLIC_LOGO_PATH && process.env.NEXT_PUBLIC_LOGO_PATH !== "/muro-logo.png" ? (
               <img src={process.env.NEXT_PUBLIC_LOGO_PATH} alt="Logo" className="h-14 w-auto max-w-full object-contain" />
            ) : (
               <>
                 <BookOpen className="w-6 h-6 text-blue-600" />
                 <span className="font-bold text-slate-800 text-lg tracking-tight">
                    {process.env.NEXT_PUBLIC_SITE_NAME?.split(' ')[0] || 'Muro'} <span className="text-blue-600 font-black">Öğrenci</span>
                 </span>
               </>
            )}
          </div>
          <button 
            onClick={() => setSidebarOpen(true)}
            className="p-2 text-slate-500 hover:bg-slate-100 rounded-lg transition-colors"
          >
            <Menu className="w-6 h-6" />
          </button>
        </header>

        <div className="relative z-0 p-4 md:p-8 min-h-full">
          {children}
        </div>
      </main>
    </div>
  );
}
