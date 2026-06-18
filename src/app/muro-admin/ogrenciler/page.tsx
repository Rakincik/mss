"use client";

import { useState, useEffect } from "react";
import { Users, Upload, Plus, Trash2, X, Search, UserCheck, UserX, GraduationCap, ShieldCheck, Download, RefreshCw, ArrowDownUp, Eye } from "lucide-react";
import Link from "next/link";
import * as XLSX from "xlsx";
import { getGroups, getUsers, getUserStats, createStudent, deleteStudent, importStudentsExcel, toggleUserStatus, bulkAssignStudents, bulkDeleteStudents, updateStudent, bulkToggleUserStatus } from "@/app/actions/userActions";
import { getCurrentUser } from "@/app/actions/authActions";
import { useToast } from "@/hooks/useToast";

// Rol etiketleri ve renkleri
const ROLE_LABELS: Record<string, { label: string; color: string; dot: string }> = {
  STUDENT: { label: "Öğrenci", color: "text-emerald-700", dot: "bg-emerald-500" },
  EDITOR: { label: "Editör", color: "text-blue-700", dot: "bg-blue-500" },
  ASISTAN: { label: "Asistan", color: "text-amber-700", dot: "bg-amber-500" },
  ADMIN: { label: "Admin", color: "text-fuchsia-700", dot: "bg-fuchsia-500" },
  SUPERADMIN: { label: "Süper Admin", color: "text-red-700", dot: "bg-red-500" },
  MUHASEBE: { label: "Muhasebe", color: "text-indigo-700", dot: "bg-indigo-500" },
};

export default function OgrencilerPage() {
  const { showToast } = useToast();
  const [filterRole, setFilterRole] = useState<string>("all");
  const [filterStatus, setFilterStatus] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [filterGroup, setFilterGroup] = useState<string>("all");
  const [filterDate, setFilterDate] = useState<string>("all");
  const [sortBy, setSortBy] = useState<string>("newest");
  
  const [groups, setGroups] = useState<any[]>([]);
  const [users, setUsers] = useState<any[]>([]);
  const [currentUserRole, setCurrentUserRole] = useState<string>("");
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  // Pagination States
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);
  const [totalCount, setTotalCount] = useState(0);
  const [totalPages, setTotalPages] = useState(1);

  // Modal States
  const [showStudentModal, setShowStudentModal] = useState(false);
  const [showExcelModal, setShowExcelModal] = useState(false);
  const [showBulkDeleteModal, setShowBulkDeleteModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingUser, setEditingUser] = useState<any>(null);
  
  // Real-time UI
  const [newStudentName, setNewStudentName] = useState("");
  const [newStudentGroup, setNewStudentGroup] = useState("");
  const [selectedUsers, setSelectedUsers] = useState<string[]>([]);
  const [bulkAssignGroupId, setBulkAssignGroupId] = useState("");

  const fetchData = async () => {
    setLoading(true);
    const [fetchedGroups, fetchedUsersData, fetchedStats, me] = await Promise.all([
      getGroups(),
      getUsers({ role: filterRole, status: filterStatus, search: searchQuery, groupId: filterGroup, dateRange: filterDate, sortBy, page: currentPage, pageSize }),
      getUserStats(),
      getCurrentUser()
    ]);
    setGroups(fetchedGroups);
    setUsers(fetchedUsersData.users);
    setTotalCount(fetchedUsersData.totalCount);
    setTotalPages(fetchedUsersData.totalPages);
    setStats(fetchedStats);
    if (me) setCurrentUserRole(me.role);
    setLoading(false);
  };

  useEffect(() => {
    fetchData();
  }, [filterRole, filterStatus, filterGroup, filterDate, sortBy, currentPage, pageSize]); 

  // Search Debounce Effect
  useEffect(() => {
    const timer = setTimeout(() => {
      fetchData();
    }, 500);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  // Form Handlers
  const handleCreateStudent = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    try {
      await createStudent({
        name: formData.get("name") as string,
        email: formData.get("email") as string,
        phone: formData.get("phone") as string,
        password: formData.get("password") as string,
        groupId: formData.get("groupId") as string,
        role: formData.get("role") as string
      });
      setShowStudentModal(false);
      setNewStudentName("");
      setNewStudentGroup("");
      fetchData();
    } catch (error: any) {
      showToast(error.message, "error");
    }
  };

  const handleUpdateStudent = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!editingUser) return;
    const formData = new FormData(e.currentTarget);
    try {
      await updateStudent(editingUser.id, {
        name: formData.get("name") as string,
        email: formData.get("email") as string,
        phone: formData.get("phone") as string,
        password: formData.get("password") as string,
        groupId: formData.get("groupId") as string,
        role: formData.get("role") as string
      });
      setShowEditModal(false);
      setEditingUser(null);
      fetchData();
    } catch (error: any) {
      showToast(error.message, "error");
    }
  };

  const handleToggleStatus = async (id: string, current: boolean) => {
    await toggleUserStatus(id, !current);
    fetchData();
  };

  const handleBulkAssign = async () => {
    if (!bulkAssignGroupId || selectedUsers.length === 0) return;
    const isConfirmed = confirm(`${selectedUsers.length} kullanıcıyı seçili gruba atamak istediğinize emin misiniz?`);
    if (isConfirmed) {
       await bulkAssignStudents(bulkAssignGroupId, selectedUsers);
       setSelectedUsers([]);
       setBulkAssignGroupId("");
       fetchData();
    }
  };

  const handleBulkToggle = async (isActive: boolean) => {
    if (selectedUsers.length === 0) return;
    try {
      await bulkToggleUserStatus(selectedUsers, isActive);
      setSelectedUsers([]);
      fetchData();
    } catch (error: any) {
      showToast(error.message, "error");
    }
  };

  const executeBulkDelete = async () => {
    if (selectedUsers.length === 0) return;
    try {
      await bulkDeleteStudents(selectedUsers);
      setSelectedUsers([]);
      setShowBulkDeleteModal(false);
      fetchData();
    } catch (error: any) {
      showToast(error.message, "error");
    }
  };
  
  const toggleSelectAll = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.checked) setSelectedUsers(users.map(u => u.id));
    else setSelectedUsers([]);
  };

  const handleExcelUpload = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    try {
      const res = await importStudentsExcel(formData);
      showToast(`${res.count} öğrenci başarıyla yüklendi.`, "success");
      setShowExcelModal(false);
      fetchData();
    } catch (err: any) {
      showToast("Excel yükleme hatası: " + err.message, "error");
    }
  };

  const handleExportExcel = () => {
    if (users.length === 0) {
      showToast("Dışa aktarılacak kullanıcı bulunamadı!", "error");
      return;
    }
    const exportData = users.map(u => ({
      "Ad Soyad": u.name || "İsimsiz",
      "Email": u.email,
      "Telefon": u.phone || "-",
      "Rol": u.role === "ADMIN" ? "Yetkili" : (u.role === "EDITOR" ? "Editör" : "Öğrenci"),
      "Grup": u.group?.name || "-",
      "Durum": u.isActive ? "Aktif" : "Pasif",
      "Kayıt Tarihi": new Date(u.createdAt).toLocaleDateString("tr-TR")
    }));

    const worksheet = XLSX.utils.json_to_sheet(exportData);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "Kullanicilar");
    XLSX.writeFile(workbook, `Kullanici_Listesi_${new Date().toLocaleDateString("tr-TR")}.xlsx`);
  };

  const handleDownloadTemplate = () => {
    const templateData = [{
      "Ad Soyad": "Örnek Öğrenci",
      "Email": "ornek@4takademi.com",
      "Telefon": "05554443322",
      "Şifre": "123456",
      "Grup": "KPSS Lisans",
    }, {
      "Ad Soyad": "Mehmet Veli (Şifresiz)",
      "Email": "ikinci@gmail.com",
      "Telefon": "",
      "Şifre": "",
      "Grup": "",
    }];

    const worksheet = XLSX.utils.json_to_sheet(templateData);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "Sablon");
    XLSX.writeFile(workbook, "Muro_Iceri_Aktarma_Sablonu.xlsx");
  };

  const getInitials = (name: string) => {
    if (!name) return "X";
    const parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  return (
    <div className="max-w-[1400px] mx-auto text-slate-800 space-y-6">
      
      {/* Header and Actions */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-black text-slate-900 tracking-tight">Kullanıcılar</h1>
          <p className="text-slate-500 mt-1.5 text-sm">Toplam {stats?.total || 0} kullanıcıyı yönetin</p>
        </div>
        <div className="flex gap-3">
          <button 
            onClick={handleExportExcel}
            className="flex items-center gap-2 px-4 py-2 bg-white text-slate-700 hover:bg-slate-50 border border-slate-200 rounded-lg transition-colors font-semibold text-sm shadow-sm"
          >
            <Download className="w-4 h-4" /> Excel'e Aktar
          </button>
          <button 
            onClick={() => setShowExcelModal(true)}
            className="flex items-center gap-2 px-4 py-2 bg-white text-slate-700 hover:bg-slate-50 border border-slate-200 rounded-lg transition-colors font-semibold text-sm shadow-sm"
          >
            <Upload className="w-4 h-4" /> İçe Aktar
          </button>
          <button 
            onClick={() => setShowStudentModal(true)}
            className="flex items-center gap-2 px-5 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg transition-colors font-semibold shadow-md shadow-slate-900/10 text-sm"
          >
            <Plus className="w-4 h-4" /> Yeni Kullanıcı
          </button>
        </div>
      </div>

      {/* KPI Dashboard Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {/* Total */}
        <div onClick={() => { setFilterStatus("all"); setFilterRole("all"); }} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-slate-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Toplam</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-slate-900">{stats?.total || 0}</h3>
            <Users className="w-6 h-6 text-slate-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        {/* Active */}
        <div onClick={() => setFilterStatus("active")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-emerald-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Aktif</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-emerald-500">{stats?.active || 0}</h3>
            <UserCheck className="w-6 h-6 text-emerald-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        {/* Passive */}
        <div onClick={() => setFilterStatus("passive")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-red-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Pasif</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-red-500">{stats?.passive || 0}</h3>
            <UserX className="w-6 h-6 text-red-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        {/* Students */}
        <div onClick={() => setFilterRole("STUDENT")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-blue-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Öğrenci</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-blue-500">{stats?.students || 0}</h3>
            <GraduationCap className="w-6 h-6 text-blue-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        {/* Admins */}
        <div onClick={() => setFilterRole("ADMIN")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-fuchsia-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Yetkili</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-fuchsia-500">{stats?.teachers || 0}</h3>
            <ShieldCheck className="w-6 h-6 text-fuchsia-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden flex flex-col">
        {/* Bulk Actions Banner */}
        {selectedUsers.length > 0 && (
           <div className="bg-blue-50/80 border-b border-blue-100 px-4 py-3 flex items-center justify-between">
              <div className="flex items-center gap-3">
                 <span className="bg-blue-600 text-white text-xs font-bold px-2.5 py-1 rounded-md shadow-sm">{selectedUsers.length} Seçildi</span>
                 <span className="text-sm font-semibold text-blue-900 hidden sm:block">Kullanıcılar üzerinde toplu işlem yapın</span>
              </div>
              <div className="flex items-center gap-3">
                 {/* Toplu Atama */}
                 <div className="flex items-center gap-2 border-r border-blue-200/60 pr-3">
                    <select 
                      value={bulkAssignGroupId} 
                      onChange={(e) => setBulkAssignGroupId(e.target.value)}
                      className="bg-white border border-blue-200 text-blue-900 text-xs sm:text-sm font-semibold rounded-lg px-3 py-1.5 outline-none focus:border-blue-500 shadow-sm"
                    >
                      <option value="">Gruba Ata...</option>
                      {groups.map(g => <option key={g.id} value={g.id}>{g.name}</option>)}
                    </select>
                    <button onClick={handleBulkAssign} disabled={!bulkAssignGroupId} className="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs sm:text-sm font-bold rounded-lg disabled:opacity-50 transition-colors shadow-sm">
                      Ata
                    </button>
                 </div>
                 <div className="flex items-center gap-1.5 border-r border-blue-200/60 pr-3 mr-1">
                    <button onClick={() => handleBulkToggle(true)} className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200 hover:border-emerald-300 text-xs sm:text-sm font-bold rounded-lg transition-colors shadow-sm">
                       <UserCheck className="w-4 h-4" /> <span className="hidden sm:inline">Aktife Al</span>
                    </button>
                    <button onClick={() => handleBulkToggle(false)} className="flex items-center gap-1.5 px-3 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-700 border border-amber-200 hover:border-amber-300 text-xs sm:text-sm font-bold rounded-lg transition-colors shadow-sm">
                       <UserX className="w-4 h-4" /> <span className="hidden sm:inline">Pasife Al</span>
                    </button>
                 </div>
                 {/* Toplu Silme */}
                 <button onClick={() => setShowBulkDeleteModal(true)} className="flex items-center gap-1.5 px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 border border-red-200 hover:border-red-300 text-xs sm:text-sm font-bold rounded-lg transition-colors shadow-sm">
                    <Trash2 className="w-4 h-4" /> <span className="hidden sm:inline">Seçilileri</span> Sil
                 </button>
                 <button onClick={() => setSelectedUsers([])} className="p-1.5 text-blue-400 hover:text-blue-700 hover:bg-blue-100 rounded-lg transition-colors">
                    <X className="w-4 h-4" />
                 </button>
              </div>
           </div>
        )}

        {/* Toolbar */}
        <div className="p-4 border-b border-slate-100 flex flex-col lg:flex-row lg:items-center gap-4 bg-slate-50/50">
          <div className="flex-1 relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input 
              type="text"
              placeholder="İsim, email veya telefon ara..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-sm font-medium transition-colors shadow-sm"
            />
          </div>
          
          <div className="flex items-center gap-3 flex-wrap lg:flex-nowrap">
            <select 
              value={filterGroup}
              onChange={(e) => setFilterGroup(e.target.value)}
              className="bg-white border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl px-4 py-2.5 outline-none focus:border-blue-500 transition-colors shadow-sm min-w-[140px]"
            >
              <option value="all">Gruplar</option>
              {groups.map(g => <option key={g.id} value={g.id}>{g.name}</option>)}
            </select>
            
            <select 
              value={filterDate}
              onChange={(e) => setFilterDate(e.target.value)}
              className="bg-white border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl px-4 py-2.5 outline-none focus:border-blue-500 transition-colors shadow-sm min-w-[140px]"
            >
              <option value="all">Kayıt Tarihi</option>
              <option value="today">Bugün</option>
              <option value="week">Son 7 Gün</option>
              <option value="month">Bu Ay</option>
            </select>

            <select 
              value={filterRole}
              onChange={(e) => setFilterRole(e.target.value)}
              className="bg-white border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl px-4 py-2.5 outline-none focus:border-blue-500 transition-colors shadow-sm min-w-[140px]"
            >
              <option value="all">Roller</option>
              <option value="STUDENT">Öğrenci</option>
              <option value="EDITOR">Editör</option>
              <option value="ASISTAN">Asistan</option>
              <option value="ADMIN">Admin</option>
              <option value="SUPERADMIN">Süper Admin</option>
            </select>
            
            <select 
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="bg-white border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl px-4 py-2.5 outline-none focus:border-blue-500 transition-colors shadow-sm min-w-[140px]"
            >
              <option value="all">Durumlar</option>
              <option value="active">Aktif</option>
              <option value="passive">Pasif</option>
            </select>

            <select 
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="bg-white border border-slate-200 text-slate-700 text-sm font-semibold rounded-xl px-4 py-2.5 outline-none focus:border-blue-500 transition-colors shadow-sm min-w-[140px]"
            >
              <option value="newest">En Yeni Kayıt</option>
              <option value="oldest">En Eski Kayıt</option>
              <option value="az">İsim (A-Z)</option>
              <option value="za">İsim (Z-A)</option>
            </select>
            
            <button onClick={fetchData} className="p-2.5 bg-white text-slate-600 hover:bg-slate-50 hover:text-blue-600 border border-slate-200 rounded-xl transition-colors shadow-sm">
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin text-blue-600' : ''}`} />
            </button>
          </div>
        </div>

        {/* Table / List */}
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead className="text-[10px] text-slate-500 uppercase tracking-widest bg-white border-b border-slate-100">
              <tr>
                <th className="px-6 py-4 w-10">
                  <input type="checkbox" checked={selectedUsers.length === users.length && users.length > 0} onChange={toggleSelectAll} className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500" />
                </th>
                <th className="px-6 py-4 font-bold">Kullanıcı</th>
                <th className="px-6 py-4 font-bold">Email</th>
                <th className="px-6 py-4 font-bold">Rol</th>
                <th className="px-6 py-4 font-bold">Grup</th>
                <th className="px-6 py-4 font-bold">Durum</th>
                <th className="px-6 py-4 font-bold">Katılım / Kayıt</th>
                <th className="px-6 py-4 text-right font-bold">İşlemler</th>
              </tr>
            </thead>
            <tbody>
              {users.map(u => (
                <tr key={u.id} className="border-b border-slate-50 hover:bg-slate-50/60 transition-colors group">
                  <td className="px-6 py-4">
                    <input type="checkbox" checked={selectedUsers.includes(u.id)} onChange={(e) => {
                       if (e.target.checked) setSelectedUsers(prev => [...prev, u.id]);
                       else setSelectedUsers(prev => prev.filter(id => id !== u.id));
                    }} className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500" />
                  </td>
                  
                  {/* Kullanıcı */}
                  <td className="px-6 py-4">
                    <Link href={`/muro-admin/ogrenciler/${u.id}`} className="flex items-center gap-3 hover:text-blue-600 transition-colors group/link">
                      <div className="w-10 h-10 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-600 font-bold text-xs shrink-0 group-hover:bg-blue-50 group-hover:text-blue-600 group-hover:border-blue-100 transition-colors">
                        {getInitials(u.name || "")}
                      </div>
                      <div className="flex flex-col">
                        <span className="font-bold text-slate-800 group-hover/link:text-blue-600 transition-colors">{u.name || "İsimsiz Kullanıcı"}</span>
                        <span className="text-[11px] text-slate-500 font-medium tracking-wide mt-0.5">{u.phone || "Telefon Yok"}</span>
                      </div>
                    </Link>
                  </td>
                  
                  {/* Email */}
                  <td className="px-6 py-4 text-slate-500 text-xs font-medium">
                    {u.email}
                  </td>
                  
                  {/* Rol */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                       <div className={`w-2 h-2 rounded-full ${ROLE_LABELS[u.role]?.dot || 'bg-slate-400'}`}></div>
                       <span className={`font-bold text-xs ${ROLE_LABELS[u.role]?.color || 'text-slate-500'}`}>{ROLE_LABELS[u.role]?.label || u.role}</span>
                    </div>
                  </td>

                  {/* Grup */}
                  <td className="px-6 py-4">
                    <div className="flex flex-wrap gap-1 max-w-[180px]">
                       {u.groups && u.groups.length > 0 ? (
                         u.groups.map((g: any) => (
                           <span key={g.id} className="bg-blue-50 text-blue-600 border border-blue-100 px-2 py-0.5 rounded-md text-[10px] font-bold whitespace-nowrap">
                             {g.name}
                           </span>
                         ))
                       ) : (
                         <span className="opacity-50 text-slate-400 font-semibold">—</span>
                       )}
                    </div>
                  </td>
                  
                  {/* Durum */}
                  <td className="px-6 py-4">
                    <button onClick={() => handleToggleStatus(u.id, u.isActive)} className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider transition-colors outline-none border ${u.isActive ? 'bg-emerald-50/50 text-emerald-600 border-emerald-200 hover:bg-emerald-100' : 'bg-slate-100 text-slate-500 border-slate-200 hover:bg-slate-200'}`}>
                      <div className={`w-1.5 h-1.5 rounded-full ${u.isActive ? 'bg-emerald-500' : 'bg-slate-400'}`}></div>
                      {u.isActive ? 'Aktif' : 'Pasif'}
                    </button>
                  </td>

                  {/* Katılım (Tarih) */}
                  <td className="px-6 py-4 text-slate-500 text-xs font-medium">
                     {new Date(u.createdAt).toLocaleDateString("tr-TR")}
                  </td>

                  {/* İşlemler */}
                  <td className="px-6 py-4 text-right">
                     <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                       <Link href={`/muro-admin/ogrenciler/${u.id}`} className="p-2 text-slate-400 hover:text-blue-600 bg-white hover:bg-blue-50 rounded-lg transition-colors border border-transparent hover:border-blue-100">
                         <Eye className="w-4 h-4" />
                       </Link>
                       <button onClick={() => { setEditingUser(u); setShowEditModal(true); }} className="p-2 text-slate-400 hover:text-amber-600 bg-white hover:bg-amber-50 rounded-lg transition-colors border border-transparent hover:border-amber-100" title="Düzenle">
                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="lucide lucide-pencil"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/></svg>
                       </button>
                       {u.role !== 'ADMIN' && (
                         <button onClick={async () => { await deleteStudent(u.id); fetchData(); }} className="p-2 text-slate-400 hover:text-red-600 bg-white hover:bg-red-50 rounded-lg transition-colors border border-transparent hover:border-red-100" title="Sil">
                           <Trash2 className="w-4 h-4" />
                         </button>
                       )}
                     </div>
                  </td>
                </tr>
              ))}
              {users.length === 0 && !loading && (
                <tr>
                  <td colSpan={8} className="px-6 py-20 text-center">
                    <div className="flex flex-col items-center justify-center text-slate-400">
                      <Search className="w-8 h-8 mb-3 opacity-20" />
                      <p className="font-medium">Arama kriterlerine uygun kullanıcı bulunamadı.</p>
                    </div>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
        
        {/* Pagination Footer */}
        <div className="border-t border-slate-100 px-6 py-4 flex items-center justify-between bg-slate-50/30">
           <div className="flex items-center gap-3 text-xs font-semibold text-slate-500">
             Sayfa başı:
             <select 
               value={pageSize}
               onChange={(e) => { setPageSize(Number(e.target.value)); setCurrentPage(1); }}
               className="bg-white border border-slate-200 rounded-lg px-2.5 py-1 font-bold outline-none cursor-pointer"
             >
               <option value={25}>25</option>
               <option value={50}>50</option>
               <option value={100}>100</option>
             </select>
             <span>Toplam <strong className="text-slate-800">{totalCount}</strong> kullanıcı</span>
           </div>
           {totalPages > 1 && (
             <div className="flex items-center gap-2">
               <button
                 onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                 disabled={currentPage === 1}
                 className="px-3 py-1.5 border border-slate-200 bg-white hover:bg-slate-50 disabled:opacity-50 rounded-lg text-xs font-bold transition"
               >Önceki</button>
               <span className="px-3 py-1.5 border border-slate-200 bg-slate-50 rounded-lg text-xs font-bold text-slate-800">{currentPage} / {totalPages}</span>
               <button
                 onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                 disabled={currentPage === totalPages}
                 className="px-3 py-1.5 border border-slate-200 bg-white hover:bg-slate-50 disabled:opacity-50 rounded-lg text-xs font-bold transition"
               >Sonraki</button>
             </div>
           )}
        </div>
      </div>

      {/* MODALS START (Aynen korundu ve modernize edildi) */}
      
      {/* Excel Yükleme Modal */}
      {showExcelModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl flex flex-col overflow-hidden border border-slate-200 p-10 relative animate-in fade-in zoom-in-95">
            <button 
              onClick={() => setShowExcelModal(false)}
              className="absolute top-6 right-6 text-slate-400 hover:text-slate-700 bg-slate-100 hover:bg-slate-200 p-2 rounded-full transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
            <div className="flex items-center justify-between mb-2">
              <div>
                <h2 className="text-2xl font-bold tracking-tight text-slate-900 mb-1">Excel İle Toplu Yükleme</h2>
                <p className="text-sm text-slate-500">Sisteme saniyeler içinde binlerce kullanıcı kaydedin.</p>
              </div>
            </div>
            
            <div className="bg-blue-50 border border-blue-100 rounded-xl p-5 mb-6 mt-4">
              <div className="flex items-center justify-between mb-3 border-b border-blue-100/50 pb-3">
                <h4 className="text-xs font-bold text-blue-800 uppercase tracking-widest flex items-center gap-2">Sistem Nasıl Çalışır?</h4>
                <button onClick={handleDownloadTemplate} className="flex items-center gap-1.5 px-3 py-1.5 bg-white text-blue-600 hover:bg-blue-600 hover:text-white border border-blue-200 hover:border-transparent rounded-lg text-xs font-bold transition-colors shadow-sm">
                  <Download className="w-3.5 h-3.5" /> Örnek Şablon İndir
                </button>
              </div>
              <ul className="text-xs text-blue-700/80 space-y-2 list-disc pl-4 font-medium">
                <li><strong className="text-blue-800">Ad Soyad</strong> ve <strong className="text-blue-800">Email</strong> sütunlarının doldurulması <strong className="bg-blue-200 px-1 py-0.5 rounded text-blue-900">zorunludur</strong>.</li>
                <li><strong className="text-blue-800">Şifre</strong> boş bırakılırsa, kullanıcı otomatik olarak <code className="bg-blue-200 px-1 py-0.5 rounded font-mono text-blue-900 tracking-wider">123456</code> parolasıyla sisteme dahil edilir.</li>
                <li><strong className="text-blue-800">Grup</strong> hücresine yazdığınız grup adı sistemde bulunuyorsa kullanıcı o gruba atanır. <strong>Eğer mevcut değilse, sistem o isimde yeni bir grup yaratır.</strong></li>
                <li>Yüklemeden önce sütun başlıklarını indirdiğiniz şablondakiyle <strong>birebir aynı</strong> tutmaya özen gösterin.</li>
              </ul>
            </div>
            
            <form onSubmit={handleExcelUpload} className="space-y-6">
              <div className="border-2 border-dashed border-blue-200 hover:border-blue-300 bg-blue-50/50 p-10 rounded-2xl text-center transition-colors">
                <input 
                  type="file" 
                  name="file" 
                  accept=".xlsx, .xls" 
                  required 
                  className="w-full text-sm text-slate-600 file:mr-4 file:py-3 file:px-6 file:rounded-xl file:border-0 file:text-sm file:font-bold file:bg-blue-600 file:text-white hover:file:bg-blue-700 cursor-pointer shadow-sm file:transition-colors" 
                />
              </div>
              <button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 py-4 items-center justify-center flex gap-2 rounded-xl text-white font-bold text-lg transition-all shadow-md shadow-blue-600/20 active:scale-[0.98]">
                <Upload className="w-5 h-5" /> Verileri Sisteme Yazdır
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Yeni Kullanıcı Manuel Modal */}
      {showStudentModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-4xl shadow-2xl flex overflow-hidden text-slate-900 border border-slate-200 animate-in fade-in zoom-in-95">
            {/* Sol Pane - Dinamik Önizleme */}
            <div className="hidden md:flex flex-col items-center justify-center bg-slate-50 w-[40%] p-8 border-r border-slate-100 relative">
              <div className="w-24 h-24 bg-blue-600 rounded-3xl text-white flex items-center justify-center mb-6 shadow-md shadow-blue-600/20 rotate-3">
                <Users className="w-10 h-10" />
              </div>
              <h3 className="text-xl font-bold text-slate-800 text-center truncate w-full px-4">
                {newStudentName || "Öğrenci Adı"}
              </h3>
              
              <div className="mt-8 bg-white border border-slate-200 shadow-sm px-4 py-2.5 rounded-xl flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-emerald-500"></div>
                <span className="text-xs font-bold uppercase tracking-wider text-slate-600 truncate max-w-[150px]">
                  {newStudentGroup ? groups.find(g => g.id === newStudentGroup)?.name : "Grupsuz"}
                </span>
              </div>
            </div>

            {/* Sağ Pane - Form */}
            <div className="p-10 w-full relative">
              <button 
                onClick={() => setShowStudentModal(false)}
                className="absolute top-6 right-6 text-slate-400 hover:text-slate-700 bg-slate-100 hover:bg-slate-200 p-2 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>

              <div className="mb-10 w-full pr-12">
                <h2 className="text-2xl font-bold tracking-tight text-slate-900">Kullanıcı Bilgileri</h2>
                <p className="text-slate-500 text-sm mt-1">Sisteme bireysel kullanıcı kaydı oluşturun.</p>
              </div>

              <form onSubmit={handleCreateStudent} className="space-y-5">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Ad Soyad</label>
                    <input 
                      name="name" 
                      required 
                      value={newStudentName}
                      onChange={(e) => setNewStudentName(e.target.value)}
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold placeholder:font-medium placeholder:text-slate-400 hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                      placeholder="Örn: Ali Veli" 
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">E-posta</label>
                    <input 
                      name="email" 
                      type="email"
                      required 
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold placeholder:font-medium placeholder:text-slate-400 hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                      placeholder="Örn: ali@gmail.com" 
                    />
                  </div>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Telefon</label>
                    <input 
                      name="phone" 
                      type="tel"
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold placeholder:font-medium placeholder:text-slate-400 hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                      placeholder="Örn: 0555..." 
                    />
                  </div>
                  <div>
                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Şifre (Boş ise 123456)</label>
                    <input 
                      name="password" 
                      type="text"
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold placeholder:font-medium placeholder:text-slate-400 hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                      placeholder="******" 
                    />
                  </div>
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Rol / Yetki</label>
                    <select 
                      name="role" 
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm"
                    >
                      <option value="STUDENT">Öğrenci</option>
                      <option value="EDITOR">Editör (Sınav Yönetimi)</option>
                      <option value="ASISTAN">Asistan (Muhasebesiz)</option>
                      <option value="ADMIN">Admin (Tam Yetki)</option>
                      {currentUserRole === "SUPERADMIN" && (
                        <option value="SUPERADMIN">Süper Admin</option>
                      )}
                    </select>
                  </div>
                  <div>
                    <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Grup / Sınıf Ataması</label>
                    <select 
                      name="groupId" 
                      value={newStudentGroup}
                      onChange={e => setNewStudentGroup(e.target.value)}
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-blue-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm"
                    >
                      <option value="">-- Herhangi bir gruba atama --</option>
                      {groups.map(g => <option key={g.id} value={g.id}>{g.name}</option>)}
                    </select>
                  </div>
                </div>
                <div className="pt-4">
                  <button type="submit" className="w-full bg-slate-900 hover:bg-slate-800 py-3.5 rounded-xl text-white font-bold transition-all shadow-md shadow-slate-900/20 active:scale-[0.98]">
                    Kullanıcıyı Kaydet
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Kullanıcı Düzenleme Modal */}
      {showEditModal && editingUser && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl flex flex-col overflow-hidden text-slate-900 border border-slate-200 animate-in fade-in zoom-in-95 p-10 relative">
            <button 
              onClick={() => { setShowEditModal(false); setEditingUser(null); }}
              className="absolute top-6 right-6 text-slate-400 hover:text-slate-700 bg-slate-100 hover:bg-slate-200 p-2 rounded-full transition-colors"
            >
              <X className="w-5 h-5" />
            </button>

            <div className="mb-8 w-full pr-12">
              <h2 className="text-2xl font-bold tracking-tight text-slate-900">Kullanıcıyı Düzenle</h2>
              <p className="text-slate-500 text-sm mt-1">{editingUser.name} adlı kullanıcının bilgilerini güncelliyorsunuz.</p>
            </div>

            <form onSubmit={handleUpdateStudent} className="space-y-5">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Ad Soyad</label>
                  <input 
                    name="name" 
                    required 
                    defaultValue={editingUser.name || ""}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-amber-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">E-posta</label>
                  <input 
                    name="email" 
                    type="email"
                    required 
                    defaultValue={editingUser.email || ""}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-amber-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Telefon</label>
                  <input 
                    name="phone" 
                    type="tel"
                    defaultValue={editingUser.phone || ""}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-amber-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm" 
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2 text-rose-500">Mevcut Şifre / Yeni Şifre</label>
                  <input 
                    name="password" 
                    type="text"
                    defaultValue={editingUser.password}
                    className="w-full bg-rose-50 border border-rose-200 rounded-xl p-3.5 text-rose-700 font-bold hover:border-rose-300 focus:border-rose-500 focus:ring-0 outline-none transition-colors shadow-sm" 
                    placeholder="Değiştirmek için yazın..." 
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Rol / Yetki</label>
                  <select 
                    name="role" 
                    defaultValue={editingUser.role}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-amber-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm"
                  >
                    <option value="STUDENT">Öğrenci</option>
                    <option value="EDITOR">Editör (Sınav Yönetimi)</option>
                    <option value="ASISTAN">Asistan (Muhasebesiz)</option>
                    <option value="ADMIN">Admin (Tam Yetki)</option>
                    <option value="MUHASEBE">Muhasebe (Sadece Finans)</option>
                    {currentUserRole === "SUPERADMIN" && (
                      <option value="SUPERADMIN">Süper Admin</option>
                    )}
                  </select>
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Grup / Sınıf Ataması</label>
                  <select 
                    name="groupId" 
                    defaultValue={editingUser.groups?.[0]?.id || ""}
                    className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3.5 text-slate-900 font-bold hover:border-slate-300 focus:border-amber-500 focus:bg-white focus:ring-0 outline-none transition-colors shadow-sm"
                  >
                    <option value="">-- Herhangi bir gruba atama --</option>
                    {groups.map(g => <option key={g.id} value={g.id}>{g.name}</option>)}
                  </select>
                </div>
              </div>
              <div className="pt-4 flex gap-3">
                <button type="button" onClick={() => { setShowEditModal(false); setEditingUser(null); }} className="w-1/3 bg-slate-100 hover:bg-slate-200 py-3.5 rounded-xl text-slate-700 font-bold transition-all">
                  İptal
                </button>
                <button type="submit" className="w-2/3 bg-amber-500 hover:bg-amber-600 py-3.5 rounded-xl text-white font-bold transition-all shadow-md shadow-amber-500/20 active:scale-[0.98]">
                  Değişiklikleri Kaydet
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Toplu Silme Modal */}
      {showBulkDeleteModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl flex flex-col overflow-hidden border border-slate-200 p-8 relative animate-in fade-in zoom-in-95">
            <div className="w-16 h-16 bg-red-50 text-red-500 rounded-full flex items-center justify-center mb-6 mx-auto">
              <Trash2 className="w-8 h-8" />
            </div>
            <h2 className="text-xl font-bold tracking-tight text-slate-900 mb-2 text-center">Toplu Silme İşlemi</h2>
            <p className="text-sm text-slate-500 text-center mb-8">
              Seçili <strong className="text-slate-800">{selectedUsers.length}</strong> kullanıcıyı kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz.
            </p>
            
            <div className="flex items-center gap-3">
              <button 
                onClick={() => setShowBulkDeleteModal(false)}
                className="flex-1 py-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl transition-colors"
              >
                İptal Et
              </button>
              <button 
                onClick={executeBulkDelete}
                className="flex-1 py-3 bg-red-600 hover:bg-red-700 text-white font-bold rounded-xl shadow-md shadow-red-600/20 transition-all active:scale-[0.98]"
              >
                Evet, Sil
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
