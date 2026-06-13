"use client";

import { useState, useEffect } from "react";
import { getDocuments, deleteDocument } from "@/app/actions/documentActions";
import { FileText, Search, Plus, Trash2, Folder, Tag, AlertCircle, CheckCircle, X } from "lucide-react";
import { DocumentType } from "@prisma/client";
import dayjs from "dayjs";
import 'dayjs/locale/tr';
dayjs.locale('tr');

export default function DocumentArchivePage() {
  const [documents, setDocuments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<DocumentType>("EXAM_PDF");
  const [searchQuery, setSearchQuery] = useState("");
  const [isUploading, setIsUploading] = useState(false);
  const [showTagModal, setShowTagModal] = useState(false);
  const [pendingFile, setPendingFile] = useState<File | null>(null);
  
  // Yeni Form Alanları
  const [modalTitle, setModalTitle] = useState("");
  const [modalCategory, setModalCategory] = useState("");
  const [modalAcademicYear, setModalAcademicYear] = useState("");
  const [modalDescription, setModalDescription] = useState("");
  const [modalTags, setModalTags] = useState("");

  const [toast, setToast] = useState<{message: string, type: "success" | "error" | "info" | null}>({message: "", type: null});

  const showToast = (message: string, type: "success" | "error" | "info" = "success") => {
    setToast({ message, type });
    setTimeout(() => {
      setToast(prev => prev.message === message ? { message: "", type: null } : prev);
    }, 4000);
  };

  const fetchDocuments = async () => {
    setLoading(true);
    try {
      const docs = await getDocuments(activeTab, searchQuery);
      setDocuments(docs);
    } catch (err) {
      showToast("Dokümanlar yüklenemedi.", "error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDocuments();
  }, [activeTab, searchQuery]);

  const handleDelete = async (id: string) => {
    if (!confirm("Bu dokümanı arşivden silmek istediğinize emin misiniz? (Mevcut sınavlara bağlıysa o sınavlarda erişim kopabilir!)")) return;
    
    try {
      await deleteDocument(id);
      showToast("Doküman silindi.", "success");
      fetchDocuments();
    } catch (err: any) {
      showToast(err.message || "Silinemedi.", "error");
    }
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.size > 50 * 1024 * 1024) {
      showToast("Dosya boyutu 50MB sınırını aşamaz.", "error");
      return;
    }

    setPendingFile(file);
    setModalTitle("");
    setModalCategory("");
    setModalAcademicYear("");
    setModalDescription("");
    setModalTags("");
    setShowTagModal(true);
    
    if (e.target) e.target.value = ''; // Input'u temizle ki aynı dosyayı tekrar seçebilsin
  };

  const confirmUpload = async () => {
    if (!pendingFile) return;

    setIsUploading(true);
    setShowTagModal(false);

    const formData = new FormData();
    formData.append("file", pendingFile);
    formData.append("name", pendingFile.name);
    formData.append("type", activeTab);
    formData.append("title", modalTitle);
    formData.append("category", modalCategory);
    formData.append("academicYear", modalAcademicYear);
    formData.append("description", modalDescription);
    formData.append("tags", modalTags);

    try {
      const res = await fetch("/api/document", {
        method: "POST",
        body: formData
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Yükleme hatası");
      
      showToast("Doküman başarıyla arşive eklendi!", "success");
      fetchDocuments();
    } catch (err: any) {
      showToast(err.message, "error");
    } finally {
      setIsUploading(false);
      setPendingFile(null);
    }
  };

  const cancelUpload = () => {
    setShowTagModal(false);
    setPendingFile(null);
  };

  return (
    <div className="p-8 max-w-7xl mx-auto font-sans text-slate-800">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-black text-slate-900 flex items-center gap-3">
            <Folder className="w-8 h-8 text-blue-600" /> Doküman Arşivi
          </h1>
          <p className="text-slate-500 mt-2">Sistemdeki tüm sınav ve çözüm kitapçıklarını buradan yönetebilirsiniz.</p>
        </div>
        
        <div className="relative">
          <input 
            type="file" 
            id="docUpload" 
            className="hidden" 
            accept="application/pdf"
            onChange={handleFileSelect}
            disabled={isUploading}
          />
          <label 
            htmlFor="docUpload" 
            className={`px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl shadow-sm cursor-pointer flex items-center gap-2 transition-all ${isUploading ? 'opacity-70 pointer-events-none' : ''}`}
          >
            {isUploading ? (
              <span className="animate-pulse">Yükleniyor...</span>
            ) : (
              <><Plus className="w-5 h-5" /> Yeni {activeTab === "EXAM_PDF" ? "Sınav" : "Çözüm"} Yükle</>
            )}
          </label>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-4 border-b border-slate-200 mb-6">
        <button 
          onClick={() => setActiveTab("EXAM_PDF")}
          className={`px-6 py-3 font-bold text-sm border-b-2 transition-all ${activeTab === "EXAM_PDF" ? 'border-blue-600 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-800'}`}
        >
          Sınav Kitapçıkları
        </button>
        <button 
          onClick={() => setActiveTab("SOLUTION_PDF")}
          className={`px-6 py-3 font-bold text-sm border-b-2 transition-all ${activeTab === "SOLUTION_PDF" ? 'border-blue-600 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-800'}`}
        >
          Çözüm Kitapçıkları
        </button>
      </div>

      <div className="flex justify-between items-center mb-6">
        <div className="relative w-full max-w-md">
          <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input 
            type="text" 
            placeholder="Doküman adı veya etiket ara..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 outline-none transition-all shadow-sm"
          />
        </div>
        
        <div className="text-sm text-slate-500 font-medium">
          Toplam <span className="text-slate-800 font-bold">{documents.length}</span> kayıt bulundu
        </div>
      </div>

      {loading ? (
        <div className="py-20 text-center text-slate-500 font-bold animate-pulse">Dokümanlar Yükleniyor...</div>
      ) : documents.length === 0 ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-12 text-center shadow-sm">
          <FileText className="w-16 h-16 text-slate-300 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-slate-800 mb-2">Doküman Bulunamadı</h3>
          <p className="text-slate-500">Bu kategoride henüz bir PDF yüklenmemiş veya aramanızla eşleşen sonuç yok.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {documents.map(doc => (
            <div key={doc.id} className="relative bg-white border border-slate-200 rounded-2xl p-5 shadow-sm hover:shadow-md transition-all group flex flex-col">
              
              {/* Silme Butonu (Linkin Dışında) */}
              <div className="absolute top-4 right-4 z-10">
                <button 
                  onClick={(e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    handleDelete(doc.id);
                  }} 
                  className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors opacity-0 group-hover:opacity-100"
                  title="Sil"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              {/* Tıklanabilir Kart Alanı */}
              <a href={doc.url} target="_blank" rel="noopener noreferrer" className="flex flex-col flex-1">
                <div className="flex justify-between items-start mb-4">
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${activeTab === "EXAM_PDF" ? 'bg-blue-50 text-blue-600' : 'bg-emerald-50 text-emerald-600'}`}>
                    <FileText className="w-6 h-6" />
                  </div>
                </div>
                
                <h3 className="font-bold text-slate-800 mb-1 line-clamp-2 hover:text-blue-600 transition-colors" title={doc.title || doc.name}>
                  {doc.title || doc.name}
                </h3>
                
                {doc.description && (
                  <p className="text-xs text-slate-500 mb-3 line-clamp-2">{doc.description}</p>
                )}
                
                <div className="flex flex-wrap gap-2 mb-4 mt-auto">
                  {doc.academicYear && (
                    <span className="px-2 py-1 bg-purple-50 text-purple-700 border border-purple-100 rounded-lg text-[10px] font-bold">
                      {doc.academicYear}
                    </span>
                  )}
                  {doc.category && (
                    <span className="px-2 py-1 bg-amber-50 text-amber-700 border border-amber-100 rounded-lg text-[10px] font-bold">
                      {doc.category}
                    </span>
                  )}
                  {doc.tags ? doc.tags.split(',').map((t: string, i: number) => (
                    <span key={i} className="px-2 py-1 bg-slate-100 text-slate-600 rounded-lg text-[10px] font-bold flex items-center gap-1 uppercase">
                      <Tag className="w-3 h-3" /> {t.trim()}
                    </span>
                  )) : (
                    !doc.category && !doc.academicYear && <span className="text-xs text-slate-400 italic">Etiket yok</span>
                  )}
                </div>
                
                <div className="flex items-center justify-between pt-4 border-t border-slate-100 mt-auto">
                  <span className="text-xs font-bold text-slate-500">
                    {doc.sizeBytes ? (doc.sizeBytes / (1024 * 1024)).toFixed(2) + " MB" : "Bilinmiyor"}
                  </span>
                  <span className="text-xs font-bold text-slate-400">
                    {dayjs(doc.createdAt).format("DD MMM YYYY")}
                  </span>
                </div>
              </a>
            </div>
          ))}
        </div>
      )}
      
      {/* Gelişmiş Doküman Pop-up (Modal) */}
      {showTagModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl shadow-xl w-full max-w-lg overflow-hidden animate-in fade-in zoom-in-95 duration-200 flex flex-col max-h-[90vh]">
            <div className="p-6 overflow-y-auto custom-scrollbar">
              <div className="flex items-center gap-3 mb-6 border-b border-slate-100 pb-4">
                <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center shrink-0">
                  <FileText className="w-6 h-6 text-blue-600" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-slate-800">Doküman Detayları</h3>
                  <p className="text-xs text-slate-500 truncate max-w-[300px]" title={pendingFile?.name}>{pendingFile?.name}</p>
                </div>
              </div>
              
              <div className="space-y-4 mb-6">
                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-1">
                    Kullanıcı Dostu Başlık <span className="text-slate-400 font-normal">(Opsiyonel)</span>
                  </label>
                  <input 
                    type="text" 
                    value={modalTitle}
                    onChange={(e) => setModalTitle(e.target.value)}
                    placeholder="Örn: 2021 KPSS Lisans GYGK Çıkmış Sorular"
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all"
                    autoFocus
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-1">Kategori / Tür</label>
                    <select 
                      value={modalCategory}
                      onChange={(e) => setModalCategory(e.target.value)}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all text-sm"
                    >
                      <option value="">Seçiniz...</option>
                      <option value="TYT">TYT</option>
                      <option value="AYT">AYT</option>
                      <option value="YKS">YKS (Genel)</option>
                      <option value="LGS">LGS</option>
                      <option value="KPSS">KPSS</option>
                      <option value="DGS">DGS</option>
                      <option value="ALES">ALES</option>
                      <option value="YDS">YDS</option>
                      <option value="Kurum İçi">Kurum İçi Sınav</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-slate-700 mb-1">Eğitim Yılı</label>
                    <select 
                      value={modalAcademicYear}
                      onChange={(e) => setModalAcademicYear(e.target.value)}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all text-sm"
                    >
                      <option value="">Seçiniz...</option>
                      <option value="2024-2025">2024-2025</option>
                      <option value="2023-2024">2023-2024</option>
                      <option value="2022-2023">2022-2023</option>
                      <option value="Çıkmış Soru">Çıkmış Soru</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-1">
                    Serbest Etiketler <span className="text-slate-400 font-normal">(Virgülle ayırın)</span>
                  </label>
                  <input 
                    type="text" 
                    value={modalTags}
                    onChange={(e) => setModalTags(e.target.value)}
                    placeholder="Örn: Matematik, Zor, Deneme 1"
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all"
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') confirmUpload();
                      if (e.key === 'Escape') cancelUpload();
                    }}
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-slate-700 mb-1">Kısa Açıklama / Notlar</label>
                  <textarea 
                    value={modalDescription}
                    onChange={(e) => setModalDescription(e.target.value)}
                    placeholder="Bu dokümanla ilgili eklemek istediğiniz notlar..."
                    rows={2}
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all resize-none text-sm"
                  ></textarea>
                </div>
              </div>
              
              <div className="flex gap-3 pt-2">
                <button 
                  onClick={cancelUpload}
                  className="flex-1 py-3 px-4 font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors"
                >
                  İptal
                </button>
                <button 
                  onClick={confirmUpload}
                  className="flex-1 py-3 px-4 font-bold text-white bg-blue-600 hover:bg-blue-700 rounded-xl shadow-md shadow-blue-500/20 transition-all"
                >
                  Dosyayı Arşive Ekle
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Toast Notification */}
      {toast.type && (
        <div className="fixed bottom-6 right-6 z-[60] animate-in slide-in-from-bottom-8 fade-in duration-300">
          <div className={`flex items-center gap-3 px-5 py-4 rounded-2xl shadow-xl shadow-slate-900/10 border ${
            toast.type === "success" ? "bg-emerald-50 border-emerald-200 text-emerald-800" :
            toast.type === "error" ? "bg-rose-50 border-rose-200 text-rose-800" :
            "bg-blue-50 border-blue-200 text-blue-800"
          }`}>
            {toast.type === "success" && <div className="w-8 h-8 rounded-full bg-emerald-100 flex items-center justify-center shrink-0"><CheckCircle className="w-5 h-5 text-emerald-600" /></div>}
            {toast.type === "error" && <div className="w-8 h-8 rounded-full bg-rose-100 flex items-center justify-center shrink-0"><AlertCircle className="w-5 h-5 text-rose-600" /></div>}
            {toast.type === "info" && <div className="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center shrink-0"><AlertCircle className="w-5 h-5 text-blue-600" /></div>}
            <span className="font-bold text-sm tracking-wide">{toast.message}</span>
            <button onClick={() => setToast({message: "", type: null})} className="ml-4 text-slate-400 hover:text-slate-600 transition-colors p-1.5 rounded-full hover:bg-black/5">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
