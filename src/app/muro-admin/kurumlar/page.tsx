import { getCurrentUser, impersonateTenant } from "@/app/actions/authActions";
import { getInstitutions, createInstitution, toggleInstitutionStatus } from "@/app/actions/institutionActions";
import { redirect } from "next/navigation";
import { Building2, Plus, Users, BookOpen, Activity, ToggleLeft, ToggleRight, CheckCircle2, XCircle, ArrowRight } from "lucide-react";
import { revalidatePath } from "next/cache";

export default async function KurumlarPage() {
  const user = await getCurrentUser();
  if (user?.role !== "SUPERADMIN") {
    redirect("/muro-admin");
  }

  const institutions = await getInstitutions();

  async function handleCreate(formData: FormData) {
    "use server";
    await createInstitution({
      name: formData.get("name") as string,
      subdomain: formData.get("subdomain") as string,
      adminName: formData.get("adminName") as string,
      adminEmail: formData.get("adminEmail") as string,
      adminPassword: formData.get("adminPassword") as string,
    });
  }

  async function handleToggle(id: string, currentStatus: boolean) {
    "use server";
    await toggleInstitutionStatus(id, !currentStatus);
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 tracking-tight flex items-center gap-2">
            <Building2 className="w-7 h-7 text-cyan-600" />
            Sistem Kurumları
          </h1>
          <p className="text-sm text-slate-500 mt-1">Sistemdeki dershane ve okulları yönetin.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-1">
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 sticky top-6">
            <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center gap-2">
              <Plus className="w-5 h-5 text-cyan-600" />
              Yeni Kurum Ekle
            </h2>
            <form action={handleCreate} className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1">Kurum Adı</label>
                <input 
                  type="text" 
                  name="name" 
                  required 
                  className="w-full px-4 py-2 border border-slate-200 rounded-xl focus:outline-none focus:border-cyan-500 transition-colors bg-slate-50 focus:bg-white text-sm"
                  placeholder="Örn: ON7 Akademi"
                />
              </div>
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1">Subdomain (Opsiyonel)</label>
                <input 
                  type="text" 
                  name="subdomain" 
                  className="w-full px-4 py-2 border border-slate-200 rounded-xl focus:outline-none focus:border-cyan-500 transition-colors bg-slate-50 focus:bg-white text-sm"
                  placeholder="Örn: on7 (on7.murosinav.com)"
                />
              </div>
              
              <div className="pt-2 mt-2 border-t border-slate-100">
                <h3 className="text-xs font-bold text-slate-500 uppercase tracking-wider mb-3">Kurum Yöneticisi (Admin)</h3>
                <div className="space-y-3">
                  <div>
                    <input 
                      type="text" 
                      name="adminName" 
                      required 
                      className="w-full px-4 py-2 border border-slate-200 rounded-xl focus:outline-none focus:border-cyan-500 transition-colors bg-slate-50 focus:bg-white text-sm"
                      placeholder="Yönetici Adı Soyadı"
                    />
                  </div>
                  <div>
                    <input 
                      type="email" 
                      name="adminEmail" 
                      required 
                      className="w-full px-4 py-2 border border-slate-200 rounded-xl focus:outline-none focus:border-cyan-500 transition-colors bg-slate-50 focus:bg-white text-sm"
                      placeholder="Yönetici E-Posta"
                    />
                  </div>
                  <div>
                    <input 
                      type="text" 
                      name="adminPassword" 
                      className="w-full px-4 py-2 border border-slate-200 rounded-xl focus:outline-none focus:border-cyan-500 transition-colors bg-slate-50 focus:bg-white text-sm"
                      placeholder="Şifre (Boş: 123456)"
                    />
                  </div>
                </div>
              </div>
              <button type="submit" className="w-full py-2.5 bg-cyan-600 hover:bg-cyan-700 text-white rounded-xl font-bold transition-all shadow-md shadow-cyan-500/20 active:scale-95 text-sm">
                Kurumu Oluştur
              </button>
            </form>
          </div>
        </div>

        <div className="lg:col-span-2">
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-slate-50 border-b border-slate-100 text-xs uppercase tracking-wider text-slate-500 font-semibold">
                    <th className="p-4 rounded-tl-2xl">Kurum Adı</th>
                    <th className="p-4">Öğrenci</th>
                    <th className="p-4">Sınav / Grup</th>
                    <th className="p-4">Durum</th>
                    <th className="p-4 rounded-tr-2xl text-right">İşlem</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-sm">
                  {institutions.map(inst => (
                    <tr key={inst.id} className="hover:bg-slate-50/50 transition-colors group">
                      <td className="p-4">
                        <div className="font-bold text-slate-800">{inst.name}</div>
                        <div className="text-xs text-slate-500">{inst.subdomain ? `${inst.subdomain}.murosinav.com` : 'Sadece Mail Girişi'}</div>
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-1.5 text-slate-600">
                          <Users className="w-4 h-4 text-slate-400" />
                          <span className="font-medium">{inst._count.users}</span>
                        </div>
                      </td>
                      <td className="p-4">
                        <div className="flex flex-col gap-1 text-xs">
                          <div className="flex items-center gap-1 text-slate-600">
                            <BookOpen className="w-3.5 h-3.5 text-slate-400" />
                            {inst._count.exams} Sınav
                          </div>
                          <div className="flex items-center gap-1 text-slate-600">
                            <Activity className="w-3.5 h-3.5 text-slate-400" />
                            {inst._count.groups} Grup
                          </div>
                        </div>
                      </td>
                      <td className="p-4">
                        {inst.isActive ? (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-700 text-xs font-bold border border-emerald-100">
                            <CheckCircle2 className="w-3.5 h-3.5" />
                            Aktif
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-rose-50 text-rose-700 text-xs font-bold border border-rose-100">
                            <XCircle className="w-3.5 h-3.5" />
                            Pasif
                          </span>
                        )}
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-3">
                          {inst.isActive && (
                            <form action={async () => {
                              "use server";
                              await impersonateTenant(inst.id);
                              redirect("/muro-admin");
                            }}>
                              <button 
                                type="submit" 
                                className="flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-blue-700 hover:bg-blue-600 hover:text-white rounded-xl text-xs font-bold transition-all"
                              >
                                Panele Git <ArrowRight className="w-3.5 h-3.5" />
                              </button>
                            </form>
                          )}
                          <form action={handleToggle.bind(null, inst.id, inst.isActive)}>
                            <button 
                              type="submit" 
                              className={`p-2 rounded-xl transition-colors ${inst.isActive ? 'text-emerald-600 hover:bg-emerald-50' : 'text-slate-400 hover:bg-slate-100'}`}
                              title={inst.isActive ? "Pasife Al" : "Aktife Al"}
                            >
                              {inst.isActive ? <ToggleRight className="w-6 h-6" /> : <ToggleLeft className="w-6 h-6" />}
                            </button>
                          </form>
                        </div>
                      </td>
                    </tr>
                  ))}
                  {institutions.length === 0 && (
                    <tr>
                      <td colSpan={5} className="p-8 text-center text-slate-500">
                        Henüz hiç kurum eklenmemiş.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
