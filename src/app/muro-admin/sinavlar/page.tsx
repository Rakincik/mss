"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { BookOpen, Plus, Trash2, KeyRound, UploadCloud, Users, Pencil, CalendarClock, ChevronRight, ChevronLeft, Loader2, Trophy, Eye, EyeOff, Search, ArrowUpDown } from "lucide-react";
import { getExams, createExam, deleteExam, saveQuestionKeys, updateExamDetails, updateExamFull, toggleExamResultsStatus, toggleExamActiveStatus } from "@/app/actions/examActions";
import { getGroups } from "@/app/actions/userActions";
import { getDocuments } from "@/app/actions/documentActions";
import PackageExams from "@/components/admin/PackageExams";

export default function SinavlarPage() {
  const [activeTab, setActiveTab] = useState<'exams' | 'packages'>('exams');
  const [exams, setExams] = useState<any[]>([]);
  const [groups, setGroups] = useState<any[]>([]);
  const [examDocuments, setExamDocuments] = useState<any[]>([]);
  const [solutionDocuments, setSolutionDocuments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [sortBy, setSortBy] = useState('newest');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchInput, setSearchInput] = useState('');

  // Modals
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedExamForKeys, setSelectedExamForKeys] = useState<any>(null);
  const [selectedExamForEdit, setSelectedExamForEdit] = useState<any>(null);
  const [editStep, setEditStep] = useState(1);
  const [createStep, setCreateStep] = useState(1);

  // Exam Form State
  const [selectedGroups, setSelectedGroups] = useState<string[]>([]);
  const [savingExam, setSavingExam] = useState(false);
  const [sectionsBuilder, setSectionsBuilder] = useState<{id: string, title: string, count: number | string, points: number | string}[]>([{id: Date.now().toString(), title: "Genel Test", count: 40, points: 1.0}]);
  const [editSectionsBuilder, setEditSectionsBuilder] = useState<{id: string, title: string, count: number | string, points: number | string}[]>([]);
  
  // Step 3 (Wizard) Keys State
  const [createWizardKeys, setCreateWizardKeys] = useState<{questionNumber: number, correctOption: string, topic: string, points: number, videoUrl: string}[]>([]);
  const [activeWizardSectionId, setActiveWizardSectionId] = useState<string | null>(null);

  // Question Keys Form State
  const [keysState, setKeysState] = useState<{questionNumber: number, correctOption: string, topic: string, points: number, videoUrl: string}[]>([]);
  const [savingKeys, setSavingKeys] = useState(false);
  const [expandedKeyIdx, setExpandedKeyIdx] = useState<number | null>(null);
  const [activeOpticSectionId, setActiveOpticSectionId] = useState<string | null>(null);
  const [examTemplate, setExamTemplate] = useState("CUSTOM");

  const handleEditSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (editStep === 1) { setEditStep(2); return; }
    if (editStep === 2) { setEditStep(3); return; }
    if (editStep === 3) { setEditStep(4); return; }
    
    setSavingExam(true);
    const formData = new FormData(e.currentTarget);
    
    // Validation
    const startStr = formData.get("startTime") as string;
    const endStr = formData.get("endTime") as string;
    if (startStr && endStr && new Date(startStr) >= new Date(endStr)) {
      alert("Sınav bitiş tarihi, başlama tarihinden önce olamaz!");
      setSavingExam(false);
      return;
    }

    try {
      formData.append("sections", JSON.stringify(editSectionsBuilder));
      formData.append("groups", JSON.stringify(selectedGroups));
      
      const res = await updateExamFull(selectedExamForEdit.id, formData);
      
      // Save Question Keys
      await saveQuestionKeys(selectedExamForEdit.id, keysState);
      
      setShowEditModal(false);
      setSelectedExamForEdit(null);
      setEditStep(1);
      fetchData();
    } catch (err: any) {
      alert("Hata: " + err.message);
    } finally {
      setSavingExam(false);
    }
  };

  const fetchData = async (page?: number, sort?: string, search?: string) => {
    setLoading(true);
    const p = page ?? currentPage;
    const s = sort ?? sortBy;
    const q = search ?? searchQuery;
    const [examResult, fetchedGroups, fetchedDocs] = await Promise.all([
      getExams({ page: p, pageSize: 12, sortBy: s, search: q }),
      getGroups(),
      getDocuments()
    ]);
    setExams(examResult.exams);
    setTotalPages(examResult.totalPages);
    setTotalCount(examResult.totalCount);
    setGroups(fetchedGroups);
    setExamDocuments(fetchedDocs.filter((d: any) => d.type === "EXAM_PDF"));
    setSolutionDocuments(fetchedDocs.filter((d: any) => d.type === "SOLUTION_PDF"));
    setLoading(false);
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleToggleResults = async (exam: any) => {
    try {
      await toggleExamResultsStatus(exam.id, exam.isResultsPublished);
      fetchData();
    } catch (e) {
      alert("Durum değiştirilirken hata oluştu.");
    }
  };

  const handleToggleActive = async (exam: any) => {
    try {
      await toggleExamActiveStatus(exam.id, exam.isActive);
      fetchData();
    } catch (e) {
      alert("Aktif/Pasif durumu değiştirilirken hata oluştu.");
    }
  };

  // SINAV OLUŞTURMA İŞLEMİ
  const handleInitializeWizardKeys = () => {
    let emptyKeys = [];
    let currentQuestionNum = 1;

    for (const sec of sectionsBuilder) {
      const cCount = typeof sec.count === 'string' ? parseInt(sec.count) || 0 : sec.count || 0;
      for (let i = 0; i < cCount; i++) {
        emptyKeys.push({
          questionNumber: currentQuestionNum,
          correctOption: "A",
          topic: sec.title,
          points: typeof sec.points === 'string' ? parseFloat(sec.points) || 1.0 : sec.points || 1.0,
          videoUrl: ""
        });
        currentQuestionNum++;
      }
    }
    
    // Yalnızca uzunluk uyuşmazsa ez (kullanıcı girdi yaptıysa ve soru sayısı değişmediyse verisini kaybetmemek için)
    if (createWizardKeys.length !== currentQuestionNum - 1) {
      setCreateWizardKeys(emptyKeys);
    }
    if (sectionsBuilder.length > 0) setActiveWizardSectionId(sectionsBuilder[0].id);
  };

  const handleCreateSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (createStep === 1) {
      setCreateStep(2);
      return; // Stop form submission, we only submit on step 2
    }
    if (createStep === 2) {
      handleInitializeWizardKeys();
      setCreateStep(3);
      return; 
    }
    
    setSavingExam(true);
    const formData = new FormData(e.currentTarget);
    
    // Validation
    const startStr = formData.get("startTime") as string;
    const endStr = formData.get("endTime") as string;
    if (startStr && endStr && new Date(startStr) >= new Date(endStr)) {
      alert("Sınav bitiş tarihi, başlama tarihinden önce olamaz!");
      setSavingExam(false);
      return;
    }
    
    formData.append("groups", JSON.stringify(selectedGroups));
    formData.append("sections", JSON.stringify(sectionsBuilder));
    formData.append("keysData", JSON.stringify(createWizardKeys));
    
    try {
      const res = await fetch("/api/upload", {
        method: "POST",
        body: formData,
      });
      
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Sunucu hatası.");
      
      setShowCreateModal(false);
      setCreateStep(1);
      setCreateWizardKeys([]);
      setSectionsBuilder([{id: Date.now().toString(), title: "Genel Test", count: 40, points: 1.0}]);
      fetchData();
    } catch (err: any) {
      alert("Hata: " + err.message);
    } finally {
      setSavingExam(false);
    }
  };

  const updateWizardKey = (index: number, field: string, value: any) => {
    let copy = [...createWizardKeys];
    (copy[index] as any)[field] = value;
    setCreateWizardKeys(copy);
  };

  // GRUP SEÇİMİ (Multi-select / Checkbox mantığı)
  const toggleGroup = (id: string) => {
    setSelectedGroups(prev => prev.includes(id) ? prev.filter(gId => gId !== id) : [...prev, id]);
  };

  // ANAHTAR VERİSİNİ HAZIRLAMA (DÜZENLEME MODALI İÇİN)
  const prepareKeysState = (exam: any) => {
    // Determine active section
    let parsedSections = exam.sections;
    if (typeof parsedSections === "string") parsedSections = JSON.parse(parsedSections);
    
    if (parsedSections && parsedSections.length > 0) {
      setActiveOpticSectionId(parsedSections[0].id);
    } else {
      setActiveOpticSectionId(null);
    }

    // Sınavın mevcut anahtarlarını al veya boşlarını doldur
    const existing = exam.keys || [];
    let stateList = [];
    for (let i = 1; i <= exam.questionCount; i++) {
      const found = existing.find((k: any) => k.questionNumber === i);
      stateList.push({
        questionNumber: i,
        correctOption: found ? found.correctOption : "A",
        topic: found ? found.topic || "" : "",
        points: found ? found.points || 1 : 1,
        videoUrl: found ? found.videoUrl || "" : ""
      });
    }
    setKeysState(stateList);
  };

  // ANAHTAR STATE GÜNCELLEME
  const updateKey = (index: number, field: "correctOption" | "topic" | "points" | "videoUrl", value: string | number) => {
    setKeysState(prev => {
      const copy = [...prev];
      copy[index] = { ...copy[index], [field]: value };
      return copy;
    });
  };

  const handleSaveKeys = async () => {
    setSavingKeys(true);
    try {
      await saveQuestionKeys(selectedExamForKeys.id, keysState);
      setSelectedExamForKeys(null);
      fetchData();
    } catch (err) {
      alert("Hata oluştu.");
    } finally {
      setSavingKeys(false);
    }
  };

  // Zaman dilimi sapmasını (UTC to Local) önlemek için datetime-local string üretici (YYYY-MM-DDTHH:mm)
  const toLocalISOString = (dateVal: any) => {
    if (!dateVal) return "";
    const d = new Date(dateVal);
    if (isNaN(d.getTime())) return "";
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
  };

  return (
    <div className="max-w-7xl mx-auto text-slate-800 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-slate-800">Sınavlar</h1>
          <p className="text-slate-500 mt-2 text-sm">Deneme sınavlarını, ilgili PDF'leri ve optik cevap anahtarlarını yönetin.</p>
        </div>
        <button 
          onClick={() => { setSelectedGroups([]); setShowCreateModal(true); setCreateStep(1); }}
          className="flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl transition-all font-bold shadow-sm active:scale-95 text-sm"
        >
          <Plus className="w-4 h-4" /> Yeni Sınav Yükle
        </button>
      </div>
      
      <div className="flex gap-6 border-b border-slate-200 mb-6 overflow-x-auto custom-scrollbar">
        <button onClick={() => setActiveTab('exams')} className={`pb-3 px-4 font-bold transition-all whitespace-nowrap flex items-center gap-2 ${activeTab === 'exams' ? 'border-b-2 border-blue-600 text-blue-600' : 'text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded-t-xl'}`}>
          <BookOpen className="w-4 h-4" /> Bireysel Oturumlar
        </button>
        <button onClick={() => setActiveTab('packages')} className={`pb-3 px-4 font-bold transition-all whitespace-nowrap flex items-center gap-2 ${activeTab === 'packages' ? 'border-b-2 border-indigo-600 text-indigo-600' : 'text-slate-500 hover:text-slate-700 hover:bg-slate-50 rounded-t-xl'}`}>
           Paket (Çoklu Oturum) Sınavlar
        </button>
      </div>

      {activeTab === "packages" ? (
        <PackageExams allExams={exams} allGroups={groups} />
      ) : (
        <>
        {/* Arama + Sıralama Toolbar */}
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
                  setCurrentPage(1);
                  fetchData(1, sortBy, searchInput);
                }
              }}
              placeholder="Sınav ara..."
              className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium text-slate-700 outline-none focus:border-blue-500 shadow-sm transition-colors placeholder:text-slate-400"
            />
          </div>
          <div className="flex gap-2">
            <div className="relative">
              <ArrowUpDown className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
              <select
                value={sortBy}
                onChange={(e) => {
                  setSortBy(e.target.value);
                  setCurrentPage(1);
                  fetchData(1, e.target.value, searchQuery);
                }}
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
              {totalCount} sınav
            </span>
          </div>
        </div>

        {loading ? (
          <div className="py-20 text-center text-slate-400 font-medium">Sınavlar yükleniyor...</div>
        ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {exams.map(exam => (
            <div key={exam.id} className="bg-white border border-slate-200 rounded-2xl flex flex-col overflow-hidden hover:shadow-md transition-all group shadow-sm">
              <div className="p-6 flex-1 relative">
                {/* Decorative blob */}
                <div className="absolute top-0 right-0 w-32 h-32 bg-blue-50/50 rounded-full blur-2xl -mr-10 -mt-10"></div>
                
                <div className="flex justify-between items-start mb-4 relative z-10">
                  <div className="p-3 bg-blue-50 text-blue-600 rounded-xl border border-blue-100">
                    <BookOpen className="w-6 h-6" />
                  </div>
                  <button 
                    onClick={() => handleToggleResults(exam)}
                    className={`px-3 py-1.5 text-[10px] uppercase tracking-widest font-bold rounded-lg border shadow-sm transition-colors active:scale-95 ${exam.isResultsPublished ? 'bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100' : 'bg-slate-100 text-slate-500 border-slate-200 hover:bg-slate-200'}`}
                  >
                    {exam.isResultsPublished ? "👁️ Karneler Açık" : "🔒 Karneler Gizli"}
                  </button>
                </div>
                <h3 className="text-lg font-bold mb-1 text-slate-800 truncate relative z-10" title={exam.title}>
                  <Link href={`/muro-admin/sinavlar/${exam.id}`} className="hover:text-blue-600 transition-colors">{exam.title}</Link>
                </h3>
                <p className="text-xs font-semibold text-slate-500 mb-6 line-clamp-2 min-h-[32px] relative z-10">{exam.description || "Açıklama yok."}</p>
                
                <div className="grid grid-cols-2 gap-4 text-sm bg-slate-50 rounded-xl p-3 border border-slate-100 relative z-10">
                  <div>
                    <span className="block text-slate-400 text-[10px] font-bold uppercase tracking-widest mb-0.5">Soru Sayısı</span>
                    <strong className="text-slate-800">{exam.questionCount}</strong>
                  </div>
                  <div>
                    <span className="block text-slate-400 text-[10px] font-bold uppercase tracking-widest mb-0.5">Atanan Grup</span>
                    <strong className="text-slate-800">{exam.groups?.length || 0}</strong>
                  </div>
                </div>
              </div>
              
              <div className="bg-slate-50 border-t border-slate-100 p-4 flex flex-col gap-3">
                <Link 
                  href={`/muro-admin/sinavlar/${exam.id}`}
                  className="w-full flex justify-center items-center gap-2 px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow-sm transition-colors text-sm group"
                >
                  <Trophy className="w-4 h-4 group-hover:scale-110 transition-transform" /> 
                  Sınav Detayı ve Karneler
                </Link>
                
                <div className="flex items-center justify-between mt-1">
                  <div className="flex gap-2">
                    <a href={exam.pdfUrl} target="_blank" className="p-2 bg-white border border-slate-200 rounded-lg text-slate-500 hover:text-blue-600 hover:border-blue-200 transition-colors shadow-sm" title="Soru Kitapçığını PDF Olarak Aç"><BookOpen className="w-4 h-4"/></a>
                  <button 
                    onClick={() => { setSelectedExamForEdit(exam); prepareKeysState(exam); setEditSectionsBuilder(exam.sections || [{id: Date.now().toString(), title: "Genel Test", count: exam.questionCount || 40, points: 1.0}]); setSelectedGroups(exam.groups ? exam.groups.map((g: any) => g.id) : []); setExamTemplate(exam.examTemplate || "CUSTOM"); setShowEditModal(true); setEditStep(1); }}
                    title="Sınavı Düzenle"
                    className="flex justify-center items-center gap-2 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-amber-600 font-bold text-xs hover:border-amber-200 hover:bg-amber-50 transition-colors shadow-sm"
                  >
                    <Pencil className="w-4 h-4" /> Düzenle
                  </button>
                  <button onClick={async () => { await deleteExam(exam.id); fetchData(); }} className="p-2 bg-white border border-slate-200 rounded-lg text-slate-500 hover:text-red-500 hover:border-red-200 hover:bg-red-50 transition-colors shadow-sm">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
                <button 
                  onClick={async () => handleToggleActive(exam)} 
                  className={`flex items-center gap-2 px-3 py-1.5 border rounded-lg font-bold text-xs transition-colors shadow-sm ${exam.isActive !== false ? 'bg-emerald-50 border-emerald-200 text-emerald-600 hover:text-slate-500 hover:bg-slate-100 hover:border-slate-300' : 'bg-slate-100 border-slate-300 text-slate-500 hover:text-emerald-600 hover:border-emerald-200 hover:bg-emerald-50'}`}
                >
                  <div className={`w-2 h-2 rounded-full ${exam.isActive !== false ? 'bg-emerald-500' : 'bg-slate-400'}`}></div>
                  {exam.isActive !== false ? "Sınav Yayında" : "Sınav Pasif"}
                </button>
              </div>
            </div>
          </div>
          ))}
          {exams.length === 0 && (
            <div className="col-span-full py-16 text-center border-2 border-dashed border-slate-200 bg-white rounded-3xl">
              <BookOpen className="w-12 h-12 text-slate-300 mx-auto mb-3" />
              <p className="text-slate-500 font-medium mb-3">{searchQuery ? 'Arama sonucu bulunamadı.' : 'Henüz sınav yüklenmemiş.'}</p>
              {!searchQuery && <button onClick={() => setShowCreateModal(true)} className="text-blue-600 font-bold hover:underline">İlk sınavı yükle</button>}
            </div>
          )}
        </div>
        )}

        {/* Sayfalama */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-2 mt-8">
            <button
              onClick={() => { const p = currentPage - 1; setCurrentPage(p); fetchData(p); }}
              disabled={currentPage === 1}
              className="flex items-center gap-1 px-4 py-2 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors shadow-sm"
            >
              <ChevronLeft className="w-4 h-4" /> Önceki
            </button>
            <div className="flex gap-1">
              {Array.from({ length: totalPages }, (_, i) => i + 1)
                .filter(p => p === 1 || p === totalPages || Math.abs(p - currentPage) <= 1)
                .map((p, idx, arr) => (
                  <span key={p}>
                    {idx > 0 && arr[idx - 1] !== p - 1 && <span className="px-2 py-2 text-slate-400">...</span>}
                    <button
                      onClick={() => { setCurrentPage(p); fetchData(p); }}
                      className={`w-10 h-10 rounded-xl text-sm font-bold transition-colors shadow-sm ${
                        p === currentPage
                          ? 'bg-blue-600 text-white'
                          : 'bg-white border border-slate-200 text-slate-600 hover:bg-slate-50'
                      }`}
                    >
                      {p}
                    </button>
                  </span>
                ))}
            </div>
            <button
              onClick={() => { const p = currentPage + 1; setCurrentPage(p); fetchData(p); }}
              disabled={currentPage === totalPages}
              className="flex items-center gap-1 px-4 py-2 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors shadow-sm"
            >
              Sonraki <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        )}
        </>
      )}

      {/* SINAV OLUŞTURMA MODALI */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white border border-slate-200 rounded-3xl w-full max-w-4xl shadow-2xl flex flex-col max-h-[90vh] animate-in fade-in zoom-in-95">
            <div className="p-6 border-b border-slate-100 flex justify-between items-center shrink-0 bg-slate-50 rounded-t-3xl">
              <h2 className="text-2xl font-bold flex items-center gap-2 text-blue-600">
                <Plus className="w-6 h-6" /> Yeni Sınav Yükle
              </h2>
              <button type="button" onClick={() => { setShowCreateModal(false); setCreateStep(1); }} className="text-slate-400 hover:text-slate-700 bg-white border border-slate-200 hover:bg-slate-100 p-1.5 rounded-full transition-colors shadow-sm font-bold">✕</button>
            </div>
            
            <form 
              onSubmit={handleCreateSubmit} 
              onKeyDown={(e) => {
                if (e.key === 'Enter' && (e.target as HTMLElement).tagName !== 'TEXTAREA') {
                  e.preventDefault();
                }
              }}
              className="flex flex-col flex-1 overflow-y-auto custom-scrollbar relative"
            >
              {/* Sekmeler / Stepper */}
              <div className="flex gap-2 border-b border-slate-100 pb-4 mb-5 px-6 pt-6 shrink-0">
                 <button type="button" onClick={() => setCreateStep(1)} className={`flex-1 py-3 px-2 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${createStep === 1 ? 'bg-blue-600 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>1. Sınav Kapsamı & Dosyalar</button>
                 <button type="button" onClick={() => { if(createStep<2) handleInitializeWizardKeys(); setCreateStep(2); }} className={`flex-1 py-3 px-2 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${createStep === 2 ? 'bg-blue-600 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>2. Puanlama & Takvim</button>
                 <button type="button" onClick={() => { handleInitializeWizardKeys(); setCreateStep(3); }} className={`flex-1 py-3 px-2 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${createStep === 3 ? 'bg-emerald-500 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>3. Cevap Anahtarı</button>
              </div>
              <div className="relative px-6">
                {/* STEP 1 */}
                <div className={`grid grid-cols-1 md:grid-cols-2 gap-6 ${createStep === 1 ? 'block animate-in fade-in slide-in-from-left-4' : 'hidden'}`}>
                  <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 shadow-sm h-fit">
                    <h3 className="font-bold text-slate-800 mb-1 flex items-center gap-2"><BookOpen className="w-5 h-5 text-blue-500"/> Sınav Kapsamı</h3>
                    <p className="text-xs text-slate-500 mb-6 font-medium">Sınav dosyası yetkisiz indirilemez şekilde optimize edilecektir.</p>
                    
                    <div className="space-y-4">
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Sınav Adı</label>
                        <input name="title" required className="w-full bg-white border border-slate-200 rounded-xl p-3 text-slate-800 font-bold placeholder:font-medium placeholder:text-slate-400 outline-none focus:border-blue-500 shadow-sm transition-colors" placeholder="Örn: TYT Türkiye Geneli 1" />
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Açıklama</label>
                        <textarea name="description" className="w-full bg-white border border-slate-200 rounded-xl p-3 text-slate-800 font-bold placeholder:font-medium placeholder:text-slate-400 outline-none focus:border-blue-500 shadow-sm transition-colors" placeholder="Kısa notlar..."></textarea>
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Bölümler / Testler (Optik Yapısı)</label>
                        <div className="space-y-2 mb-2">
                           {sectionsBuilder.map((sec, idx) => (
                             <div key={sec.id} className="flex gap-2 items-center">
                               <input value={sec.title} onChange={e => {
                                 let copy = [...sectionsBuilder];
                                 copy[idx].title = e.target.value;
                                 setSectionsBuilder(copy);
                               }} className="flex-1 w-full min-w-[60px] border p-2 text-sm rounded bg-white shadow-sm font-bold text-slate-700 outline-none" placeholder="Türkçe Testi" />
                               <div className="relative">
                                 <input type="number" value={sec.count} onChange={e => {
                                   let copy = [...sectionsBuilder];
                                   copy[idx].count = e.target.value;
                                   setSectionsBuilder(copy);
                                 }} className="w-14 sm:w-16 border p-2 text-sm rounded text-center bg-white font-bold outline-none shadow-sm" placeholder="40" />
                                 <span className="absolute -top-2 left-1/2 -translate-x-1/2 bg-white text-[8px] font-black tracking-wider text-slate-400 px-1.5 rounded shadow-[0_0_2px_rgba(0,0,0,0.15)] ring-1 ring-slate-100 z-10 w-max leading-tight">SORU</span>
                               </div>
                               <div className="relative">
                                 <input type="number" step="0.1" value={sec.points} onChange={e => {
                                   let copy = [...sectionsBuilder];
                                   copy[idx].points = e.target.value;
                                   setSectionsBuilder(copy);
                                 }} className="w-14 sm:w-16 border border-amber-200 bg-amber-50 p-2 text-sm rounded text-center font-bold text-amber-700 outline-none shadow-sm" placeholder="1.0" />
                                 <span className="absolute -top-2 left-1/2 -translate-x-1/2 bg-amber-200/90 backdrop-blur-sm text-[8px] font-black tracking-wider text-amber-800 px-1.5 rounded shadow-[0_0_2px_rgba(0,0,0,0.15)] ring-1 ring-amber-300 z-10 w-max leading-tight">KATSAYI</span>
                               </div>
                               {sectionsBuilder.length > 1 && (
                                 <button type="button" onClick={() => setSectionsBuilder(sectionsBuilder.filter(s => s.id !== sec.id))} className="text-red-500 p-1.5 hover:bg-red-50 hover:text-red-600 rounded-lg transition-colors shrink-0"><Trash2 className="w-4 h-4"/></button>
                               )}
                             </div>
                           ))}
                        </div>
                        <div className="flex justify-between items-center">
                           <button type="button" onClick={() => setSectionsBuilder([...sectionsBuilder, {id: Date.now().toString(), title: "Yeni Test", count: 20, points: 1.0}])} className="text-[10px] font-black tracking-widest uppercase text-blue-600 border border-blue-200 bg-blue-50/50 px-3 py-1.5 rounded hover:bg-blue-100 flex items-center gap-1 transition-colors"><Plus className="w-3 h-3"/> Bölüm Ekle</button>
                           <span className="text-[10px] font-black tracking-wider text-slate-400">TOPLAM: {sectionsBuilder.reduce((a,b)=>a+Number(b.count||0),0)} SORU</span>
                        </div>
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Sanal Hedef Katılımcı (Derece Çarpanı)</label>
                        <input name="virtualTotalParticipants" type="number" min="1" className="w-full bg-white border border-slate-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-blue-500 shadow-sm transition-colors placeholder:text-slate-300" placeholder="Örn: 1500 (Opsiyonel)" />
                      </div>
                    </div>
                  </div>

                  <div className="space-y-6 h-fit">
                  {/* Dosya Yüklemeleri */}
                  <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 shadow-sm">
                    <h3 className="font-bold text-emerald-600 mb-1 flex items-center gap-2"><UploadCloud className="w-5 h-5"/> Dosyalar</h3>
                    <p className="text-xs text-slate-500 mb-6 font-medium">Sınav ve Çözüm PDF'lerini Doküman Arşivinden seçebilir veya bilgisayarınızdan yeni (Max 50MB) yükleyebilirsiniz.</p>
                    
                    <div className="space-y-5">
                      <div className="bg-white p-4 border border-slate-200 rounded-xl shadow-sm">
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-3">Ana Sınav PDF'i *</label>
                        <select name="existingPdfUrl" className="w-full text-sm text-slate-700 bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-lg mb-3 outline-none focus:border-emerald-500" defaultValue="">
                           <option value="">-- Bilgisayardan Yeni Yükleyeceğim --</option>
                           {examDocuments.map(doc => (
                             <option key={doc.id} value={doc.url}>{doc.name} {doc.tags ? `(${doc.tags})` : ''}</option>
                           ))}
                        </select>
                        <div className="flex items-center gap-3">
                          <span className="text-[10px] font-bold text-slate-400">VEYA YENİ YÜKLE:</span>
                          <input name="pdfFile" type="file" accept=".pdf" className="w-full text-sm text-slate-600 file:bg-emerald-50 file:text-emerald-700 file:font-bold file:border-0 file:px-4 file:py-2 file:rounded-lg hover:file:bg-emerald-100 transition-colors cursor-pointer" />
                        </div>
                      </div>

                      <div className="bg-white p-4 border border-slate-200 rounded-xl shadow-sm">
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-3">Çözüm Kitapçığı PDF'i (Opsiyonel)</label>
                        <select name="existingSolutionPdfUrl" className="w-full text-sm text-slate-700 bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-lg mb-3 outline-none focus:border-emerald-500" defaultValue="">
                           <option value="">-- Bilgisayardan Yeni Yükleyeceğim --</option>
                           {solutionDocuments.map(doc => (
                             <option key={doc.id} value={doc.url}>{doc.name} {doc.tags ? `(${doc.tags})` : ''}</option>
                           ))}
                        </select>
                        <div className="flex items-center gap-3">
                          <span className="text-[10px] font-bold text-slate-400">VEYA YENİ YÜKLE:</span>
                          <input name="solutionPdfFile" type="file" accept=".pdf" className="w-full text-sm text-slate-600 file:bg-slate-100 file:text-slate-700 file:font-bold file:border-0 file:px-4 file:py-2 file:rounded-lg hover:file:bg-slate-200 transition-colors cursor-pointer" />
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Grup Ataması */}
                  <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 shadow-sm">
                    <h3 className="font-bold text-cyan-600 mb-1 flex items-center gap-2"><Users className="w-5 h-5"/> Sınavı Gruplara Ata</h3>
                    <p className="text-xs text-slate-500 mb-4 font-medium">Boş bırakırsanız sınav hiçbir gruba ait olmaz.</p>
                    
                    <div className="max-h-48 overflow-y-auto space-y-2 pr-2 custom-scrollbar p-1">
                      {groups.length === 0 ? <p className="text-sm text-slate-500 bg-white p-4 rounded-xl border border-slate-200">Sistemde hiç grup yok.</p> : groups.map(g => (
                        <label key={g.id} className="flex items-center gap-3 p-3 rounded-xl bg-white border border-slate-200 hover:border-cyan-300 hover:shadow-sm cursor-pointer transition-all">
                          <input 
                            type="checkbox" 
                            checked={selectedGroups.includes(g.id)}
                            onChange={() => toggleGroup(g.id)}
                            className="w-4 h-4 rounded border-slate-300 text-cyan-500 focus:ring-cyan-500" 
                          />
                          <span className="text-sm font-bold text-slate-700">{g.name}</span>
                        </label>
                      ))}
                  </div>
                </div>
                </div>
              </div>
              {/* END STEP 1 */}
              {/* STEP 2 */}
              <div className={`grid grid-cols-1 md:grid-cols-2 gap-6 ${createStep === 2 ? 'block animate-in fade-in slide-in-from-right-4' : 'hidden'}`}>
                  <div className="border border-indigo-100 bg-indigo-50/50 rounded-2xl p-6 shadow-sm h-fit">
                    <h3 className="font-bold text-indigo-700 mb-1 flex items-center gap-2">
                      <BookOpen className="w-5 h-5"/> ÖSYM Sınav Şablon Motoru 
                    </h3>
                    <p className="text-xs text-indigo-500/70 mb-6 font-medium">Bu sınavın hesaplama şablonunu seçin.</p>
                    <div className="space-y-4">
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-indigo-700/70 mb-2">Sınav Hesaplama Şablonu</label>
                        <select 
                          name="examTemplate" 
                          value={examTemplate} 
                          onChange={(e) => setExamTemplate(e.target.value)}
                          className="w-full bg-white border border-indigo-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm"
                        >
                          <option value="CUSTOM">🔴 Özel (Kendi Kurallarımı Gireceğim)</option>
                          <option value="KPSS_P3">📜 KPSS P3 (Lisans B Grubu)</option>
                          <option value="KPSS_P10">📜 KPSS P10 (Öğretmenlik - Alan Sınavı Olmayan)</option>
                          <option value="KPSS_P121">📜 KPSS P121 (Öğretmenlik - Alan Sınavı Olan)</option>
                          <option value="KPSS_P93">📜 KPSS P93 (Ön Lisans Memurluk)</option>
                          <option value="KPSS_P94">📜 KPSS P94 (Ortaöğretim Memurluk)</option>
                          <option value="KAYMAKAMLIK">📜 Kaymakamlık Formatı</option>
                          <option value="HMGS">📜 HMGS Hukuk Sınavı Formatı</option>
                          <option value="ICRA">📜 İcra Müdür Yrd. Formatı</option>
                        </select>
                      </div>
                      <div className="mt-4">
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-indigo-700/70 mb-2">Oturum Türü (Kategori)</label>
                        <select 
                          name="sessionType" 
                          defaultValue="STANDART"
                          className="w-full bg-white border border-indigo-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm"
                        >
                          <option value="STANDART">Kategorisiz (Standart Sınav)</option>
                          <option value="GY_GK">Genel Yetenek - Genel Kültür (GY-GK)</option>
                          <option value="EB">Eğitim Bilimleri (EB)</option>
                          <option value="OABT">Öğretmenlik Alan (ÖABT)</option>
                          <option value="ALAN">Alan Sınavı (Kaymakamlık, HMGS vb.)</option>
                        </select>
                      </div>
                      
                      {examTemplate !== "CUSTOM" && (
                        <>
                          <input type="hidden" name="penaltyRatio" value="0.25" />
                          <input type="hidden" name="baseScore" value="0" />
                        </>
                      )}

                      {examTemplate === "CUSTOM" && (
                        <div className="space-y-4 animate-in fade-in pt-2">
                          <div>
                            <label className="block text-[11px] uppercase tracking-widest font-bold text-indigo-700/70 mb-2">Taban Puan</label>
                            <input name="baseScore" type="number" step="0.1" defaultValue="100" className="w-full bg-white border border-indigo-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm" />
                          </div>
                          <div>
                            <label className="block text-[11px] uppercase tracking-widest font-bold text-indigo-700/70 mb-2">Yanlışların Doğruyu Götürme Oranı</label>
                            <select name="penaltyRatio" defaultValue="0.25" className="w-full bg-white border border-indigo-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm">
                              <option value="0">Yok (Yanlışlar Doğruyu Götürmez)</option>
                              <option value="0.25">4 Yanlış 1 Doğruyu Götürür (0.25)</option>
                              <option value="0.3333">3 Yanlış 1 Doğruyu Götürür (0.33)</option>
                            </select>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="border border-amber-200 bg-amber-50/50 rounded-2xl p-6 shadow-sm h-fit">
                    <h3 className="font-bold text-amber-600 mb-1 flex items-center gap-2"><CalendarClock className="w-5 h-5"/> Sınav Takvimi (Opsiyonel)</h3>
                    <p className="text-xs text-amber-600/70 mb-6 font-medium">Boş bırakırsanız sınav öğrencilere her zaman açık olur.</p>
                    <div className="space-y-4">
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-amber-700/70 mb-2">Dönem Başlangıcı (Öğrencilere Açılma)</label>
                        <input name="startTime" type="datetime-local" className="w-full bg-white border border-amber-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" />
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-amber-700/70 mb-2">Dönem Bitişi (Kapanma Zamanı)</label>
                        <input name="endTime" type="datetime-local" className="w-full bg-white border border-amber-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" />
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-amber-700/70 mb-2">Sonuç Açıklanma Tarihi</label>
                        <input name="showResultsTime" type="datetime-local" className="w-full bg-white border border-amber-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" />
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-amber-700/70 mb-2">Sınav Süresi (Dakika)</label>
                        <input name="durationMinutes" type="number" min="1" placeholder="Örn: 120 (Boş bırakılırsa süresiz)" className="w-full bg-white border border-amber-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" />
                      </div>
                    </div>
                  </div>
                </div>
                {/* END STEP 2 */}

                {/* STEP 3 */}
                <div className={`${createStep === 3 ? 'block animate-in fade-in slide-in-from-right-4' : 'hidden'}`}>
                  <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden flex flex-col h-[55vh]">
                    {/* Sekmeler ve Katsayı Alanı */}
                    <div className="bg-slate-50 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between px-6 pt-3 shrink-0 gap-4">
                      {sectionsBuilder.length > 0 ? (
                        <div className="flex gap-1 overflow-x-auto custom-scrollbar">
                          {sectionsBuilder.map((sec) => (
                            <button 
                              key={sec.id} type="button"
                              onClick={() => setActiveWizardSectionId(sec.id)}
                              className={`px-4 py-2 font-bold text-sm tracking-wide rounded-t-xl transition-all border-b-2 flex items-center gap-2 ${activeWizardSectionId === sec.id ? 'border-blue-600 text-blue-600 bg-blue-50/50' : 'border-transparent text-slate-500 hover:text-slate-700 hover:bg-slate-100/50'}`}
                            >
                              {sec.title}
                              <span className={`text-[10px] px-1.5 py-0.5 rounded-md ${activeWizardSectionId === sec.id ? 'bg-blue-100 text-blue-700' : 'bg-slate-200 text-slate-500'}`}>{sec.count}</span>
                            </button>
                          ))}
                        </div>
                      ) : <div />}
                      
                      <div className="flex items-center gap-2 pb-2 shrink-0 self-end sm:self-auto">
                        <span className="text-[10px] font-bold text-slate-500 uppercase">Görünür Kısım İçin Katsayı:</span>
                        <input 
                          type="number" step="0.1" placeholder="Örn: 1.0" 
                          title="Görüntülenen bölümdeki soruların puan katsayısını topluca günceller. Seçim yoksa tüm sınava uygular." 
                          className="w-16 border rounded-md px-2 py-1 text-xs font-bold text-blue-700 bg-blue-50 border-blue-200 outline-none focus:border-blue-500 transition-colors placeholder:font-medium placeholder:text-blue-300" 
                          onBlur={(e) => {
                            const val = parseFloat(e.target.value);
                            if(!isNaN(val)) {
                              let copy = [...createWizardKeys];
                              if (activeWizardSectionId && sectionsBuilder.length > 0) {
                                let currentCount = 0;
                                let activeRange = { start: 0, end: 0 };
                                for (const s of sectionsBuilder) {
                                  const sC = typeof s.count === 'string' ? parseInt(s.count) || 0 : s.count || 0;
                                  if (s.id === activeWizardSectionId) {
                                    activeRange = { start: currentCount + 1, end: currentCount + sC };
                                    break;
                                  }
                                  currentCount += sC;
                                }
                                copy.forEach(k => {
                                  if (k.questionNumber >= activeRange.start && k.questionNumber <= activeRange.end) {
                                    k.points = val;
                                  }
                                });
                              } else {
                                copy.forEach(k => k.points = val);
                              }
                              setCreateWizardKeys(copy);
                              e.target.value = "";
                              alert("Katsayılar uygulandı!");
                            }
                          }}
                          onKeyDown={(e) => {
                            if (e.key === 'Enter') e.currentTarget.blur();
                          }}
                        />
                      </div>
                    </div>
                    
                    {/* Optik Izgara */}
                    <div className="p-6 overflow-y-auto overflow-x-auto flex-1 bg-white custom-scrollbar rounded-b-2xl">
                      <div className="flex gap-12 pb-4 w-max mx-auto">
                        {(() => {
                           let activeRange = { start: 1, end: createWizardKeys.length };
                           if (activeWizardSectionId) {
                             let currentCount = 0;
                             for (const s of sectionsBuilder) {
                               const sC = typeof s.count === 'string' ? parseInt(s.count) || 0 : s.count || 0;
                               if (s.id === activeWizardSectionId) {
                                 activeRange = { start: currentCount + 1, end: currentCount + sC };
                                 break;
                               }
                               currentCount += sC;
                             }
                           }
                           const filtered = createWizardKeys.filter((k) => {
                             if (!activeWizardSectionId) return true;
                             return k.questionNumber >= activeRange.start && k.questionNumber <= activeRange.end;
                           });
                           
                           const chunks = [];
                           for (let i = 0; i < filtered.length; i += 10) {
                             chunks.push(filtered.slice(i, i + 10));
                           }
                           
                           return chunks.map((chunk, cIdx) => (
                             <div key={cIdx} className="flex flex-col space-y-1 min-w-[260px]">
                               {chunk.map((k) => {
                                 const idx = k.questionNumber - 1;
                                 return (
                                 <div key={idx} className={`break-inside-avoid w-full flex flex-col border-b border-pink-100/50 hover:bg-pink-50/20 transition-colors py-1.5 ${expandedKeyIdx === idx ? 'bg-slate-50/50 rounded-lg p-2 border-transparent' : ''}`}>
                                   <div className="flex items-center justify-between group">
                                     <div className="flex items-center gap-4">
                                       <span className="font-bold text-slate-700 w-6 text-right tabular-nums">{activeWizardSectionId ? k.questionNumber - activeRange.start + 1 : k.questionNumber}</span>
                                       <div className="flex items-center gap-1.5">
                                         {["A", "B", "C", "D", "E"].map(opt => (
                                           <button
                                             key={opt} type="button"
                                             onClick={() => updateWizardKey(idx, "correctOption", opt)}
                                             className={`w-6 h-6 rounded-full border text-[10px] font-black flex items-center justify-center transition-all ${
                                               k.correctOption === opt 
                                               ? 'bg-slate-800 border-slate-800 text-white' 
                                               : 'bg-white border-pink-400 text-pink-500 hover:bg-pink-100'
                                             }`}
                                           >  {opt} </button>
                                         ))}
                                         <button type="button" onClick={() => updateWizardKey(idx, "correctOption", "IPTAL")} className={`ml-2 px-1.5 h-6 rounded border text-[9px] font-bold uppercase transition-all ${
                                             k.correctOption === "IPTAL"  ? 'bg-red-500 border-red-500 text-white' : 'bg-white border-slate-200 text-slate-400 hover:bg-red-50 hover:border-red-300 hover:text-red-500'
                                           }`}> İPTAL </button>
                                       </div>
                                     </div>
                                     <button type="button" onClick={() => setExpandedKeyIdx(expandedKeyIdx === idx ? null : idx)} className={`p-1.5 rounded-md transition-all ${expandedKeyIdx === idx ? 'bg-blue-100 text-blue-600' : 'opacity-100 text-slate-300 hover:text-blue-500 hover:bg-slate-100'}`} title="Soru Katsayısı & Özel Ayarlar (Puan, Konu, Video)"><Pencil className="w-4 h-4" /></button>
                                   </div>
                                   {expandedKeyIdx === idx && (
                                     <div className="mt-3 pl-10 pr-2 pb-2 space-y-2 animate-in slide-in-from-top-2 fade-in">
                                       <div className="flex items-center gap-3">
                                         <span className="text-[10px] font-bold text-slate-500 uppercase w-14">Puan:</span>
                                         <input type="number" step="0.1" value={k.points} onChange={(e) => updateWizardKey(idx, "points", parseFloat(e.target.value))} className="w-16 border rounded-md px-2 py-1 text-xs font-bold text-amber-700 bg-amber-50 border-amber-200 outline-none focus:border-amber-500"/>
                                       </div>
                                       <div className="flex items-center gap-3">
                                         <span className="text-[10px] font-bold text-slate-500 uppercase w-14">Kazanım:</span>
                                         <input value={k.topic} onChange={(e) => updateWizardKey(idx, "topic", e.target.value)} placeholder="Örn: Limit" className="flex-1 border border-slate-200 rounded-md px-2 py-1 text-xs outline-none focus:border-blue-500"/>
                                       </div>
                                       <div className="flex items-center gap-3">
                                         <span className="text-[10px] font-bold text-slate-500 uppercase w-14">Video:</span>
                                         <input value={k.videoUrl} onChange={(e) => updateWizardKey(idx, "videoUrl", e.target.value)} placeholder="YouTube URL" className="flex-1 border border-slate-200 rounded-md px-2 py-1 text-xs outline-none focus:border-red-400"/>
                                       </div>
                                     </div>
                                   )}
                                 </div>
                                 );
                               })}
                             </div>
                           ));
                        })()}
                      </div>
                    </div>
                  </div>
                </div>
                {/* END STEP 3 */}
              </div>

              <div className="pt-5 border-t-2 border-slate-100 flex justify-between items-center mt-auto sticky bottom-0 px-6 bg-white/95 backdrop-blur z-10 pb-6 rounded-b-3xl">
                {createStep === 1 ? (
                   <button type="button" onClick={() => { setShowCreateModal(false); setCreateStep(1); }} className="px-6 py-2.5 bg-white hover:bg-slate-50 border border-slate-200 rounded-xl text-slate-500 font-bold transition-colors shadow-sm">İptal</button>
                ) : (
                   <button type="button" onClick={() => setCreateStep(createStep - 1)} className="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 border border-slate-200 rounded-xl text-slate-600 font-bold transition-colors shadow-sm">Geri Dön</button>
                )}
                
                {createStep === 1 || createStep === 2 ? (
                   <button type="button" onClick={() => { handleInitializeWizardKeys(); setCreateStep(createStep + 1); }} className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 rounded-xl text-white font-bold transition-all shadow-md active:scale-95">İleri Seçenekler ➔</button>
                ) : (
                   <div className="flex items-center gap-4">
                     <div className="flex bg-slate-100 p-1 rounded-lg border border-slate-200">
                       <label className="cursor-pointer">
                         <input type="radio" name="isActive" value="on" defaultChecked={true} className="peer sr-only" />
                         <div className="px-4 py-1.5 rounded-md text-sm font-bold text-slate-500 peer-checked:bg-white peer-checked:text-emerald-600 peer-checked:shadow-sm transition-all whitespace-nowrap">Aktif Başlat</div>
                       </label>
                       <label className="cursor-pointer">
                         <input type="radio" name="isActive" value="off" className="peer sr-only" />
                         <div className="px-4 py-1.5 rounded-md text-sm font-bold text-slate-500 peer-checked:bg-white peer-checked:text-red-500 peer-checked:shadow-sm transition-all whitespace-nowrap">Pasif (Taslak)</div>
                       </label>
                     </div>
                     <button type="submit" disabled={savingExam} className="px-6 py-2.5 bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 disabled:cursor-not-allowed rounded-xl text-white font-bold transition-all shadow-md active:scale-95 flex items-center gap-2 text-sm">
                       {savingExam ? <Loader2 className="w-5 h-5 animate-spin"/> : <KeyRound className="w-5 h-5"/>} {savingExam ? "Sınav Üretiliyor..." : "Sınavı Oluştur ve Yükle"}
                     </button>
                   </div>
                )}
              </div>
            </form>
          </div>
        </div>
      )}
      
      {/* Sınav Düzenleme Modalı */}
      {selectedExamForEdit && showEditModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white border border-slate-200 rounded-3xl w-full max-w-4xl shadow-2xl flex flex-col h-[90vh] animate-in fade-in zoom-in-95">
            <div className="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50 rounded-t-3xl">
              <h2 className="text-xl font-bold flex items-center gap-2 text-amber-600">
                <Pencil className="w-5 h-5" /> Sınavı Düzenle
              </h2>
              <button 
                type="button" 
                onClick={() => { setShowEditModal(false); setSelectedExamForEdit(null); setEditStep(1); }} 
                className="text-slate-400 hover:text-slate-700 bg-white rounded-full p-1.5 transition-colors shadow-sm border border-slate-200"
              >✕</button>
            </div>
            
            <form 
              onSubmit={handleEditSubmit} 
              onKeyDown={(e) => {
                if (e.key === 'Enter' && (e.target as HTMLElement).tagName !== 'TEXTAREA') {
                  e.preventDefault();
                }
              }}
              className="flex flex-col flex-1 overflow-y-auto custom-scrollbar relative"
            >
              {/* Sekmeler / Stepper */}
              <div className="flex gap-2 border-b border-slate-100 pb-4 mb-5 overflow-x-auto px-6 pt-6 shrink-0">
                 <button type="button" onClick={() => setEditStep(1)} className={`flex-shrink-0 py-3 px-3 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${editStep === 1 ? 'bg-blue-600 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>1. Temel</button>
                 <button type="button" onClick={() => setEditStep(2)} className={`flex-shrink-0 py-3 px-3 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${editStep === 2 ? 'bg-blue-600 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>2. Puan & Takvim</button>
                 <button type="button" onClick={() => setEditStep(3)} className={`flex-shrink-0 py-3 px-3 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${editStep === 3 ? 'bg-blue-600 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>3. Cevap Anahtarı</button>
                 <button type="button" onClick={() => setEditStep(4)} className={`flex-shrink-0 py-3 px-3 rounded-xl font-bold text-[11px] uppercase tracking-wider sm:text-xs transition-all focus:outline-none flex items-center justify-center gap-2 ${editStep === 4 ? 'bg-emerald-500 text-white shadow-md' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 border border-slate-200/60'}`}>4. Gruplar</button>
              </div>

              {/* STEP 1 */}
              <div className={`grid grid-cols-1 md:grid-cols-2 gap-6 px-6 ${editStep === 1 ? 'block animate-in fade-in slide-in-from-left-4' : 'hidden'}`}>
                
                {/* Sol Taraf: Temel Bilgiler & Kapsam */}
                <div className="space-y-5">
                  <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 shadow-sm">
                    <h3 className="font-bold text-slate-800 mb-4 flex items-center gap-2"><BookOpen className="w-5 h-5 text-amber-500"/> Sınav Kapsamı</h3>
                    <div className="space-y-4">
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Sınav Adı</label>
                        <input 
                          name="title" 
                          defaultValue={selectedExamForEdit?.title} 
                          required 
                          className="w-full bg-white border border-slate-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-amber-500 shadow-sm transition-colors" 
                        />
                      </div>
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Açıklama</label>
                        <textarea 
                          name="description" 
                          defaultValue={selectedExamForEdit?.description || ""}
                          className="w-full bg-white border border-slate-200 rounded-xl p-3 text-slate-800 font-medium outline-none focus:border-amber-500 shadow-sm transition-colors" 
                          rows={3}
                        ></textarea>
                      </div>
                      
                      {/* Bölümler / Testler */}
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Bölümler / Testler (Optik Yapısı)</label>
                        <div className="bg-amber-50/50 text-amber-700 p-2 rounded text-[10px] font-bold mb-3 border border-amber-200">
                          ⚠️ DİKKAT: Bölümleri değiştirirseniz, eski cevap anahtarı ile uyumsuzluk oluşabilir.
                        </div>
                        <div className="space-y-2 mb-2">
                           {editSectionsBuilder.map((sec, idx) => (
                             <div key={sec.id} className="flex gap-2 items-center">
                               <input value={sec.title} onChange={e => {
                                 let copy = [...editSectionsBuilder];
                                 copy[idx].title = e.target.value;
                                 setEditSectionsBuilder(copy);
                               }} className="flex-1 w-full min-w-[60px] border p-2 text-sm rounded bg-white shadow-sm font-bold text-slate-700 outline-none" placeholder="Türkçe Testi" />
                               <div className="relative">
                                 <input type="number" value={sec.count} onChange={e => {
                                   let copy = [...editSectionsBuilder];
                                   copy[idx].count = e.target.value;
                                   setEditSectionsBuilder(copy);
                                 }} className="w-14 sm:w-16 border p-2 text-sm rounded text-center bg-white font-bold outline-none shadow-sm" placeholder="40" />
                                 <span className="absolute -top-2 left-1/2 -translate-x-1/2 bg-white text-[8px] font-black tracking-wider text-slate-400 px-1.5 rounded shadow-[0_0_2px_rgba(0,0,0,0.15)] ring-1 ring-slate-100 z-10 w-max leading-tight">SORU</span>
                               </div>
                               <div className="relative">
                                 <input type="number" step="0.1" value={sec.points} onChange={e => {
                                   let copy = [...editSectionsBuilder];
                                   copy[idx].points = e.target.value;
                                   setEditSectionsBuilder(copy);
                                 }} className="w-14 sm:w-16 border border-amber-200 bg-amber-50 p-2 text-sm rounded text-center font-bold text-amber-700 outline-none shadow-sm" placeholder="1.0" />
                                 <span className="absolute -top-2 left-1/2 -translate-x-1/2 bg-amber-200/90 backdrop-blur-sm text-[8px] font-black tracking-wider text-amber-800 px-1.5 rounded shadow-[0_0_2px_rgba(0,0,0,0.15)] ring-1 ring-amber-300 z-10 w-max leading-tight">KATSAYI</span>
                               </div>
                               {editSectionsBuilder.length > 1 && (
                                 <button type="button" onClick={() => setEditSectionsBuilder(editSectionsBuilder.filter(s => s.id !== sec.id))} className="text-red-500 p-1.5 hover:bg-red-50 hover:text-red-600 rounded-lg transition-colors shrink-0"><Trash2 className="w-4 h-4"/></button>
                               )}
                             </div>
                           ))}
                        </div>
                        <div className="flex justify-between items-center mt-3">
                           <button type="button" onClick={() => setEditSectionsBuilder([...editSectionsBuilder, {id: Date.now().toString(), title: "Yeni Test", count: 20, points: 1.0}])} className="text-[10px] font-black tracking-widest uppercase text-amber-600 border border-amber-200 bg-amber-50/50 px-3 py-1.5 rounded hover:bg-amber-100 flex items-center gap-1 transition-colors"><Plus className="w-3 h-3"/> Bölüm Ekle</button>
                           <span className="text-[10px] font-black tracking-wider text-slate-400">TOPLAM: {editSectionsBuilder.reduce((a,b)=>a+Number(b.count||0),0)} SORU</span>
                        </div>
                      </div>
                      
                      <div>
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-2">Sanal Hedef Katılımcı (Opsiyonel)</label>
                        <input 
                          name="virtualTotalParticipants" 
                          type="number"
                          defaultValue={selectedExamForEdit?.virtualTotalParticipants || ""} 
                          className="w-full bg-white border border-slate-200 rounded-xl p-3 text-slate-800 font-bold outline-none focus:border-amber-500 shadow-sm transition-colors" 
                          placeholder="Boş bırakırsanız sadece gerçek giren sayısı görünür"
                        />
                      </div>
                    </div>
                  </div>
                </div>

                {/* Sağ Taraf: Dosyalar */}
                <div className="space-y-5 h-fit">
                  <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 shadow-sm">
                    <h3 className="font-bold text-emerald-600 mb-4 flex items-center gap-2"><UploadCloud className="w-5 h-5"/> Dosyalar</h3>
                    <div className="space-y-5">
                      
                      {/* Ana Sınav PDF */}
                      <div className="bg-white p-4 border border-slate-200 rounded-xl shadow-sm">
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-3">Ana Sınav PDF'i</label>
                        {selectedExamForEdit?.pdfUrl && (
                          <a href={selectedExamForEdit.pdfUrl} target="_blank" className="text-xs font-bold text-emerald-600 flex items-center gap-1 mb-3 hover:underline">
                            <BookOpen className="w-3 h-3"/> Mevcut Sınav PDF'ini Görüntüle
                          </a>
                        )}
                        <select name="existingPdfUrl" className="w-full text-sm text-slate-700 bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-lg mb-3 outline-none focus:border-emerald-500" defaultValue={selectedExamForEdit?.pdfUrl || ""}>
                           <option value="">-- Bilgisayardan Yeni Yükleyeceğim --</option>
                           {examDocuments.map(doc => (
                             <option key={doc.id} value={doc.url}>{doc.name} {doc.tags ? `(${doc.tags})` : ''}</option>
                           ))}
                        </select>
                        <div className="flex items-center gap-3">
                          <span className="text-[10px] font-bold text-slate-400">YENİ YÜKLE:</span>
                          <input name="pdfFile" type="file" accept=".pdf" className="w-full text-sm text-slate-600 file:bg-emerald-50 file:text-emerald-700 file:font-bold file:border-0 file:px-3 file:py-1.5 file:rounded-lg hover:file:bg-emerald-100 transition-colors cursor-pointer" />
                        </div>
                      </div>

                      {/* Çözüm PDF */}
                      <div className="bg-white p-4 border border-slate-200 rounded-xl shadow-sm">
                        <label className="block text-[11px] uppercase tracking-widest font-bold text-slate-500 mb-3">Çözüm Kitapçığı PDF'i (Opsiyonel)</label>
                        {selectedExamForEdit?.solutionPdfUrl && (
                          <a href={selectedExamForEdit.solutionPdfUrl} target="_blank" className="text-xs font-bold text-blue-600 flex items-center gap-1 mb-3 hover:underline">
                            <BookOpen className="w-3 h-3"/> Mevcut Çözüm PDF'ini Görüntüle
                          </a>
                        )}
                        <select name="existingSolutionPdfUrl" className="w-full text-sm text-slate-700 bg-slate-50 border border-slate-200 px-3 py-2.5 rounded-lg mb-3 outline-none focus:border-emerald-500" defaultValue={selectedExamForEdit?.solutionPdfUrl || ""}>
                           <option value="">-- Bilgisayardan Yeni Yükleyeceğim --</option>
                           {solutionDocuments.map(doc => (
                             <option key={doc.id} value={doc.url}>{doc.name} {doc.tags ? `(${doc.tags})` : ''}</option>
                           ))}
                        </select>
                        <div className="flex items-center gap-3">
                          <span className="text-[10px] font-bold text-slate-400">YENİ YÜKLE:</span>
                          <input name="solutionPdfFile" type="file" accept=".pdf" className="w-full text-sm text-slate-600 file:bg-slate-100 file:text-slate-700 file:font-bold file:border-0 file:px-3 file:py-1.5 file:rounded-lg hover:file:bg-slate-200 transition-colors cursor-pointer" />
                        </div>
                      </div>

                    </div>
                  </div>
                </div>
              </div>

              {/* STEP 2 */}
              <div className={`space-y-5 px-6 ${editStep === 2 ? 'block animate-in fade-in slide-in-from-right-4' : 'hidden'}`}>
                <div className="border border-indigo-100 bg-indigo-50/50 rounded-2xl p-5">
                  <h3 className="font-bold text-indigo-700 mb-3 flex items-center gap-2 text-sm"><BookOpen className="w-4 h-4"/> ÖSYM Sınav Şablon Motoru</h3>
                  
                  <div className="mb-4">
                    <label className="block text-[10px] uppercase tracking-widest font-bold text-indigo-700/70 mb-1">Şablon Seçimi</label>
                    <select 
                      name="examTemplate" 
                      value={examTemplate} 
                      onChange={(e) => setExamTemplate(e.target.value)}
                      className="w-full bg-white border border-indigo-200 rounded-lg p-2.5 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm"
                    >
                      <option value="CUSTOM">🔴 Özel Seçenekler</option>
                      <option value="KPSS_P3">📜 KPSS P3 (Lisans B Grubu)</option>
                      <option value="KPSS_P10">📜 KPSS P10 (Öğretmenlik - Alan Sınavı Olmayan)</option>
                      <option value="KPSS_P121">📜 KPSS P121 (Öğretmenlik - Alan Sınavı Olan)</option>
                      <option value="KPSS_P93">📜 KPSS P93 (Ön Lisans Memurluk)</option>
                      <option value="KPSS_P94">📜 KPSS P94 (Ortaöğretim Memurluk)</option>
                      <option value="KAYMAKAMLIK">📜 Kaymakamlık Formatı</option>
                      <option value="HMGS">📜 HMGS Hukuk Sınavı</option>
                      <option value="ICRA">📜 İcra Müdür Yrd.</option>
                    </select>
                  </div>

                  <div className="mb-4">
                    <label className="block text-[10px] uppercase tracking-widest font-bold text-indigo-700/70 mb-1">Oturum Türü (Kategori)</label>
                    <select 
                      name="sessionType" 
                      defaultValue={selectedExamForEdit.sessionType || "STANDART"}
                      className="w-full bg-white border border-indigo-200 rounded-lg p-2.5 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm"
                    >
                      <option value="STANDART">Kategorisiz (Standart Sınav)</option>
                      <option value="GY_GK">Genel Yetenek - Genel Kültür (GY-GK)</option>
                      <option value="EB">Eğitim Bilimleri (EB)</option>
                      <option value="OABT">Öğretmenlik Alan (ÖABT)</option>
                      <option value="ALAN">Alan Sınavı (Kaymakamlık, HMGS vb.)</option>
                    </select>
                  </div>

                  {examTemplate !== "CUSTOM" && (
                    <>
                      <input type="hidden" name="penaltyRatio" value="0.25" />
                      <input type="hidden" name="baseScore" value="0" />
                    </>
                  )}

                  {examTemplate === "CUSTOM" && (
                    <div className="grid grid-cols-2 gap-4 animate-in fade-in">
                      <div>
                        <label className="block text-[10px] uppercase tracking-widest font-bold text-indigo-700/70 mb-1">Taban Puan</label>
                        <input name="baseScore" type="number" step="0.1" defaultValue={selectedExamForEdit.baseScore} className="w-full bg-white border border-indigo-200 rounded-lg p-2.5 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm" />
                      </div>
                      <div>
                        <label className="block text-[10px] uppercase tracking-widest font-bold text-indigo-700/70 mb-1">Yanlış/Doğru Oranı</label>
                        <select name="penaltyRatio" defaultValue={selectedExamForEdit.penaltyRatio} className="w-full bg-white border border-indigo-200 rounded-lg p-2.5 text-slate-800 font-bold outline-none focus:border-indigo-500 transition-colors shadow-sm">
                          <option value="0">Yok</option>
                          <option value="0.25">4 Yan. 1 Doğ. (0.25)</option>
                          <option value="0.3333">3 Yan. 1 Doğ. (0.33)</option>
                        </select>
                      </div>
                    </div>
                  )}
                </div>

                <div className="border border-amber-200 bg-amber-50/50 rounded-2xl p-5">
                  <h3 className="font-bold text-amber-700 mb-3 flex items-center gap-2 text-sm"><CalendarClock className="w-4 h-4"/> Sınav Takvimi</h3>
                  <div className="space-y-3">
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest font-bold text-amber-700/70 mb-1">Başlangıç Zamanı</label>
                      <input 
                        name="startTime" 
                        type="datetime-local" 
                        defaultValue={toLocalISOString(selectedExamForEdit.startTime)}
                        className="w-full bg-white border border-amber-200 rounded-lg p-2 text-sm text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" 
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest font-bold text-amber-700/70 mb-1">Bitiş Zamanı</label>
                      <input 
                        name="endTime" 
                        type="datetime-local" 
                        defaultValue={toLocalISOString(selectedExamForEdit.endTime)}
                        className="w-full bg-white border border-amber-200 rounded-lg p-2 text-sm text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" 
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest font-bold text-amber-700/70 mb-1">Sonuç Açıklanma Tarihi</label>
                      <input 
                        name="showResultsTime" 
                        type="datetime-local" 
                        defaultValue={toLocalISOString(selectedExamForEdit.showResultsTime)}
                        className="w-full bg-white border border-amber-200 rounded-lg p-2 text-sm text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" 
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] uppercase tracking-widest font-bold text-amber-700/70 mb-1">Sınav Süresi (Dakika)</label>
                      <input 
                        name="durationMinutes" 
                        type="number"
                        min="1"
                        placeholder="Örn: 120 (Boş bırakılırsa süresiz)"
                        defaultValue={selectedExamForEdit.durationMinutes || ""}
                        className="w-full bg-white border border-amber-200 rounded-lg p-2 text-sm text-slate-800 font-bold outline-none focus:border-amber-500 transition-colors shadow-sm" 
                      />
                    </div>
                  </div>
                </div>
              </div>

              {/* STEP 3 (Optik Onay) */}
              <div className={`px-6 ${editStep === 3 ? 'block animate-in fade-in slide-in-from-right-4' : 'hidden'}`}>
                  <div className="bg-white border border-slate-200 rounded-2xl shadow-sm flex flex-col min-h-[50vh]">
                    <div className="bg-slate-50 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between px-6 pt-3 shrink-0 rounded-t-2xl gap-4">
                      {selectedExamForEdit.sections && selectedExamForEdit.sections.length > 0 ? (
                        <div className="flex gap-1 overflow-x-auto custom-scrollbar">
                          {(typeof selectedExamForEdit.sections === 'string' ? JSON.parse(selectedExamForEdit.sections) : selectedExamForEdit.sections).map((sec: any) => (
                            <button 
                              key={sec.id} type="button"
                              onClick={() => setActiveOpticSectionId(sec.id)}
                              className={`px-4 py-2 font-bold text-sm tracking-wide rounded-t-xl transition-all border-b-2 flex items-center gap-2 ${activeOpticSectionId === sec.id ? 'border-emerald-500 text-emerald-600 bg-emerald-50/50' : 'border-transparent text-slate-500 hover:text-slate-700 hover:bg-slate-100/50'}`}
                            >
                              {sec.title}
                              <span className={`text-[10px] px-1.5 py-0.5 rounded-md ${activeOpticSectionId === sec.id ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-200 text-slate-500'}`}>{sec.count}</span>
                            </button>
                          ))}
                        </div>
                      ) : <div />}
                      
                      <div className="flex items-center gap-2 pb-2 shrink-0 self-end sm:self-auto">
                        <span className="text-[10px] font-bold text-slate-500 uppercase">Görünür Kısım İçin Katsayı:</span>
                        <input 
                          type="number" step="0.1" placeholder="Örn: 1.0" 
                          title="Görüntülenen bölümdeki soruların puan katsayısını topluca günceller. Seçim yoksa tüm sınava uygular." 
                          className="w-16 border rounded-md px-2 py-1 text-xs font-bold text-emerald-700 bg-emerald-50 border-emerald-200 outline-none focus:border-emerald-500 transition-colors placeholder:font-medium placeholder:text-emerald-300" 
                          onBlur={(e) => {
                            const val = parseFloat(e.target.value);
                            if(!isNaN(val)) {
                              let copy = [...keysState];
                              if (activeOpticSectionId && selectedExamForEdit.sections) {
                                let parsed = selectedExamForEdit.sections;
                                if (typeof parsed === 'string') parsed = JSON.parse(parsed);
                                let currentCount = 0;
                                let activeRange = { start: 0, end: 0 };
                                for (const s of parsed) {
                                  const sC = typeof s.count === 'string' ? parseInt(s.count) || 0 : s.count || 0;
                                  if (s.id === activeOpticSectionId) {
                                    activeRange = { start: currentCount + 1, end: currentCount + sC };
                                    break;
                                  }
                                  currentCount += sC;
                                }
                                copy.forEach(k => {
                                  if (k.questionNumber >= activeRange.start && k.questionNumber <= activeRange.end) {
                                    k.points = val;
                                  }
                                });
                              } else {
                                copy.forEach(k => k.points = val);
                              }
                              setKeysState(copy);
                              e.target.value = "";
                              alert("Katsayılar uygulandı!");
                            }
                          }}
                          onKeyDown={(e) => {
                            if (e.key === 'Enter') e.currentTarget.blur();
                          }}
                        />
                      </div>
                    </div>

                    <div className="p-6 overflow-y-auto overflow-x-auto flex-1 bg-white custom-scrollbar rounded-b-2xl">
                      <div className="flex gap-12 pb-4 w-max mx-auto">
                        {(() => {
                           let parsed = selectedExamForEdit.sections;
                           if (typeof parsed === 'string') parsed = JSON.parse(parsed);
                           
                           let activeRange = { start: 1, end: keysState.length };
                           if (activeOpticSectionId && parsed && parsed.length > 0) {
                             let currentCount = 0;
                             for (const s of parsed) {
                               const sC = typeof s.count === 'string' ? parseInt(s.count) || 0 : s.count || 0;
                               if (s.id === activeOpticSectionId) {
                                 activeRange = { start: currentCount + 1, end: currentCount + sC };
                                 break;
                               }
                               currentCount += sC;
                             }
                           }
                           
                           const filtered = keysState.filter((k) => {
                             if (!activeOpticSectionId || !parsed || parsed.length === 0) return true;
                             return k.questionNumber >= activeRange.start && k.questionNumber <= activeRange.end;
                           });

                           const chunks = [];
                           for (let i = 0; i < filtered.length; i += 10) {
                             chunks.push(filtered.slice(i, i + 10));
                           }

                           return chunks.map((chunk, cIdx) => (
                             <div key={cIdx} className="flex flex-col space-y-1 min-w-[260px]">
                               {chunk.map((k) => {
                                  const idx = k.questionNumber - 1;
                                  return (
                                  <div key={idx} className={`break-inside-avoid w-full flex flex-col border-b border-emerald-100/50 hover:bg-emerald-50/20 transition-colors py-1.5 ${expandedKeyIdx === idx ? 'bg-slate-50/50 rounded-lg p-2 border-transparent' : ''}`}>
                                    <div className="flex items-center justify-between group">
                                      <div className="flex items-center gap-4">
                                        <span className="font-bold text-slate-700 w-6 text-right tabular-nums">{activeOpticSectionId ? k.questionNumber - activeRange.start + 1 : k.questionNumber}</span>
                                        <div className="flex items-center gap-1.5">
                                          {["A", "B", "C", "D", "E"].map(opt => (
                                            <button
                                              key={opt} type="button"
                                              onClick={() => updateKey(idx, "correctOption", opt)}
                                              className={`w-6 h-6 rounded-full border text-[10px] font-black flex items-center justify-center transition-all ${
                                                k.correctOption === opt 
                                                ? 'bg-slate-800 border-slate-800 text-white' 
                                                : 'bg-white border-emerald-400 text-emerald-500 hover:bg-emerald-100'
                                              }`}
                                            >
                                              {opt}
                                            </button>
                                          ))}
                                          
                                          <button
                                            type="button"
                                            onClick={() => updateKey(idx, "correctOption", "IPTAL")}
                                            className={`ml-2 px-1.5 h-6 rounded border text-[9px] font-bold uppercase transition-all ${
                                              k.correctOption === "IPTAL" 
                                              ? 'bg-red-500 border-red-500 text-white' 
                                              : 'bg-white border-slate-200 text-slate-400 hover:bg-red-50 hover:border-red-300 hover:text-red-500'
                                            }`}
                                          >
                                            İPTAL
                                          </button>
                                        </div>
                                      </div>
                                      
                                      <button
                                        type="button"
                                        onClick={() => setExpandedKeyIdx(expandedKeyIdx === idx ? null : idx)}
                                        className={`p-1.5 rounded-md transition-all ${expandedKeyIdx === idx ? 'bg-blue-100 text-blue-600' : 'opacity-100 text-slate-300 hover:text-blue-500 hover:bg-slate-100'}`}
                                        title="Soru Katsayısı & Özel Ayarlar (Puan, Konu, Video)"
                                      >
                                        <Pencil className="w-4 h-4" />
                                      </button>
                                     </div>

                                    {expandedKeyIdx === idx && (
                                      <div className="mt-3 pl-10 pr-2 pb-2 space-y-2 animate-in slide-in-from-top-2 fade-in">
                                        <div className="flex items-center gap-3">
                                          <span className="text-[10px] font-bold text-slate-500 uppercase w-14">Puan:</span>
                                          <input 
                                            type="number" step="0.1" value={k.points}
                                            onChange={(e) => updateKey(idx, "points", parseFloat(e.target.value))}
                                            className="w-16 border rounded-md px-2 py-1 text-xs font-bold text-amber-700 bg-amber-50 border-amber-200 outline-none focus:border-amber-500"
                                          />
                                        </div>
                                        <div className="flex items-center gap-3">
                                          <span className="text-[10px] font-bold text-slate-500 uppercase w-14">Kazanım:</span>
                                          <input 
                                            value={k.topic}
                                            onChange={(e) => updateKey(idx, "topic", e.target.value)}
                                            placeholder="Örn: Limit"
                                            className="flex-1 border border-slate-200 rounded-md px-2 py-1 text-xs outline-none focus:border-blue-500"
                                          />
                                        </div>
                                        <div className="flex items-center gap-3">
                                          <span className="text-[10px] font-bold text-slate-500 uppercase w-14">Video:</span>
                                          <input 
                                            value={k.videoUrl}
                                            onChange={(e) => updateKey(idx, "videoUrl", e.target.value)}
                                            placeholder="https://youtu.be/..."
                                            className="flex-1 border border-slate-200 rounded-md px-2 py-1 text-xs outline-none focus:border-blue-500"
                                          />
                                        </div>
                                      </div>
                                    )}
                                  </div>
                                  );
                               })}
                             </div>
                           ));
                        })()}
                      </div>
                    </div>
                  </div>
              </div>

              {/* STEP 4: Gruplar */}
              <div className={`px-6 ${editStep === 4 ? 'block animate-in fade-in slide-in-from-right-4' : 'hidden'}`}>
                <div className="border border-slate-200 bg-slate-50 rounded-2xl p-6 shadow-sm min-h-[40vh]">
                  <h3 className="font-bold text-cyan-600 mb-1 flex items-center gap-2"><Users className="w-5 h-5"/> Sınavı Gruplara Ata</h3>
                  <p className="text-xs text-slate-500 mb-4 font-medium">Sınavın görünür olacağı grupları seçin. Boş bırakırsanız sınav hiçbir gruba ait olmaz.</p>
                  
                  <div className="max-h-[40vh] overflow-y-auto space-y-2 pr-2 custom-scrollbar p-1">
                    {groups.length === 0 ? <p className="text-sm text-slate-500 bg-white p-4 rounded-xl border border-slate-200">Sistemde hiç grup yok.</p> : groups.map(g => (
                      <label key={g.id} className="flex items-center gap-3 p-3 rounded-xl bg-white border border-slate-200 hover:border-cyan-300 hover:shadow-sm cursor-pointer transition-all">
                        <input 
                          type="checkbox" 
                          checked={selectedGroups.includes(g.id)}
                          onChange={() => toggleGroup(g.id)}
                          className="w-4 h-4 rounded border-slate-300 text-cyan-500 focus:ring-cyan-500" 
                        />
                        <span className="text-sm font-bold text-slate-700">{g.name}</span>
                      </label>
                    ))}
                  </div>
                </div>
              </div>

              <div className="pt-5 border-t-2 border-slate-100 flex justify-between items-center mt-auto sticky bottom-0 bg-white/95 backdrop-blur z-10 px-6 pb-6 rounded-b-3xl">
                {editStep === 1 ? (
                   <button type="button" onClick={() => { setShowEditModal(false); setSelectedExamForEdit(null); setEditStep(1); }} className="px-6 py-2.5 bg-white hover:bg-slate-50 border border-slate-200 rounded-xl text-slate-500 font-bold transition-colors shadow-sm">İptal</button>
                ) : (
                   <button type="button" onClick={() => setEditStep(editStep - 1)} className="px-6 py-2.5 bg-slate-100 hover:bg-slate-200 border border-slate-200 rounded-xl text-slate-600 font-bold transition-colors shadow-sm">Geri Dön</button>
                )}
                
                {editStep < 4 ? (
                   <button type="button" onClick={() => setEditStep(editStep + 1)} className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 rounded-xl text-white font-bold transition-all shadow-md active:scale-95">İleri Seçenekler ➔</button>
                ) : (
                   <div className="flex items-center gap-4">
                     <div className="flex bg-slate-100 p-1 rounded-lg border border-slate-200">
                       <label className="cursor-pointer">
                         <input type="radio" name="isActive" value="on" defaultChecked={selectedExamForEdit.isActive} className="peer sr-only" />
                         <div className="px-4 py-1.5 rounded-md text-sm font-bold text-slate-500 peer-checked:bg-white peer-checked:text-emerald-600 peer-checked:shadow-sm transition-all whitespace-nowrap">Aktif Bırak</div>
                       </label>
                       <label className="cursor-pointer">
                         <input type="radio" name="isActive" value="off" defaultChecked={!selectedExamForEdit.isActive} className="peer sr-only" />
                         <div className="px-4 py-1.5 rounded-md text-sm font-bold text-slate-500 peer-checked:bg-white peer-checked:text-red-500 peer-checked:shadow-sm transition-all whitespace-nowrap">Pasife Al</div>
                       </label>
                     </div>
                     <button type="submit" disabled={savingExam} className="px-6 py-2.5 bg-emerald-500 hover:bg-emerald-600 disabled:opacity-50 flex items-center gap-2 rounded-xl text-white font-bold transition-all shadow-md active:scale-95">
                       {savingExam ? <Loader2 className="w-5 h-5 animate-spin" /> : <KeyRound className="w-5 h-5"/>} 
                       Sınavı Güncelle
                     </button>
                   </div>
                )}
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
