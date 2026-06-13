"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookOpen, LayoutDashboard, ShieldAlert, Users, DollarSign, LogOut, Menu, X, Building2, BarChart3, ChevronRight, Activity } from "lucide-react";
import { ReactNode, useState } from "react";
import { logoutUser, clearImpersonation } from "@/app/actions/authActions";

interface AdminShellProps {
  children: ReactNode;
  user: { name: string | null; role: string; isImpersonating?: boolean; institutionName?: string };
}

export default function AdminShell({ children, user }: AdminShellProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const pathname = usePathname();

  const NavItem = ({ href, icon: Icon, label, color, activeGradient }: any) => {
    // Tam eşleşme veya alt rotalarda aktiflik durumu
    const isActive = href === "/muro-admin" ? pathname === href : pathname?.startsWith(href);
    
    return (
      <Link 
        href={href} 
        onClick={() => setSidebarOpen(false)} 
        className={`flex items-center gap-3 px-3 py-2.5 text-sm font-bold rounded-xl transition-all duration-300 group ${
          isActive 
            ? `bg-gradient-to-r ${activeGradient} text-white shadow-md transform scale-[1.02]` 
            : `text-slate-600 hover:bg-white hover:shadow-sm hover:translate-x-1 border border-transparent hover:border-slate-200`
        }`}
      >
        <div className={`p-1.5 rounded-lg transition-colors ${isActive ? 'bg-white/20' : `bg-slate-100 group-hover:${color.replace('text-', 'bg-').replace('600', '100')} group-hover:${color}`}`}>
          <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-slate-500'}`} />
        </div>
        <span className="flex-1">{label}</span>
        {isActive && <ChevronRight className="w-4 h-4 text-white/50" />}
      </Link>
    );
  };

  return (
    <div className="min-h-screen bg-slate-50 flex font-sans text-slate-800">
      
      {/* Mobile Overlay */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`fixed lg:static inset-y-0 left-0 z-50 w-72 bg-slate-50/50 border-r border-slate-200 flex flex-col shadow-[4px_0_24px_rgba(0,0,0,0.02)] transform transition-transform duration-300 ease-in-out print:hidden ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
        <div className="h-16 flex items-center justify-between px-6 border-b border-slate-200/60 bg-white">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-md shadow-blue-500/20">
              <Activity className="w-5 h-5" />
            </div>
            <span className="font-black text-lg tracking-tight text-slate-800">MURO <span className="text-blue-600">LMS</span></span>
          </div>
          <button 
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <nav className="flex-1 p-4 space-y-1.5 overflow-y-auto custom-scrollbar">
          
          <div className="flex items-center gap-2 px-3 pb-2 pt-2">
            <div className="h-px bg-slate-200 flex-1"></div>
            <span className="text-[9px] uppercase tracking-[0.2em] font-black text-slate-400">Yönetim</span>
            <div className="h-px bg-slate-200 flex-1"></div>
          </div>
          <NavItem href="/muro-admin" icon={LayoutDashboard} label="Dashboard" color="text-blue-600" activeGradient="from-blue-600 to-blue-500 shadow-blue-500/20" />

          {user.role !== "MUHASEBE" && (
            <>
              <NavItem href="/muro-admin/sinavlar" icon={BookOpen} label="Sınavlar" color="text-purple-600" activeGradient="from-purple-600 to-purple-500 shadow-purple-500/20" />
              
              <div className="flex items-center gap-2 px-3 pb-2 pt-4">
                <div className="h-px bg-slate-200 flex-1"></div>
                <span className="text-[9px] uppercase tracking-[0.2em] font-black text-slate-400">Kullanıcılar</span>
                <div className="h-px bg-slate-200 flex-1"></div>
              </div>
              <NavItem href="/muro-admin/ogrenciler" icon={Users} label="Öğrenciler" color="text-indigo-600" activeGradient="from-indigo-600 to-indigo-500 shadow-indigo-500/20" />
              <NavItem href="/muro-admin/gruplar" icon={Users} label="Gruplar" color="text-amber-600" activeGradient="from-amber-500 to-amber-400 shadow-amber-500/20" />
              
              <div className="flex items-center gap-2 px-3 pb-2 pt-4">
                <div className="h-px bg-slate-200 flex-1"></div>
                <span className="text-[9px] uppercase tracking-[0.2em] font-black text-slate-400">İçerik Arşivi</span>
                <div className="h-px bg-slate-200 flex-1"></div>
              </div>
              <NavItem href="/muro-admin/dokumanlar" icon={BookOpen} label="Doküman Arşivi" color="text-pink-600" activeGradient="from-pink-600 to-pink-500 shadow-pink-500/20" />
              
              <div className="flex items-center gap-2 px-3 pb-2 pt-4">
                <div className="h-px bg-slate-200 flex-1"></div>
                <span className="text-[9px] uppercase tracking-[0.2em] font-black text-slate-400">Sistem</span>
                <div className="h-px bg-slate-200 flex-1"></div>
              </div>
              {user.role === "SUPERADMIN" && (
                <NavItem href="/muro-admin/kurumlar" icon={Building2} label="Kurumlar (Tenant)" color="text-cyan-600" activeGradient="from-cyan-600 to-cyan-500 shadow-cyan-500/20" />
              )}
              <NavItem href="/muro-admin/istatistikler" icon={BarChart3} label="İstatistikler" color="text-orange-600" activeGradient="from-orange-500 to-orange-400 shadow-orange-500/20" />
              <NavItem href="/muro-admin/guvenlik" icon={ShieldAlert} label="Güvenlik Logları" color="text-rose-600" activeGradient="from-rose-600 to-rose-500 shadow-rose-500/20" />
            </>
          )}
          
          {user.role !== "ASISTAN" && (
            <div className="pt-2">
              <NavItem href="/muro-admin/muhasebe" icon={DollarSign} label="Muhasebe Modülü" color="text-emerald-600" activeGradient="from-emerald-600 to-emerald-500 shadow-emerald-500/20" />
            </div>
          )}
        </nav>

        <div className="p-4 bg-white border-t border-slate-200/60">
          <form action={logoutUser}>
            <button type="submit" className="w-full flex items-center justify-center gap-2 px-3 py-2.5 text-sm font-bold text-rose-600 hover:text-white bg-rose-50 border border-rose-100 hover:bg-rose-600 hover:border-rose-600 rounded-xl transition-all duration-300 shadow-sm hover:shadow-md hover:shadow-rose-500/20 group">
              <LogOut className="w-4 h-4 transition-transform group-hover:-translate-x-1" />
              <span>Sistemden Çıkış Yap</span>
            </button>
          </form>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col overflow-hidden bg-slate-50 relative min-w-0">
        
        {user.isImpersonating && (
          <div className="bg-rose-600 text-white px-4 md:px-8 py-3 flex items-center justify-between text-sm shadow-md shrink-0 relative z-20">
            <div className="flex items-center gap-2">
              <ShieldAlert className="w-5 h-5 shrink-0" />
              <span className="leading-tight">
                Şu an <strong className="font-black bg-rose-700/50 px-1.5 py-0.5 rounded ml-0.5 mr-0.5">{user.institutionName || 'Seçili Kurum'}</strong> paneline bakıyorsunuz. Tüm işlemler bu kuruma yansır.
              </span>
            </div>
            <form action={async () => {
              const res = await clearImpersonation();
              window.location.href = "/muro-admin/kurumlar";
            }}>
              <button type="submit" className="bg-white text-rose-600 hover:bg-rose-50 px-3 py-1.5 rounded-lg font-bold shadow-sm transition-all whitespace-nowrap ml-4 text-xs">
                Kurumdan Çık
              </button>
            </form>
          </div>
        )}

        <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 md:px-8 shadow-sm z-10 shrink-0 gap-4 print:hidden">
          {/* Hamburger (Mobile) */}
          <button 
            onClick={() => setSidebarOpen(true)}
            className="lg:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-xl transition-colors"
          >
            <Menu className="w-6 h-6" />
          </button>

          {/* Desktop spacer */}
          <div className="hidden lg:block" />

          <div className="flex items-center gap-3 md:gap-6">
            <div className="flex items-center gap-3">
              <span className="text-sm font-bold text-slate-600 hidden sm:inline">
                {user.name || "Sistem Yetkilisi"} <span className="text-[10px] bg-slate-100 text-slate-500 px-2 py-1 rounded-md ml-1">{user.role}</span>
              </span>
              <div className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold text-white shadow-md ${user.role === 'SUPERADMIN' ? 'bg-amber-500 shadow-amber-500/20' : 'bg-blue-600 shadow-blue-600/20'}`}>
                {user.name ? user.name.charAt(0).toUpperCase() : "Y"}
              </div>
            </div>
            
            <form action={logoutUser} className="hidden md:block">
              <button type="submit" className="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors" title="Çıkış Yap">
                <LogOut className="w-5 h-5" />
              </button>
            </form>
          </div>
        </header>
        <div className="flex-1 overflow-y-auto p-4 md:p-8 custom-scrollbar">
          {children}
        </div>
      </main>
    </div>
  );
}
