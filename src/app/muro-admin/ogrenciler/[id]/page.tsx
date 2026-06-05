"use client";

import { useEffect, useState, use } from "react";
import { getStudentCRMProfile, updateStudentStatus, updateStudentPasswordByAdmin, updateUserRole } from "@/app/actions/userActions";
import { 
  User, Activity, ShieldAlert, DollarSign, BookOpen, KeyRound, 
  ArrowLeft, CheckCircle2, XCircle, TrendingUp, TrendingDown 
} from "lucide-react";
import Link from "next/link";
import { getExams } from "@/app/actions/examActions";

export default function StudentCRMProfile({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = use(params);
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("academic");
  const [error, setError] = useState<string | null>(null);
  
  // Role State
  const [isUpdatingRole, setIsUpdatingRole] = useState(false);

  // Password reset states
  const [newPassword, setNewPassword] = useState("");
  const [passwordMsg, setPasswordMsg] = useState("");

  const loadData = async () => {
    setLoading(true);
    try {
      const data = await getStudentCRMProfile(resolvedParams.id);
      setProfile(data);
    } catch(err: any) {
      setError(err?.message || "Öğrenci bulunamadı.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [resolvedParams.id]);

  const handleToggleStatus = async () => {
    await updateStudentStatus(profile.id, !profile.isActive);
    loadData();
  };

  const handleRoleChange = async (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newRole = e.target.value;
    setIsUpdatingRole(true);
    try {
      await updateUserRole(profile.id, newRole);
      // Profil verisini güncellemek için yeniden load
      loadData();
    } catch(err: any) {
      alert("Hata: " + err.message);
    } finally {
      setIsUpdatingRole(false);
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await updateStudentPasswordByAdmin(profile.id, newPassword);
      setNewPassword("");
      setPasswordMsg("Şifre başarıyla güncellendi!");
      setTimeout(() => setPasswordMsg(""), 3000);
    } catch(err: any) {
      setPasswordMsg("Hata: " + err.message);
    }
  };

  if (loading) return <div className="py-20 text-center text-blue-600 font-bold">Öğrenci Profil MR'ı çekiliyor...</div>;
  if (error) return <div className="py-20 text-center text-red-600 font-bold">Hata: {error}</div>;

  // LTV (Life Time Value) Hesaplama
  const totalLTV = profile.transactions.reduce((acc: number, tx: any) => acc + tx.amount, 0);

  return (
    <div className="max-w-6xl mx-auto space-y-6 pb-20">
      
      {/* Header and Back Button */}
      <div className="flex items-center gap-4 mb-6">
        <Link href="/muro-admin/ogrenciler" className="p-2 bg-white rounded-xl shadow-sm border border-slate-200 text-slate-400 hover:text-blue-600 transition-colors">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-black text-slate-900 flex items-center gap-3">
            {profile.name}
            {profile.isActive ? 
              <span className="bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-md text-[10px] tracking-wider uppercase">Aktif</span> :
              <span className="bg-red-100 text-red-700 px-2 py-0.5 rounded-md text-[10px] tracking-wider uppercase">Pasif</span>
            }
          </h1>
          <p className="text-sm text-slate-500">{profile.email} • {profile.phone || "Telefon Yok"}</p>
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-6">
        
        {/* Sol Sidebar - 360 Kontrol Merkezi */}
        <div className="w-full lg:w-1/3 space-y-6">
          
          <div className="bg-white rounded-3xl border border-slate-200 p-6 shadow-sm relative overflow-hidden">
             <div className="absolute top-0 right-0 w-32 h-32 bg-blue-50 rounded-full blur-2xl -mr-10 -mt-10"></div>
             
             <div className="relative z-10 flex flex-col items-center">
                 <div className="w-24 h-24 bg-gradient-to-br from-blue-600 to-indigo-600 rounded-full shadow-lg shadow-blue-500/30 flex items-center justify-center text-white text-3xl font-black mb-4">
                   {profile.name?.charAt(0).toUpperCase()}
                 </div>
                 <h2 className="text-xl font-bold text-slate-800">{profile.name}</h2>
                 
                 <div className="w-full mt-4 space-y-3 bg-slate-50/50 p-4 rounded-2xl border border-slate-100">
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-slate-400 font-bold uppercase tracking-widest">Rol / Yetki</span>
                      <select 
                        value={profile.role}
                        onChange={handleRoleChange}
                        disabled={isUpdatingRole}
                        className="bg-transparent border-b border-slate-200 font-bold text-slate-800 focus:outline-none focus:border-blue-500 max-w-[120px]"
                      >
                        <option value="STUDENT">Öğrenci</option>
                        <option value="EDITOR">Editör</option>
                        <option value="ASISTAN">Asistan</option>
                        <option value="ADMIN">Admin</option>
                        <option value="SUPERADMIN">Süper Admin</option>
                      </select>
                    </div>
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-slate-400 font-bold uppercase tracking-widest">Email</span>
                      <span className="font-mono text-slate-700">{profile.email}</span>
                    </div>
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-slate-400 font-bold uppercase tracking-widest">Telefon</span>
                      <span className="font-mono text-slate-700">{profile.phone || "-"}</span>
                    </div>
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-slate-400 font-bold uppercase tracking-widest">Kayıt Tarihi</span>
                      <span className="font-mono text-slate-700">{new Date(profile.createdAt).toLocaleDateString('tr-TR')}</span>
                    </div>
                 </div>
                 
                 <div className="w-full bg-slate-50 rounded-2xl p-4 border border-slate-100 mb-6 mt-4 flex justify-center">
                    <div className="flex flex-col items-center">
                      <p className="text-[10px] uppercase tracking-widest font-bold text-slate-400 mb-2">Bulunduğu Gruplar / Sınıflar</p>
                      <div className="flex flex-wrap gap-2 justify-center">
                         {profile.groups && profile.groups.length > 0 ? profile.groups.map((g: any) => (
                           <span key={g.id} className="font-bold text-blue-700 text-sm bg-blue-100/50 px-2.5 py-1 rounded-md">{g.name}</span>
                         )) : <span className="font-bold text-slate-500 text-sm">Yok - Bağımsız Öğrenci</span>}
                      </div>
                    </div>
                 </div>

                 <button 
                   onClick={handleToggleStatus}
                   className={`w-full py-3 rounded-xl font-bold text-sm tracking-wide transition-all shadow-sm ${profile.isActive ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'}`}
                 >
                   Hesabı {profile.isActive ? 'Pasife Al (Dondur)' : 'Aktif Et (Girişe Aç)'}
                 </button>
             </div>
          </div>

          <div className="bg-white rounded-3xl border border-slate-200 p-6 shadow-sm">
             <h3 className="font-bold text-slate-800 flex items-center gap-2 mb-4">
               <KeyRound className="w-5 h-5 text-amber-500" />
               Şifre Sıfırlama
             </h3>
             <form onSubmit={handleChangePassword} className="space-y-3">
                <input 
                  type="text" 
                  autoComplete="off"
                  placeholder="Yeni Şifre Belirle" 
                  value={newPassword}
                  onChange={e => setNewPassword(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:border-amber-400 focus:bg-white"
                />
                <button type="submit" disabled={newPassword.length < 5} className="w-full bg-amber-50 text-amber-600 hover:bg-amber-100 font-bold py-2 rounded-xl text-sm transition-colors disabled:opacity-50">
                  Şifreyi Değiştir
                </button>
                {passwordMsg && <p className="text-xs font-medium text-center mt-2 text-indigo-600">{passwordMsg}</p>}
             </form>
          </div>

        </div>

        {/* Sağ Alan - İçerik (Tabs) */}
        <div className="w-full lg:w-2/3 space-y-6">
           
           {/* Tab Butonları */}
           <div className="flex gap-2 bg-white p-2 rounded-2xl border border-slate-200 overflow-x-auto">
             <button onClick={() => setActiveTab("academic")} className={`flex-1 flex justify-center items-center gap-2 py-3 px-4 rounded-xl text-sm font-bold transition-all ${activeTab === 'academic' ? 'bg-blue-600 text-white shadow-md' : 'text-slate-500 hover:bg-slate-50'}`}>
                <BookOpen className="w-4 h-4" /> Karneler
             </button>
             <button onClick={() => setActiveTab("finance")} className={`flex-1 flex justify-center items-center gap-2 py-3 px-4 rounded-xl text-sm font-bold transition-all ${activeTab === 'finance' ? 'bg-emerald-600 text-white shadow-md' : 'text-slate-500 hover:bg-slate-50'}`}>
                <DollarSign className="w-4 h-4" /> Finans Geçmişi
             </button>
             <button onClick={() => setActiveTab("security")} className={`flex-1 flex justify-center items-center gap-2 py-3 px-4 rounded-xl text-sm font-bold transition-all ${activeTab === 'security' ? 'bg-red-600 text-white shadow-md' : 'text-slate-500 hover:bg-slate-50'}`}>
                <ShieldAlert className="w-4 h-4" /> Güvenlik Logları
             </button>
           </div>

           {/* Akademik / Karne Tabı */}
           {activeTab === "academic" && (
             <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 overflow-hidden">
                <div className="mb-6 flex justify-between items-center">
                  <h3 className="font-bold text-lg text-slate-800">Sınav Geçmişi ve Karneler</h3>
                  <span className="bg-blue-50 text-blue-600 font-bold px-3 py-1 rounded-lg text-sm">{profile.results.length} Sınav Çözdü</span>
                </div>
                
                {profile.results.length === 0 ? (
                   <div className="text-center py-10 text-slate-400 text-sm">Henüz sistemde hiçbir deneme çözmemiş.</div>
                ) : (
                   <div className="space-y-4">
                     {profile.results.map((res: any) => (
                       <details key={res.id} className="group bg-slate-50 rounded-2xl border border-slate-200 overflow-hidden outline-none">
                         <summary className="flex flex-col md:flex-row md:items-center justify-between p-4 cursor-pointer hover:bg-slate-100 transition-colors list-none select-none">
                            <div>
                               <h4 className="font-bold text-slate-800">{res.exam.title}</h4>
                               <p className="text-xs text-slate-500 mt-1">{new Date(res.createdAt).toLocaleString('tr-TR')} tarihinde tamamlandı.</p>
                            </div>
                            <div className="flex items-center gap-4 mt-3 md:mt-0">
                               <div className="text-center">
                                  <p className="text-[10px] uppercase font-bold text-slate-400">Puan</p>
                                  <p className="font-black text-blue-600 font-mono">{res.score.toFixed(1)}</p>
                               </div>
                               <div className="w-px h-8 bg-slate-200"></div>
                               <div className="flex gap-3">
                                  <div className="text-center">
                                    <p className="text-[10px] text-emerald-500 font-bold">D</p>
                                    <p className="font-bold">{res.correctAnswers}</p>
                                  </div>
                                  <div className="text-center">
                                    <p className="text-[10px] text-red-500 font-bold">Y</p>
                                    <p className="font-bold">{res.incorrectAnswers}</p>
                                  </div>
                                  <div className="text-center">
                                    <p className="text-[10px] text-slate-400 font-bold">B</p>
                                    <p className="font-bold">{res.emptyQuestions}</p>
                                  </div>
                               </div>
                            </div>
                         </summary>
                         <div className="p-4 bg-white border-t border-slate-100">
                            <p className="text-xs uppercase font-bold text-slate-400 mb-3 tracking-widest">Sınav Optiği (Verilen Cevaplar)</p>
                            <div className="flex gap-2 flex-wrap max-h-48 overflow-y-auto pr-2 custom-scrollbar">
                              {!res.answers || res.answers.length === 0 ? (
                                <p className="text-xs text-slate-400 italic">Optik detayları bulunamadı (Eski sınav).</p>
                              ) : (
                                res.answers.map((ans: any) => (
                                  <div key={ans.id} className="w-8 flex flex-col items-center">
                                     <span className="text-[10px] text-slate-400 font-mono mb-0.5">{ans.questionNumber}</span>
                                     <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold ${!ans.selectedOption ? 'bg-slate-100 text-slate-400 border border-slate-200' : 'bg-blue-50 text-blue-600 border border-blue-200 shadow-sm'}`}>
                                        {ans.selectedOption || "-"}
                                     </div>
                                  </div>
                                ))
                              )}
                            </div>
                         </div>
                       </details>
                     ))}
                   </div>
                )}

                {/* Bağımsız Sınavları Ekstra Göster */}
                {profile.directExams.length > 0 && (
                   <div className="mt-8 border-t border-slate-100 pt-6">
                      <h4 className="text-sm font-bold text-slate-500 uppercase tracking-widest mb-4">Sınıf Dışı / Özel Satın Alınan Denemeleri</h4>
                      <div className="flex flex-wrap gap-2">
                         {profile.directExams.map((ex: any) => (
                           <div key={ex.id} className="bg-purple-50 text-purple-700 px-3 py-2 rounded-xl text-xs font-bold border border-purple-100 flex items-center gap-2">
                             <BookOpen className="w-3.5 h-3.5" />
                             {ex.title}
                           </div>
                         ))}
                      </div>
                   </div>
                )}
             </div>
           )}

           {/* Finansal MR Tabı */}
           {activeTab === "finance" && (
             <div className="space-y-6">
                 <div className="grid grid-cols-2 gap-4">
                    <div className="bg-emerald-50 rounded-3xl border border-emerald-100 p-6 flex flex-col justify-center items-center text-center">
                       <DollarSign className="w-8 h-8 text-emerald-500 mb-2 p-1.5 bg-emerald-100 rounded-xl" />
                       <p className="text-xs font-bold text-emerald-600/70 uppercase tracking-widest">Öğrenci Kâr Planı (LTV)</p>
                       <p className="text-3xl font-black text-emerald-700 mt-1">₺{totalLTV.toLocaleString("tr-TR")}</p>
                    </div>
                    <div className="bg-white rounded-3xl border border-slate-200 p-6 flex flex-col justify-center items-center text-center">
                       <Activity className="w-8 h-8 text-blue-500 mb-2 p-1.5 bg-blue-50 rounded-xl" />
                       <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">İşlem Hacmi</p>
                       <p className="text-3xl font-black text-slate-800 mt-1">{profile.transactions.length} Kayıt</p>
                    </div>
                 </div>

                 <div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden">
                    <h3 className="font-bold text-lg text-slate-800 p-6 border-b border-slate-100">İşlem Defteri (Muhasebe)</h3>
                    <table className="w-full text-sm text-left">
                       <thead className="bg-slate-50 text-[10px] uppercase text-slate-500 font-bold">
                         <tr>
                           <th className="px-6 py-3">Tarih</th>
                           <th className="px-6 py-3">Sebep</th>
                           <th className="px-6 py-3 text-right">Tutar</th>
                         </tr>
                       </thead>
                       <tbody>
                         {profile.transactions.map((tx: any) => (
                           <tr key={tx.id} className="border-b border-slate-100 last:border-0 hover:bg-slate-50">
                             <td className="px-6 py-4 text-slate-500 text-xs font-mono">{new Date(tx.createdAt).toLocaleDateString('tr-TR', { day: '2-digit', month: 'short', year: 'numeric'})}</td>
                             <td className="px-6 py-4">
                                <span className={`px-2 py-1 flex w-max items-center justify-center rounded-lg text-xs font-bold border ${tx.reason === 'GROUP_JOIN' ? 'bg-amber-50 text-amber-700 border-amber-200' : 'bg-purple-50 text-purple-700 border-purple-200'}`}>
                                  {tx.reason === "GROUP_JOIN" ? "Grup / Sınıf Kaydı" : "Sınav Satın Alma"}
                                </span>
                             </td>
                             <td className="px-6 py-4 text-right">
                               <span className="font-black text-emerald-600">₺{tx.amount}</span>
                             </td>
                           </tr>
                         ))}
                         {profile.transactions.length === 0 && (
                           <tr><td colSpan={3} className="px-6 py-10 text-center text-slate-400">Muhasebe kaydı veya satın alma yok.</td></tr>
                         )}
                       </tbody>
                    </table>
                 </div>
             </div>
           )}

           {/* Security Logs Tab */}
           {activeTab === "security" && (
             <div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden">
                <div className="p-6 bg-red-50 border-b border-red-100 flex items-center gap-3">
                   <div className="w-10 h-10 bg-red-100 text-red-600 rounded-2xl flex items-center justify-center">
                     <ShieldAlert className="w-5 h-5" />
                   </div>
                   <div>
                     <h3 className="font-bold text-red-800 text-lg">Güvenlik İhlal Dosyası</h3>
                     <p className="text-xs text-red-600 font-medium">Bu öğrencinin sınavlarda yaptığı şüpheli aktivite logları bu alanda depolanır.</p>
                   </div>
                </div>
                
                {profile.logs.length === 0 ? (
                   <div className="p-10 text-center flex flex-col items-center justify-center gap-3">
                      <div className="w-16 h-16 bg-emerald-50 rounded-full flex items-center justify-center text-emerald-600">
                         <CheckCircle2 className="w-8 h-8" />
                      </div>
                      <div>
                         <p className="font-bold text-slate-800 text-lg">Tertemiz!</p>
                         <p className="text-slate-500 text-sm">Öğrenciye ait herhangi bir sınav kuralı ihlali bulunmuyor.</p>
                      </div>
                   </div>
                ) : (
                   <div className="p-0">
                      {profile.logs.map((log: any) => (
                        <div key={log.id} className="p-4 border-b border-slate-100 flex items-start gap-4 hover:bg-slate-50 transition-colors">
                           <div className="mt-1">
                              {log.actionType === 'BLUR' && <XCircle className="w-5 h-5 text-amber-500" />}
                              {log.actionType === 'KEYBOARD' && <ShieldAlert className="w-5 h-5 text-red-500" />}
                           </div>
                           <div className="flex-1">
                              <div className="flex justify-between items-start">
                                <p className="font-bold text-slate-800 text-sm">
                                  {log.actionType === 'BLUR' ? 'Sekme Değiştirme / Odak Kaybı' : 
                                   log.actionType === 'KEYBOARD' ? 'Klavye Kısayolu Yasak İhlali' : log.actionType}
                                </p>
                                <span className="text-[10px] text-slate-400 font-mono px-2 py-1 bg-slate-100 rounded-md">
                                  {new Date(log.createdAt).toLocaleString('tr-TR')}
                                </span>
                              </div>
                              <p className="text-slate-500 text-xs mt-1 bg-white border border-slate-200 p-2 rounded-lg font-mono">{log.details}</p>
                           </div>
                        </div>
                      ))}
                   </div>
                )}
             </div>
           )}

        </div>

      </div>
    </div>
  );
}
