"use client";

import { useState, useEffect } from "react";
import { Plus, Trash2, Calculator, Layers, BookOpen, Edit2, AlertTriangle, X, BarChart, Search, ArrowUpDown } from "lucide-react";
import { getPackages, createPackage, deletePackage, calculatePackageScores, updatePackage } from "@/app/actions/packageActions";
import Link from "next/link";
import { useToast } from "@/hooks/useToast";

export default function PackageExams({ allExams, allGroups = [] }: { allExams: any[], allGroups?: any[] }) {
  const [packages, setPackages] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [calculatingId, setCalculatingId] = useState<string | null>(null);
  const [editPackageId, setEditPackageId] = useState<string | null>(null);
  const [deletePackageId, setDeletePackageId] = useState<string | null>(null);
  const [confirmCalculateId, setConfirmCalculateId] = useState<string | null>(null);
  const { showToast } = useToast();

  const [formData, setFormData] = useState({ title: "", description: "", isSequential: false, showResultsTime: "" });
  const [selectedExams, setSelectedExams] = useState<string[]>([]);
  const [selectedGroups, setSelectedGroups] = useState<string[]>([]);
  const [examSearchTerm, setExamSearchTerm] = useState("");
  const [groupSearchTerm, setGroupSearchTerm] = useState("");

  const [sortBy, setSortBy] = useState('newest');
  const [searchInput, setSearchInput] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  const fetchPackages = async () => {
    setLoading(true);
    const data = await getPackages();
    setPackages(data);
    setLoading(false);
  };

  useEffect(() => {
    fetchPackages();
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedExams.length === 0) {
      showToast("Lütfen pakete en az bir sınav ekleyin.", "error");
      return;
    }
    setSaving(true);
    
    let res;
    if (editPackageId) {
      res = await updatePackage(editPackageId, { ...formData, examIds: selectedExams, groupIds: selectedGroups });
    } else {
      res = await createPackage({ ...formData, examIds: selectedExams, groupIds: selectedGroups });
    }
    
    if (res.success) {
      setShowModal(false);
      setEditPackageId(null);
      setFormData({ title: "", description: "", isSequential: false, showResultsTime: "" });
      setSelectedExams([]);
      setSelectedGroups([]);
      setGroupSearchTerm("");
      fetchPackages();
    } else {
      showToast("Hata: " + res.error, "error");
    }
    setSaving(false);
  };

  const handleCalculate = async (pkgId: string) => {
    setCalculatingId(pkgId);
    const res = await calculatePackageScores(pkgId);
    if (res.success) {
      showToast("Puanlar başarıyla hesaplandı ve karneler üretildi!", "success");
      fetchPackages();
    } else {
      showToast("Hata: " + res.error, "error");
    }
    setCalculatingId(null);
  };

  if (loading) return <div className="text-center py-10 text-slate-500">Paketler yükleniyor...</div>;

  let filteredPackages = [...packages];
  
  if (searchQuery) {
    const q = searchQuery.toLowerCase();
    filteredPackages = filteredPackages.filter(p => p.title.toLowerCase().includes(q) || (p.description && p.description.toLowerCase().includes(q)));
  }

  filteredPackages.sort((a, b) => {
    if (sortBy === 'newest') return new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime();
    if (sortBy === 'oldest') return new Date(a.createdAt || 0).getTime() - new Date(b.createdAt || 0).getTime();
    if (sortBy === 'updated') return new Date(b.updatedAt || 0).getTime() - new Date(a.updatedAt || 0).getTime();
    if (sortBy === 'az') return a.title.localeCompare(b.title);
    if (sortBy === 'za') return b.title.localeCompare(a.title);
    return 0;
  });

  return (
    <div className="space-y-6 animate-in fade-in">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-xl font-bold text-slate-800">Sınav Paketleri</h2>
          <p className="text-slate-500 text-sm">Birden fazla oturumu birleştirerek tek bir puan türü oluşturun.</p>
        </div>
        <button 
          onClick={() => {
            setEditPackageId(null);
            setFormData({ title: "", description: "", isSequential: false, showResultsTime: "" });
            setSelectedExams([]);
            setSelectedGroups([]);
            setExamSearchTerm("");
            setGroupSearchTerm("");
            setShowModal(true);
          }}
          className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl transition-all font-bold shadow-sm"
        >
          <Plus className="w-4 h-4" /> Yeni Paket Oluştur
        </button>
      </div>

      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                setSearchQuery(searchInput);
              }
            }}
            placeholder="Paket ara..."
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium text-slate-700 outline-none focus:border-blue-500 shadow-sm transition-colors placeholder:text-slate-400"
          />
        </div>
        <div className="flex gap-2">
          <div className="relative">
            <ArrowUpDown className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="pl-10 pr-8 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-700 outline-none focus:border-blue-500 shadow-sm transition-colors appearance-none cursor-pointer"
            >
              <option value="newest">Son Eklenen</option>
              <option value="oldest">İlk Eklenen</option>
              <option value="updated">Son Düzenlenen</option>
              <option value="az">A → Z</option>
              <option value="za">Z → A</option>
            </select>
          </div>
          <span className="flex items-center px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-500">
            {filteredPackages.length} paket
          </span>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredPackages.map(pkg => (
          <div key={pkg.id} className="bg-white border border-slate-200 rounded-2xl p-6 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="p-3 bg-indigo-50 text-indigo-600 rounded-xl">
                <Layers className="w-6 h-6" />
              </div>
              <div className="flex gap-2">
                <Link 
                  href={`/muro-admin/sinavlar/paket/${pkg.id}/rapor`}
                  className="p-2 text-slate-400 hover:text-emerald-600 transition-colors"
                  title="Analiz Raporu"
                >
                  <BarChart className="w-5 h-5" />
                </Link>
                <button 
                  onClick={() => {
                    setEditPackageId(pkg.id);
                    setFormData({ title: pkg.title, description: pkg.description || "", isSequential: pkg.isSequential || false, showResultsTime: pkg.showResultsTime ? new Date(pkg.showResultsTime).toISOString().slice(0, 16) : "" });
                    setSelectedExams(pkg.exams.map((e:any) => e.id));
                    setSelectedGroups(pkg.groups ? pkg.groups.map((g:any) => g.id) : []);
                    setExamSearchTerm("");
                    setGroupSearchTerm("");
                    setShowModal(true);
                  }}
                  className="text-slate-400 hover:text-blue-500 transition-colors"
                  title="Düzenle"
                >
                  <Edit2 className="w-5 h-5" />
                </button>
                <button 
                  onClick={() => setDeletePackageId(pkg.id)} 
                  className="text-slate-400 hover:text-rose-500 transition-colors"
                  title="Sil"
                >
                  <Trash2 className="w-5 h-5" />
                </button>
              </div>
            </div>
            
            <h3 className="text-lg font-bold text-slate-800 mb-1">{pkg.title}</h3>
            <p className="text-sm text-slate-500 mb-4 h-10 line-clamp-2">{pkg.description || "Açıklama yok"}</p>
            
            <div className="bg-slate-50 rounded-xl p-3 border border-slate-100 mb-4">
              <h4 className="text-[10px] font-bold text-slate-400 uppercase mb-2">Bağlı Oturumlar</h4>
              <ul className="text-xs font-semibold text-slate-700 space-y-1">
                {pkg.exams.map((e: any) => (
                  <li key={e.id} className="flex items-center gap-2">
                    <BookOpen className="w-3 h-3 text-blue-500" /> {e.title}
                  </li>
                ))}
              </ul>
            </div>

            <div className="flex items-center justify-between pt-4 border-t border-slate-100">
              <span className="text-xs font-bold text-emerald-600">{pkg.results?.length || 0} Birleşik Karne</span>
              <button 
                onClick={() => setConfirmCalculateId(pkg.id)}
                disabled={calculatingId === pkg.id}
                className="flex items-center gap-2 text-xs font-bold px-3 py-1.5 bg-indigo-50 text-indigo-700 rounded-lg hover:bg-indigo-100 transition-colors disabled:opacity-50"
              >
                {calculatingId === pkg.id ? "Hesaplanıyor..." : <><Calculator className="w-3 h-3" /> Puanları Hesapla</>}
              </button>
            </div>
          </div>
        ))}
        {filteredPackages.length === 0 && (
           <div className="col-span-full py-16 text-center border-2 border-dashed border-slate-200 bg-white rounded-3xl">
             <Layers className="w-12 h-12 text-slate-300 mx-auto mb-3" />
             <p className="text-slate-500 font-medium mb-3">
               {searchQuery ? 'Arama sonucu bulunamadı.' : 'Henüz paket sınav oluşturulmamış.'}
             </p>
           </div>
        )}
      </div>

      {showModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-xl p-6 shadow-2xl max-h-[95vh] overflow-y-auto flex flex-col">
            <h2 className="text-xl font-bold mb-4">{editPackageId ? "Sınav Paketini Güncelle" : "Yeni Sınav Paketi"}</h2>
            <form onSubmit={handleCreate} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Paket Adı (Örn: 2026 KPSS Lisans)</label>
                <input required value={formData.title} onChange={e => setFormData({...formData, title: e.target.value})} className="w-full border p-3 rounded-xl outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all font-bold" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Açıklama</label>
                <textarea value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} className="w-full border p-3 rounded-xl outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all text-sm"></textarea>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-1">Paket Karnesi Açıklanma Tarihi (Opsiyonel)</label>
                <input type="datetime-local" value={formData.showResultsTime} onChange={e => setFormData({...formData, showResultsTime: e.target.value})} className="w-full border p-3 rounded-xl outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all text-sm font-bold text-slate-600" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-2">Pakete Dahil Edilecek Oturumlar (Sınavlar)</label>
                <div className="relative mb-2">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                  <input 
                    type="text" 
                    placeholder="Sınav ara..." 
                    value={examSearchTerm}
                    onChange={(e) => setExamSearchTerm(e.target.value)}
                    className="w-full border pl-9 pr-3 py-2 rounded-xl outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all text-sm"
                  />
                </div>
                <div className="max-h-48 overflow-y-auto space-y-2 border border-slate-200 rounded-xl p-3 bg-slate-50/50">
                  {allExams.filter(e => e.title.toLowerCase().includes(examSearchTerm.toLowerCase())).map(exam => (
                    <label key={exam.id} className={`flex items-center gap-3 p-3 bg-white rounded-lg border cursor-pointer transition-all ${selectedExams.includes(exam.id) ? 'border-blue-500 ring-1 ring-blue-500 bg-blue-50/30' : 'border-slate-200 hover:border-blue-300'}`}>
                      <input 
                        type="checkbox" 
                        checked={selectedExams.includes(exam.id)}
                        className="w-4 h-4 text-blue-600 rounded border-slate-300 focus:ring-blue-500 cursor-pointer accent-blue-600"
                        onChange={(e) => {
                          if (e.target.checked) setSelectedExams([...selectedExams, exam.id]);
                          else setSelectedExams(selectedExams.filter(id => id !== exam.id));
                        }}
                      />
                      <span className={`text-sm font-bold ${selectedExams.includes(exam.id) ? 'text-blue-700' : 'text-slate-700'}`}>{exam.title}</span>
                    </label>
                  ))}
                </div>
              </div>
              
              {/* Group Assignment */}
              <div>
                <label className="block text-xs font-bold text-slate-500 mb-2">Paketi Gruplara Ata (Opsiyonel)</label>
                <div className="relative mb-2">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                  <input 
                    type="text" 
                    placeholder="Grup ara..." 
                    value={groupSearchTerm}
                    onChange={(e) => setGroupSearchTerm(e.target.value)}
                    className="w-full border pl-9 pr-3 py-2 rounded-xl outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all text-sm"
                  />
                </div>
                <div className="max-h-48 overflow-y-auto space-y-2 border border-slate-200 rounded-xl p-3 bg-slate-50/50">
                  {allGroups.filter(g => g.name.toLowerCase().includes(groupSearchTerm.toLowerCase())).map(group => (
                    <label key={group.id} className={`flex items-center gap-3 p-3 bg-white rounded-lg border cursor-pointer transition-all ${selectedGroups.includes(group.id) ? 'border-amber-500 ring-1 ring-amber-500 bg-amber-50/30' : 'border-slate-200 hover:border-amber-300'}`}>
                      <input 
                        type="checkbox" 
                        checked={selectedGroups.includes(group.id)}
                        className="w-4 h-4 text-amber-600 rounded border-slate-300 focus:ring-amber-500 cursor-pointer accent-amber-600"
                        onChange={(e) => {
                          if (e.target.checked) setSelectedGroups([...selectedGroups, group.id]);
                          else setSelectedGroups(selectedGroups.filter(id => id !== group.id));
                        }}
                      />
                      <span className={`text-sm font-bold ${selectedGroups.includes(group.id) ? 'text-amber-700' : 'text-slate-700'}`}>{group.name}</span>
                    </label>
                  ))}
                  {allGroups.length === 0 && <p className="text-xs text-slate-400 font-medium">Henüz hiç grup oluşturulmamış.</p>}
                </div>
              </div>

              {/* isSequential Checkbox */}
              <div>
                <label className="flex items-center gap-3 p-3 bg-indigo-50/50 rounded-xl border border-indigo-100 cursor-pointer hover:bg-indigo-50 transition-colors">
                  <input 
                    type="checkbox" 
                    checked={formData.isSequential}
                    onChange={(e) => setFormData({...formData, isSequential: e.target.checked})}
                    className="w-5 h-5 text-indigo-600 rounded border-slate-300 focus:ring-indigo-500 cursor-pointer accent-indigo-600"
                  />
                  <div>
                    <span className="text-sm font-bold text-indigo-800 block">Sıralı İlerlemeyi Zorunlu Kıl (Oturum Kilidi)</span>
                    <span className="text-[10px] font-bold text-indigo-500">Öğrenciler 1. oturumu bitirmeden 2. oturuma giremez.</span>
                  </div>
                </label>
              </div>
              <div className="flex justify-end gap-3 pt-4 border-t border-slate-100">
                <button type="button" onClick={() => {
                  setShowModal(false);
                  setEditPackageId(null);
                }} className="px-5 py-2.5 rounded-xl font-bold text-slate-500 hover:bg-slate-100 transition-colors">İptal</button>
                <button type="submit" disabled={saving} className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold disabled:opacity-50 transition-all shadow-sm">
                  {saving ? "Kaydediliyor..." : (editPackageId ? "Güncelle" : "Oluştur")}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deletePackageId && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-sm p-6 shadow-2xl relative animate-in zoom-in-95">
            <button onClick={() => setDeletePackageId(null)} className="absolute top-4 right-4 text-slate-400 hover:bg-slate-100 p-2 rounded-full transition-colors">
              <X className="w-4 h-4" />
            </button>
            <div className="w-12 h-12 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center mb-4 mx-auto">
              <AlertTriangle className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-center text-slate-800 mb-2">Paketi Sil</h3>
            <p className="text-sm text-center text-slate-500 mb-6">
              Bu paketi silmek istediğinize emin misiniz? Altındaki sınavlar silinmez, sadece paket bağı kopar.
            </p>
            <div className="flex gap-3">
              <button onClick={() => setDeletePackageId(null)} className="flex-1 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl transition-colors">
                İptal
              </button>
              <button 
                onClick={async () => {
                  await deletePackage(deletePackageId);
                  setDeletePackageId(null);
                  fetchPackages();
                }} 
                className="flex-1 px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white font-bold rounded-xl shadow-md transition-colors"
              >
                Sil
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Calculate Scores Confirmation Modal */}
      {confirmCalculateId && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-sm p-6 shadow-2xl relative animate-in zoom-in-95">
            <button onClick={() => setConfirmCalculateId(null)} className="absolute top-4 right-4 text-slate-400 hover:bg-slate-100 p-2 rounded-full transition-colors">
              <X className="w-4 h-4" />
            </button>
            <div className="w-12 h-12 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center mb-4 mx-auto">
              <Calculator className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-center text-slate-800 mb-2">Puanları Hesapla</h3>
            <p className="text-sm text-center text-slate-500 mb-6">
              Bu paketteki tüm öğrencilerin sonuçları toplanıp KPSS/ÖSYM formülleriyle hesaplanacak. Onaylıyor musunuz?
            </p>
            <div className="flex gap-3">
              <button onClick={() => setConfirmCalculateId(null)} className="flex-1 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl transition-colors">
                İptal
              </button>
              <button 
                onClick={async () => {
                  const pkgId = confirmCalculateId;
                  setConfirmCalculateId(null);
                  await handleCalculate(pkgId);
                }} 
                className="flex-1 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl shadow-md transition-colors"
              >
                Hesapla
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
