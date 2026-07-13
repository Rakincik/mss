"use client";

import { useState } from "react";
import { GraduationCap, ArrowRight, Loader2 } from "lucide-react";
import { loginWithCredentials } from "@/app/actions/authActions";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    
    const formData = new FormData(e.currentTarget);
    const res = await loginWithCredentials(formData);
    
    if (res.success && res.redirectUrl) {
      window.location.href = res.redirectUrl;
    } else {
      setError(res.message || "Giriş başarısız.");
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4 sm:p-6 font-sans">
      <div className="w-full max-w-[400px] bg-white rounded-3xl shadow-xl shadow-slate-200/50 p-8 sm:p-10 text-center relative overflow-hidden">
        {/* Dekoratif hafif arka plan - isteğe bağlı */}
        <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-blue-50/50 to-transparent -z-10"></div>
        
        {/* İkon / Logo */}
        {process.env.NEXT_PUBLIC_LOGO_PATH && process.env.NEXT_PUBLIC_LOGO_PATH !== "/muro-logo.png" ? (
          <div className="mx-auto w-full max-w-[320px] h-36 mb-6 flex items-center justify-center">
            <img 
              src={process.env.NEXT_PUBLIC_LOGO_PATH} 
              alt="Kurum Logosu" 
              className="max-w-full max-h-full object-contain drop-shadow-sm"
            />
          </div>
        ) : (
          <>
            <div className="mx-auto w-20 h-20 bg-gradient-to-br from-[#1d8cd4] to-[#126ab0] rounded-2xl flex items-center justify-center shadow-lg shadow-blue-500/30 mb-4">
              <GraduationCap className="w-10 h-10 text-white" />
            </div>
            <div className="text-center mb-6">
              <p className="text-xs text-slate-500 font-medium mt-1">
                {process.env.NEXT_PUBLIC_SITE_NAME || 'Sınav Platformu'}
              </p>
            </div>
          </>
        )}        {error && (
          <div className="bg-red-50 text-red-600 text-sm font-semibold p-3.5 rounded-xl mb-6 shadow-sm border border-red-100">
            {error}
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-5 text-left">
          <div className="space-y-1.5">
            <label className="text-sm font-bold text-slate-700 ml-1">E-posta</label>
            <input 
              type="email" 
              name="email"
              placeholder="E-postanız" 
              required
              className="w-full px-4 py-3.5 bg-white border border-slate-200 rounded-xl outline-none focus:border-blue-500 transition-all font-medium text-slate-700 shadow-sm placeholder-slate-400"
            />
          </div>
          
          <div className="space-y-1.5">
            <label className="text-sm font-bold text-slate-700 ml-1">Şifre</label>
            <input 
              type="password" 
              name="password"
              placeholder="••••••••" 
              required
              className="w-full px-4 py-3.5 bg-white border border-slate-200 rounded-xl outline-none focus:border-blue-500 transition-all font-medium text-slate-700 shadow-sm placeholder-slate-400 tracking-widest"
            />
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="w-full mt-4 flex items-center justify-center gap-2 py-4 px-6 bg-[#1782cf] hover:bg-[#126ab0] active:scale-[0.98] text-white rounded-xl font-bold text-md transition-all shadow-md shadow-blue-500/20 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : "Giriş Yap"}
          </button>
        </form>

      </div>
    </div>
  );
}
