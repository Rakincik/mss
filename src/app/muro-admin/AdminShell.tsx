"use client";

import Link from "next/link";
import { BookOpen, LayoutDashboard, ShieldAlert, Users, DollarSign, LogOut, Menu, X, Building2, BarChart3 } from "lucide-react";
import { ReactNode, useState } from "react";
import { logoutUser, clearImpersonation } from "@/app/actions/authActions";

interface AdminShellProps {
  children: ReactNode;
  user: { name: string | null; role: string; isImpersonating?: boolean; institutionName?: string };
}

export default function AdminShell({ children, user }: AdminShellProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

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
      <aside className={`fixed lg:static inset-y-0 left-0 z-50 w-64 bg-white border-r border-slate-200 flex flex-col shadow-sm transform transition-transform duration-300 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}`}>
        <div className="h-16 flex items-center justify-between px-6 border-b border-slate-100">
          <div></div>
          <button 
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        
        <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
          <div className="px-3 pb-2 pt-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Yönetim</div>
          <Link href="/muro-admin" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-blue-700 hover:bg-blue-50 rounded-xl transition-all group">
            <LayoutDashboard className="w-5 h-5 text-slate-400 group-hover:text-blue-500 transition-colors" />
            <span>Dashboard</span>
          </Link>

          {user.role !== "MUHASEBE" && (
            <>
              <Link href="/muro-admin/istatistikler" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-orange-700 hover:bg-orange-50 rounded-xl transition-all group">
                <BarChart3 className="w-5 h-5 text-slate-400 group-hover:text-orange-500 transition-colors" />
                <span>İstatistikler</span>
              </Link>
              <Link href="/muro-admin/sinavlar" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-purple-700 hover:bg-purple-50 rounded-xl transition-all group">
                <BookOpen className="w-5 h-5 text-slate-400 group-hover:text-purple-500 transition-colors" />
                <span>Sınavlar</span>
              </Link>
              <div className="px-3 pt-4 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Kullanıcılar</div>
              <Link href="/muro-admin/ogrenciler" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-indigo-700 hover:bg-indigo-50 rounded-xl transition-all group">
                <Users className="w-5 h-5 text-slate-400 group-hover:text-indigo-500 transition-colors" />
                <span>Öğrenciler</span>
              </Link>
              <Link href="/muro-admin/gruplar" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-amber-700 hover:bg-amber-50 rounded-xl transition-all group">
                <Users className="w-5 h-5 text-slate-400 group-hover:text-amber-500 transition-colors" />
                <span>Gruplar</span>
              </Link>
              <div className="px-3 pt-4 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">İçerik Yönetimi</div>
              <Link href="/muro-admin/dokumanlar" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-pink-700 hover:bg-pink-50 rounded-xl transition-all group">
                <BookOpen className="w-5 h-5 text-slate-400 group-hover:text-pink-500 transition-colors" />
                <span>Doküman Arşivi</span>
              </Link>
              <div className="px-3 pt-4 pb-2 text-[10px] uppercase tracking-widest font-bold text-slate-400">Sistem</div>
              {user.role === "SUPERADMIN" && (
                <Link href="/muro-admin/kurumlar" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-cyan-700 hover:bg-cyan-50 rounded-xl transition-all group mb-1">
                  <Building2 className="w-5 h-5 text-cyan-500 group-hover:text-cyan-600 transition-colors" />
                  <span>Kurumlar (Tenant)</span>
                </Link>
              )}
              <Link href="/muro-admin/guvenlik" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-red-700 hover:bg-red-50 rounded-xl transition-all group">
                <ShieldAlert className="w-5 h-5 text-red-500 group-hover:text-red-600 transition-colors" />
                <span className="text-red-600 group-hover:text-red-700">Güvenlik Logları</span>
              </Link>
            </>
          )}
          
          {user.role !== "ASISTAN" && (
            <Link href="/muro-admin/muhasebe" onClick={() => setSidebarOpen(false)} className="flex items-center gap-3 px-3 py-2.5 text-sm font-semibold text-slate-600 hover:text-emerald-700 hover:bg-emerald-50 rounded-xl transition-all group mt-2">
              <DollarSign className="w-5 h-5 text-slate-400 group-hover:text-emerald-500 transition-colors" />
              <span>Muhasebe</span>
            </Link>
          )}
        </nav>

        <div className="p-4 border-t border-slate-100 bg-slate-50/50">
          <form action={logoutUser}>
            <button type="submit" className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm font-bold text-rose-600 hover:text-rose-700 bg-rose-50 border border-rose-200 hover:border-rose-300 rounded-xl transition-all shadow-sm hover:shadow">
              <LogOut className="w-4 h-4" />
              <span>Güvenli Çıkış Yap</span>
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

        <header className="h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 md:px-8 shadow-sm z-10 shrink-0 gap-4">
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
