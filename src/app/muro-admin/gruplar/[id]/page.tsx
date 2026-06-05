"use client";

import { useState, useEffect } from "react";
import { Users, BookOpen, Trash2, ChevronLeft, Calendar, Plus, X, Download, Power, Clock } from "lucide-react";
import { getGroupDetails, removeStudentFromGroup, removeExamFromGroup, assignExamToGroup, toggleGroupStatus, updateGroupExpireDate, getUsers, bulkAssignStudents } from "@/app/actions/userActions";
import { getExams } from "@/app/actions/examActions";
import * as xlsx from "xlsx";
import Link from "next/link";
import { useParams } from "next/navigation";

export default function GroupDetailPage() {
  const { id } = useParams();
  const [group, setGroup] = useState<any>(null);
  const [allExams, setAllExams] = useState<any[]>([]);
  const [allStudents, setAllStudents] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  // Modal State
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [selectedExamId, setSelectedExamId] = useState("");

  const [showStudentModal, setShowStudentModal] = useState(false);
  const [selectedStudentIds, setSelectedStudentIds] = useState<string[]>([]);
  const [studentSearch, setStudentSearch] = useState("");

  const fetchData = async () => {
    setLoading(true);
    const [data, examsResult, studentsData] = await Promise.all([
      getGroupDetails(id as string),
      getExams({ pageSize: 9999 }),
      getUsers({ role: 'STUDENT', pageSize: 9999 })
    ]);
    setGroup(data);
    setAllExams(examsResult.exams);
    setAllStudents(studentsData.users);
    setLoading(false);
  };

  useEffect(() => {
    fetchData();
  }, [id]);

  const exportToExcel = () => {
    const data = group.users.map((u: any) => ({
      "Ad Soyad": u.name,
      "E-posta": u.email,
      "Telefon": u.phone || "-",
      "Kayıt Tarihi": new Date(u.createdAt).toLocaleDateString('tr-TR')
    }));
    const ws = xlsx.utils.json_to_sheet(data);
    const wb = xlsx.utils.book_new();
    xlsx.utils.book_append_sheet(wb, ws, "Öğrenciler");
    xlsx.writeFile(wb, `${group.name}_Ogrencilar.xlsx`);
  };

  const handleToggleStatus = async () => {
    await toggleGroupStatus(group.id, !group.isActive);
    fetchData();
  };

  const handleUpdateExpireDate = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    await updateGroupExpireDate(group.id, val ? new Date(val) : null);
    fetchData();
  };

  if (loading) {
    return <div className="py-32 flex justify-center text-blue-600 font-medium">Grup detayları yükleniyor...</div>;
  }

  if (!group) {
    return (
      <div className="text-center py-32 space-y-4">
        <h2 className="text-2xl font-bold text-slate-800">Grup Bulunamadı</h2>
        <Link href="/muro-admin/gruplar" className="text-blue-600 hover:underline">Gruplara Dön</Link>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto text-slate-800 space-y-8">
      {/* Üst Kısım - Başlık ve Geri Butonu */}
      <div className="flex items-start gap-6">
        <Link 
          href="/muro-admin/gruplar" 
          className="mt-1 p-2.5 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 text-slate-500 hover:text-slate-800 transition-colors shadow-sm"
        >
          <ChevronLeft className="w-5 h-5" />
        </Link>
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-3xl font-bold text-slate-800">{group.name}</h1>
            <button onClick={handleToggleStatus} className={`ml-2 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider transition-colors outline-none border ${group.isActive ? 'bg-emerald-100 text-emerald-700 border-emerald-200' : 'bg-red-100 text-red-700 border-red-200'}`}>
               {group.isActive ? 'Grup Aktif' : 'Grup Pasif'}
            </button>
          </div>
          <p className="text-slate-500 mt-2 text-sm font-medium">
            {group.description || "Bu grup için herhangi bir açıklama girilmemiş."}
          </p>
          
          <div className="mt-4 flex items-center gap-3 p-3 bg-white border border-slate-200 rounded-xl max-w-sm shadow-sm">
             <div className="p-2 bg-amber-50 text-amber-600 rounded-lg"><Clock className="w-4 h-4" /></div>
             <div className="flex flex-col flex-1">
               <span className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">Sona Erme Tarihi (Opsiyonel)</span>
               <input 
                 type="datetime-local"
                 value={group.expireAt ? new Date(new Date(group.expireAt).getTime() - new Date(group.expireAt).getTimezoneOffset() * 60000).toISOString().slice(0, 16) : ''}
                 onChange={handleUpdateExpireDate}
                 className="text-sm font-bold text-slate-800 bg-transparent outline-none mt-0.5 cursor-pointer"
               />
             </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 pt-4">
        {/* Sol Kolon - Öğrenciler */}
        <div className="space-y-4">
          <div className="flex items-center justify-between border-b border-slate-200 pb-3">
            <div className="flex items-center gap-3">
               <h2 className="text-lg font-bold flex items-center gap-2 text-slate-800">
                 <Users className="w-5 h-5 text-blue-500" />
                 Sınıf Öğrencileri
               </h2>
               <span className="text-[10px] font-bold bg-slate-100 border border-slate-200 px-3 py-1 rounded-lg text-slate-600 uppercase tracking-widest">
                 {group.users.length} Kişi
               </span>
            </div>
            
            <div className="flex items-center gap-2">
              <button onClick={exportToExcel} className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-50 text-slate-600 hover:bg-slate-100 rounded-lg text-xs font-bold transition-colors border border-slate-200 shadow-sm">
                 <Download className="w-3.5 h-3.5" /> Excel İndir
              </button>
              <button 
                onClick={() => {
                  setSelectedStudentIds([]);
                  setStudentSearch("");
                  setShowStudentModal(true);
                }}
                className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200 text-emerald-700 text-xs font-bold rounded-lg transition-colors shadow-sm"
              >
                <Plus className="w-4 h-4" /> Ekle
              </button>
            </div>
          </div>
          
          <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm">
            {group.users.length === 0 ? (
              <div className="p-12 text-center text-slate-400 font-medium">
                Bu grupta henüz öğrenci bulunmuyor.
              </div>
            ) : (
              <div className="max-h-[600px] overflow-y-auto custom-scrollbar">
                <table className="w-full text-sm text-left">
                  <thead className="text-[10px] text-slate-500 uppercase tracking-widest bg-slate-50 sticky top-0 z-10 border-b border-slate-200">
                    <tr>
                      <th className="px-5 py-3 font-bold">Öğrenci Adı</th>
                      <th className="px-5 py-3 text-right font-bold">İşlem</th>
                    </tr>
                  </thead>
                  <tbody>
                    {group.users.map((user: any) => (
                      <tr key={user.id} className="border-b border-slate-100 hover:bg-slate-50/80 transition-colors">
                        <td className="px-5 py-4">
                          <div className="font-bold text-slate-800">{user.name}</div>
                          <div className="text-[11px] text-slate-500 font-mono mt-0.5">{user.email}</div>
                        </td>
                        <td className="px-5 py-4 text-right">
                          <button 
                            onClick={async () => {
                              if (confirm("Bu öğrenciyi gruptan çıkarmak istediğinize emin misiniz?")) {
                                await removeStudentFromGroup(user.id, group.id);
                                fetchData();
                              }
                            }}
                            title="Gruptan Çıkar"
                            className="p-2 bg-white hover:bg-red-50 text-slate-400 hover:text-red-600 rounded-lg transition-colors border border-slate-200 hover:border-red-200 inline-flex shadow-sm"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>

        {/* Sağ Kolon - Atanmış Sınavlar */}
        <div className="space-y-4">
          <div className="flex items-center justify-between border-b border-slate-200 pb-3">
            <h2 className="text-lg font-bold flex items-center gap-2 text-slate-800">
              <BookOpen className="w-5 h-5 text-emerald-500" />
              Atanmış Sınavlar
            </h2>
            <div className="flex items-center gap-3">
              <span className="text-[10px] font-bold bg-slate-100 border border-slate-200 px-3 py-1 rounded-lg text-slate-600 uppercase tracking-widest">
                {group.exams.length} Adet
              </span>
              <button 
                onClick={() => setShowAssignModal(true)}
                className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200 text-emerald-700 text-xs font-bold rounded-lg transition-colors shadow-sm"
              >
                <Plus className="w-4 h-4" /> Ekle
              </button>
            </div>
          </div>

          <div className="space-y-3">
            {group.exams.length === 0 ? (
              <div className="bg-white border border-slate-200 rounded-2xl p-12 text-center text-slate-400 font-medium shadow-sm">
                Bu gruba atanmış herhangi bir sınav bulunmuyor.
              </div>
            ) : (
              group.exams.map((exam: any) => (
                <div key={exam.id} className="bg-white border border-slate-200 p-5 rounded-2xl flex items-center justify-between hover:shadow-md transition-all shadow-sm">
                  <div>
                    <h3 className="font-bold text-sm text-slate-800 mb-1">{exam.title}</h3>
                    <div className="flex items-center gap-4 text-[10px] text-slate-500 font-bold uppercase tracking-widest mt-2">
                       <span className="flex items-center gap-1 bg-slate-50 px-2 py-1 rounded border border-slate-100"><BookOpen className="w-3.5 h-3.5 text-blue-500"/> {exam.questionCount} Soru</span>
                       <span className="flex items-center gap-1 bg-slate-50 px-2 py-1 rounded border border-slate-100"><Calendar className="w-3.5 h-3.5 text-emerald-500"/> {new Date(exam.createdAt).toLocaleDateString("tr-TR")}</span>
                    </div>
                  </div>
                  <div>
                     <button 
                        onClick={async () => {
                          if (confirm("Bu sınavın erişim yetkisini gruptan geri almak istediğinize emin misiniz?")) {
                            await removeExamFromGroup(exam.id, group.id);
                            fetchData();
                          }
                        }}
                        title="Yetkiyi Geri Al"
                        className="p-2 bg-white hover:bg-red-50 text-slate-400 hover:text-red-500 rounded-lg transition-colors border border-slate-200 hover:border-red-200 shadow-sm"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Sınav Atama Modalı */}
      {showAssignModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl flex flex-col overflow-hidden text-slate-900 border border-slate-200 p-8 relative animate-in fade-in zoom-in-95">
            <button 
              onClick={() => setShowAssignModal(false)}
              className="absolute top-6 right-6 text-slate-400 hover:text-slate-700 bg-slate-100 hover:bg-slate-200 p-2 rounded-full transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
            
            <h2 className="text-2xl font-bold tracking-tight text-slate-900 mb-2">Gruba Sınav Ata</h2>
            <p className="text-sm text-slate-500 mb-6 font-medium">Bu sınıfa henüz atanmamış sınavları seçebilirsiniz.</p>
            
            <div className="space-y-5">
              <div>
                <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Mevcut Sınavlar</label>
                <select 
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-800 font-bold hover:border-slate-300 focus:border-emerald-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm"
                  value={selectedExamId}
                  onChange={(e) => setSelectedExamId(e.target.value)}
                >
                  <option value="">-- Sınav Seçin --</option>
                  {allExams
                    .filter((e: any) => !group.exams.find((ge: any) => ge.id === e.id))
                    .map((e: any) => (
                    <option key={e.id} value={e.id}>{e.title}</option>
                  ))}
                </select>
              </div>
              
              <button 
                disabled={!selectedExamId}
                onClick={async () => {
                  try {
                    await assignExamToGroup(selectedExamId, group.id);
                    setShowAssignModal(false);
                    setSelectedExamId("");
                    fetchData();
                  } catch (error: any) {
                    alert("Hata: " + error.message);
                  }
                }}
                className="w-full bg-emerald-600 hover:bg-emerald-500 disabled:opacity-50 py-3.5 rounded-xl text-white font-bold transition-all shadow-md active:scale-95 flex items-center justify-center gap-2"
              >
                Seçili Sınavı Gruba Ata
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Öğrenci Ekleme (Toplu) Modalı */}
      {showStudentModal && (() => {
        const unassignedStudents = allStudents.filter(s => !s.groups?.find((g: any) => g.id === group.id) && s.name.toLowerCase().includes(studentSearch.toLowerCase()));
        
        return (
          <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl flex flex-col overflow-hidden text-slate-900 border border-slate-200 p-8 relative animate-in fade-in zoom-in-95 max-h-[90vh]">
              <button 
                onClick={() => setShowStudentModal(false)}
                className="absolute top-6 right-6 text-slate-400 hover:text-slate-700 bg-slate-100 hover:bg-slate-200 p-2 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
              
              <h2 className="text-2xl font-bold tracking-tight text-slate-900 mb-2">Öğrenci Ekle</h2>
              <p className="text-sm text-slate-500 mb-6 font-medium">Bu gruba eklemek istediğiniz öğrencileri seçin.</p>
              
              <div className="space-y-4 flex-1 overflow-hidden flex flex-col">
                <input 
                  type="text"
                  placeholder="İsme göre öğrenci ara..."
                  value={studentSearch}
                  onChange={e => setStudentSearch(e.target.value)}
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-800 font-medium hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm"
                />

                <div className="flex-1 overflow-y-auto min-h-[300px] border border-slate-200 rounded-xl bg-slate-50 p-2 custom-scrollbar">
                  {unassignedStudents.length === 0 ? (
                    <div className="h-full flex items-center justify-center text-slate-400 font-medium text-sm">Aramaya uygun öğrenci bulunamadı.</div>
                  ) : (
                    unassignedStudents.map(student => (
                      <label key={student.id} className="flex items-center gap-3 p-3 hover:bg-white rounded-lg cursor-pointer transition-colors border border-transparent hover:border-slate-200 hover:shadow-sm">
                        <input 
                          type="checkbox"
                          checked={selectedStudentIds.includes(student.id)}
                          onChange={(e) => {
                            if (e.target.checked) setSelectedStudentIds(prev => [...prev, student.id]);
                            else setSelectedStudentIds(prev => prev.filter(id => id !== student.id));
                          }}
                          className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500 shrink-0"
                        />
                        <div className="flex-1 min-w-0">
                          <div className="font-bold text-slate-800 text-sm truncate">{student.name}</div>
                          <div className="text-[11px] text-slate-500 truncate">{student.email}</div>
                        </div>
                        {student.groups && student.groups.length > 0 && (
                           <div className="text-[10px] font-bold bg-indigo-50 text-indigo-700 px-2 py-0.5 rounded border border-indigo-200 whitespace-nowrap">{student.groups.length} Gruba Kayıtlı</div>
                        )}
                      </label>
                    ))
                  )}
                </div>
                
                <div className="flex items-center justify-between pt-4 border-t border-slate-100">
                  <div className="text-sm font-bold text-slate-600">
                    <span className="text-blue-600">{selectedStudentIds.length}</span> Öğrenci Seçili
                  </div>
                  <button 
                    disabled={selectedStudentIds.length === 0}
                    onClick={async () => {
                      try {
                        await bulkAssignStudents(group.id, selectedStudentIds);
                        setShowStudentModal(false);
                        setSelectedStudentIds([]);
                        fetchData();
                      } catch (error: any) {
                        alert("Hata: " + error.message);
                      }
                    }}
                    className="bg-blue-600 hover:bg-blue-700 disabled:opacity-50 px-6 py-2.5 rounded-xl text-white font-bold transition-all shadow-md active:scale-95"
                  >
                    Seçilileri Kaydet
                  </button>
                </div>
              </div>
            </div>
          </div>
        );
      })()}
    </div>
  );
}
