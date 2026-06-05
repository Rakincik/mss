"use client";

import { useState } from "react";
import { updateStudentProfile } from "@/app/actions/authActions";
import { Save, AlertCircle, CheckCircle2 } from "lucide-react";

export default function ProfileForm({ student }: { student: any }) {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: "success" | "error", text: string } | null>(null);

  async function handleSubmit(formData: FormData) {
    setLoading(true);
    setMessage(null);
    
    // Şifre boşsa hiç gönderme
    const pw = formData.get("password");
    if (!pw) {
      formData.delete("password");
    }

    const result = await updateStudentProfile(formData);
    
    if (result.success) {
      setMessage({ type: "success", text: result.message });
      // Clear password field
      const form = document.getElementById("profileForm") as HTMLFormElement;
      if (form) form.password.value = "";
    } else {
      setMessage({ type: "error", text: result.message });
    }
    
    setLoading(false);
  }

  return (
    <form id="profileForm" action={handleSubmit} className="space-y-6">
      {message && (
        <div className={`p-4 rounded-xl flex items-center gap-3 border ${message.type === "success" ? "bg-emerald-50 border-emerald-100 text-emerald-600" : "bg-red-50 border-red-100 text-red-600"}`}>
          {message.type === "success" ? <CheckCircle2 className="w-5 h-5 shrink-0" /> : <AlertCircle className="w-5 h-5 shrink-0" />}
          <p className="font-medium text-sm">{message.text}</p>
        </div>
      )}

      <div>
        <label className="block text-[11px] font-bold text-slate-500 mb-2 uppercase tracking-wide">Ad Soyad</label>
        <input 
          type="text" 
          name="name" 
          defaultValue={student.name || ""} 
          required 
          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-colors shadow-sm"
        />
      </div>

      <div>
        <label className="block text-[11px] font-bold text-slate-500 mb-2 uppercase tracking-wide">E-posta Adresi</label>
        <input 
          type="email" 
          name="email" 
          defaultValue={student.email || ""} 
          required 
          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-colors shadow-sm"
        />
      </div>

      <div>
        <label className="block text-[11px] font-bold text-slate-500 mb-2 uppercase tracking-wide">Yeni Şifre (Değiştirmek İstemiyorsanız Boş Bırakın)</label>
        <input 
          type="password" 
          name="password" 
          placeholder="••••••••" 
          className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2.5 text-slate-900 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-colors shadow-sm"
        />
      </div>

      <div className="pt-2">
        <button 
          type="submit" 
          disabled={loading}
          className="w-full flex items-center justify-center gap-2 py-3 bg-blue-600 hover:bg-blue-500 disabled:opacity-50 disabled:pointer-events-none text-white font-bold rounded-xl shadow-md shadow-blue-500/20 transition-all active:scale-95 text-sm"
        >
          {loading ? (
             <span className="flex items-center gap-2">KAYDEDİLİYOR...</span>
          ) : (
             <><Save className="w-4 h-4" /> DEĞİŞİKLİKLERİ KAYDET</>
          )}
        </button>
      </div>
    </form>
  );
}
