"use client";

import { useState, useEffect, useMemo } from "react";
import { Users, Plus, Trash2, X, ChevronRight, ChevronDown, Search, Layers, ShieldCheck, GraduationCap, RefreshCw, Copy, Edit2, Calendar, BookOpen, Settings, AlertTriangle } from "lucide-react";
import { getGroups, getGroupStats, createGroup, deleteGroup, toggleGroupStatus, getGroupDetails, updateGroup, bulkRemoveFromGroup, bulkTransferToGroup } from "@/app/actions/userActions";
import Link from "next/link";
import dayjs from "dayjs";

export default function GruplarPage() {
  const [filterStatus, setFilterStatus] = useState<string>("all");
  const [searchQuery, setSearchQuery] = useState<string>("");
  
  const [groups, setGroups] = useState<any[]>([]);
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  // Split-Pane State
  const [selectedGroupId, setSelectedGroupId] = useState<string | null>(null);
  const [groupDetails, setGroupDetails] = useState<any>(null);
  const [detailsLoading, setDetailsLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<"members" | "exams" | "settings">("members");

  // Accordion State
  const [expandedGroups, setExpandedGroups] = useState<Record<string, boolean>>({});

  // Selection
  const [selectedUsers, setSelectedUsers] = useState<string[]>([]);

  // Modals
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [creatingSubgroupFor, setCreatingSubgroupFor] = useState<string | null>(null);
  const [showTransferModal, setShowTransferModal] = useState(false);

  const fetchData = async () => {
    setLoading(true);
    const [fetchedGroups, fetchedStats] = await Promise.all([
      getGroups({ search: searchQuery, status: filterStatus, sortBy: "newest" }),
      getGroupStats()
    ]);
    setGroups(fetchedGroups);
    setStats(fetchedStats);
    setLoading(false);
  };

  // Debounce Search
  useEffect(() => {
    const timer = setTimeout(() => {
      fetchData();
    }, 400);
    return () => clearTimeout(timer);
  }, [searchQuery, filterStatus]);

  // Fetch details when selection changes
  useEffect(() => {
    if (selectedGroupId) {
      loadGroupDetails(selectedGroupId);
    } else {
      setGroupDetails(null);
    }
    setSelectedUsers([]);
  }, [selectedGroupId]);

  const loadGroupDetails = async (id: string) => {
    setDetailsLoading(true);
    try {
      const details = await getGroupDetails(id);
      setGroupDetails(details);
    } catch (e) {
      console.error(e);
    }
    setDetailsLoading(false);
  };

  const handleCreateGroup = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    try {
      await createGroup({
        name: formData.get("name") as string,
        description: formData.get("description") as string,
        price: Number(formData.get("price") || 0),
        parentId: creatingSubgroupFor || undefined
      });
      setShowCreateModal(false);
      setCreatingSubgroupFor(null);
      fetchData();
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleUpdateGroup = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!groupDetails) return;
    const formData = new FormData(e.currentTarget);
    try {
      const dateStr = formData.get("expireAt") as string;
      await updateGroup(groupDetails.id, {
        name: formData.get("name") as string,
        description: formData.get("description") as string,
        price: Number(formData.get("price") || 0),
        expireAt: dateStr ? new Date(dateStr) : null
      });
      alert("Başarıyla güncellendi!");
      loadGroupDetails(groupDetails.id);
      fetchData();
    } catch (error: any) {
      alert(error.message);
    }
  };

  const handleToggleStatus = async () => {
    if (!groupDetails) return;
    try {
      await toggleGroupStatus(groupDetails.id, !groupDetails.isActive);
      loadGroupDetails(groupDetails.id);
      fetchData();
    } catch (e: any) {
      alert(e.message);
    }
  };

  const handleDeleteGroup = async () => {
    if (!groupDetails) return;
    if (!confirm("Bu grubu tamamen silmek istediğinize emin misiniz? Alt gruplar da etkilenebilir.")) return;
    try {
      await deleteGroup(groupDetails.id);
      setSelectedGroupId(null);
      fetchData();
    } catch (e: any) {
      alert(e.message);
    }
  };

  const handleBulkRemoveUsers = async () => {
    if (!groupDetails || selectedUsers.length === 0) return;
    if (!confirm(`Seçili ${selectedUsers.length} üyeyi bu gruptan çıkarmak istediğinize emin misiniz?`)) return;
    try {
      await bulkRemoveFromGroup(groupDetails.id, selectedUsers);
      setSelectedUsers([]);
      loadGroupDetails(groupDetails.id);
      fetchData(); // For updating user count
    } catch (e: any) {
      alert(e.message);
    }
  };

  const executeTransfer = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!groupDetails || selectedUsers.length === 0) return;
    const formData = new FormData(e.currentTarget);
    const targetGroupId = formData.get("targetGroupId") as string;
    if (!targetGroupId) return alert("Lütfen bir hedef grup seçin.");
    
    try {
      await bulkTransferToGroup(groupDetails.id, targetGroupId, selectedUsers);
      setShowTransferModal(false);
      setSelectedUsers([]);
      loadGroupDetails(groupDetails.id);
      fetchData();
    } catch (e: any) {
      alert(e.message);
    }
  };

  const toggleAccordion = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setExpandedGroups(prev => ({ ...prev, [id]: !prev[id] }));
  };

  // Build tree
  const mainGroups = useMemo(() => groups.filter(g => !g.parentId), [groups]);
  const getSubgroups = (parentId: string) => groups.filter(g => g.parentId === parentId);

  return (
    <div className="max-w-[1400px] mx-auto text-slate-800 space-y-6">
      
      {/* KPI Dashboard Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div onClick={() => setFilterStatus("all")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-slate-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Toplam Grup</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-slate-900">{stats?.total || 0}</h3>
            <Layers className="w-6 h-6 text-slate-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Toplam Üye</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-blue-500">{stats?.totalStudentsInGroups || 0}</h3>
            <Users className="w-6 h-6 text-blue-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        <div onClick={() => setFilterStatus("active")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-emerald-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Aktif Gruplar</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-emerald-500">{stats?.active || 0}</h3>
            <ShieldCheck className="w-6 h-6 text-emerald-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>

        <div onClick={() => setFilterStatus("passive")} className="cursor-pointer bg-white rounded-2xl p-5 border border-slate-100 hover:border-red-300 shadow-sm relative overflow-hidden group transition-colors">
          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2 z-10 relative">Pasif Gruplar</p>
          <div className="flex items-end justify-between z-10 relative">
            <h3 className="text-3xl font-black text-red-500">{stats?.passive || 0}</h3>
            <AlertTriangle className="w-6 h-6 text-red-400 group-hover:scale-110 transition-transform" />
          </div>
        </div>
      </div>

      {/* Split Pane Container */}
      <div className="flex flex-col md:flex-row gap-6 min-h-[600px] items-stretch">
        
        {/* Left Pane: Group Tree */}
        <div className="w-full md:w-[380px] shrink-0 bg-white border border-slate-200 rounded-2xl shadow-sm flex flex-col overflow-hidden">
          <div className="p-4 border-b border-slate-100 bg-slate-50 flex items-center justify-between gap-3">
            <div className="relative flex-1">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input 
                type="text"
                placeholder="Grup ara..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-9 pr-4 py-2 bg-white border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-sm font-medium shadow-sm transition-colors"
              />
            </div>
            <button 
              onClick={() => { setCreatingSubgroupFor(null); setShowCreateModal(true); }}
              className="p-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl shadow-md transition-colors shadow-blue-600/20 shrink-0"
              title="Ana Grup Oluştur"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          <div className="flex-1 overflow-y-auto p-3 custom-scrollbar space-y-1">
            {loading ? (
              <div className="flex justify-center p-8"><RefreshCw className="w-6 h-6 animate-spin text-slate-400" /></div>
            ) : mainGroups.length === 0 ? (
              <div className="text-center p-8 text-sm text-slate-500">Grup bulunamadı.</div>
            ) : (
              mainGroups.map(group => {
                const subs = getSubgroups(group.id);
                const hasSubs = subs.length > 0;
                const isExpanded = expandedGroups[group.id];
                const isSelected = selectedGroupId === group.id;

                return (
                  <div key={group.id} className="flex flex-col">
                    {/* Main Group Node */}
                    <div 
                      onClick={() => setSelectedGroupId(group.id)}
                      className={`flex items-center gap-3 p-3 rounded-xl cursor-pointer transition-all border ${isSelected ? 'bg-blue-50 border-blue-200 shadow-sm' : 'hover:bg-slate-50 border-transparent'}`}
                    >
                      <button 
                        onClick={(e) => hasSubs ? toggleAccordion(group.id, e) : null}
                        className={`p-1 rounded-md transition-colors ${hasSubs ? 'hover:bg-slate-200 text-slate-500' : 'text-transparent cursor-default'}`}
                      >
                        <ChevronRight className={`w-4 h-4 transition-transform ${isExpanded ? 'rotate-90' : ''}`} />
                      </button>
                      
                      <div className="w-8 h-8 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
                        <Users className="w-4 h-4" />
                      </div>
                      
                      <div className="flex-1 min-w-0">
                        <h4 className={`text-sm font-bold truncate ${isSelected ? 'text-blue-900' : 'text-slate-800'}`}>
                          {group.name}
                        </h4>
                        <div className="flex items-center gap-3 text-[10px] uppercase tracking-widest font-bold text-slate-400 mt-2">
                          <span>{group._count?.users || 0} üye</span>
                          <span className="w-1 h-1 rounded-full bg-slate-300"></span>
                          <span>{(group._count?.exams || 0) + (group._count?.packages || 0)} sınav</span>
                          <span className="w-1 h-1 rounded-full bg-slate-300"></span>
                          <span className={group.isActive ? 'text-emerald-600' : 'text-slate-400'}>{group.isActive ? 'Aktif' : 'Pasif'}</span>
                        </div>
                      </div>
                    </div>

                    {/* Subgroups Container */}
                    {hasSubs && isExpanded && (
                      <div className="pl-12 mt-1 space-y-1 relative before:absolute before:left-7 before:top-0 before:bottom-4 before:w-px before:bg-slate-200">
                        {subs.map(sub => {
                          const isSubSelected = selectedGroupId === sub.id;
                          return (
                            <div 
                              key={sub.id} 
                              onClick={() => setSelectedGroupId(sub.id)}
                              className={`flex items-center gap-3 p-2.5 rounded-xl cursor-pointer transition-all border relative ${isSubSelected ? 'bg-blue-50 border-blue-200 shadow-sm' : 'hover:bg-slate-50 border-transparent'}`}
                            >
                              <div className="absolute left-[-20px] top-1/2 w-4 h-px bg-slate-200"></div>
                              <div className="w-6 h-6 rounded-md bg-indigo-50 text-indigo-500 flex items-center justify-center shrink-0">
                                <div className="w-2 h-2 rounded-full bg-current"></div>
                              </div>
                              <div className="flex-1 min-w-0">
                                <h4 className={`text-[13px] font-bold truncate ${isSubSelected ? 'text-blue-900' : 'text-slate-700'}`}>
                                  {sub.name}
                                </h4>
                                <div className="flex items-center gap-2 text-[10px] font-medium text-slate-500">
                                  <span>{sub._count?.users || 0} üye</span>
                                  <span className="w-1 h-1 rounded-full bg-slate-300"></span>
                                  <span className={sub.isActive ? 'text-emerald-600' : 'text-slate-400'}>{sub.isActive ? 'Aktif' : 'Pasif'}</span>
                                </div>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    )}
                  </div>
                );
              })
            )}
          </div>
          <div className="p-3 border-t border-slate-100 bg-slate-50 text-[11px] font-bold text-slate-500 text-center uppercase tracking-widest">
            {mainGroups.length} Ana Grup • {groups.length - mainGroups.length} Alt Grup
          </div>
        </div>

        {/* Right Pane: Details */}
        <div className="flex-1 bg-white border border-slate-200 rounded-2xl shadow-sm flex flex-col min-w-0 overflow-hidden">
          {!selectedGroupId ? (
            <div className="flex-1 flex flex-col items-center justify-center text-slate-400 p-8">
              <Layers className="w-16 h-16 mb-4 opacity-20" />
              <h3 className="text-lg font-bold text-slate-600">Grup Seçilmedi</h3>
              <p className="text-sm">Detayları görmek için sol menüden bir grup seçin.</p>
            </div>
          ) : detailsLoading || !groupDetails ? (
            <div className="flex-1 flex items-center justify-center p-8">
              <RefreshCw className="w-8 h-8 animate-spin text-blue-500" />
            </div>
          ) : (
            <>
              {/* Header */}
              <div className="p-6 border-b border-slate-100 relative bg-slate-50/50">
                <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
                  <div className="flex items-start gap-4">
                    <div className="w-14 h-14 bg-blue-600 text-white rounded-2xl shadow-lg shadow-blue-600/20 flex items-center justify-center shrink-0">
                      <Users className="w-6 h-6" />
                    </div>
                    <div>
                      <div className="flex items-center gap-3 mb-1">
                        <h2 className="text-2xl font-black text-slate-900 tracking-tight">{groupDetails.name}</h2>
                        {!groupDetails.isActive && (
                          <span className="px-2.5 py-1 bg-slate-100 text-slate-600 text-[10px] font-bold uppercase tracking-widest rounded-md border border-slate-200">
                            Offline / Pasif
                          </span>
                        )}
                        {groupDetails.expireAt && new Date(groupDetails.expireAt) < new Date() && (
                          <span className="px-2.5 py-1 bg-rose-50 text-rose-600 text-[10px] font-bold uppercase tracking-widest rounded-md border border-rose-200">
                            Süresi Doldu
                          </span>
                        )}
                      </div>
                      <p className="text-sm text-slate-500 font-medium mb-3">{groupDetails.description || "Açıklama yok"}</p>
                      <div className="flex items-center gap-4 text-xs font-bold text-slate-600">
                        <span className="flex items-center gap-1.5"><Users className="w-4 h-4 text-slate-400"/> {groupDetails.users?.length || 0} Üye</span>
                        <span className="flex items-center gap-1.5"><BookOpen className="w-4 h-4 text-slate-400"/> {(groupDetails.exams?.length || 0) + (groupDetails.packages?.length || 0)} Sınav</span>
                        {groupDetails.expireAt && (
                          <span className="flex items-center gap-1.5"><Calendar className="w-4 h-4 text-slate-400"/> Son: {dayjs(groupDetails.expireAt).format('DD MMM YYYY')}</span>
                        )}
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-2">
                    <button onClick={() => { navigator.clipboard.writeText(groupDetails.id); alert("Grup ID kopyalandı!"); }} className="p-2 text-slate-400 hover:text-slate-700 bg-white hover:bg-slate-100 rounded-lg border border-slate-200 shadow-sm transition-colors" title="ID Kopyala">
                      <Copy className="w-4 h-4" />
                    </button>
                    {!groupDetails.parentId && (
                      <button onClick={() => { setCreatingSubgroupFor(groupDetails.id); setShowCreateModal(true); }} className="px-3 py-2 text-xs font-bold text-blue-600 hover:text-blue-700 bg-blue-50 hover:bg-blue-100 rounded-lg transition-colors border border-blue-200 shadow-sm">
                        + Alt Grup
                      </button>
                    )}
                  </div>
                </div>

                {/* Tabs */}
                <div className="flex items-center gap-6 mt-8 border-b border-slate-200">
                  <button onClick={() => setActiveTab("members")} className={`pb-3 text-sm font-bold transition-all relative ${activeTab === 'members' ? 'text-blue-600' : 'text-slate-500 hover:text-slate-700'}`}>
                    <div className="flex items-center gap-2">
                      <Users className="w-4 h-4" /> Üyeler
                    </div>
                    {activeTab === 'members' && <div className="absolute bottom-[-1px] left-0 right-0 h-0.5 bg-blue-600 rounded-t-full"></div>}
                  </button>
                  <button onClick={() => setActiveTab("exams")} className={`pb-3 text-sm font-bold transition-all relative ${activeTab === 'exams' ? 'text-blue-600' : 'text-slate-500 hover:text-slate-700'}`}>
                    <div className="flex items-center gap-2">
                      <BookOpen className="w-4 h-4" /> Sınavlar
                    </div>
                    {activeTab === 'exams' && <div className="absolute bottom-[-1px] left-0 right-0 h-0.5 bg-blue-600 rounded-t-full"></div>}
                  </button>
                  <button onClick={() => setActiveTab("settings")} className={`pb-3 text-sm font-bold transition-all relative ${activeTab === 'settings' ? 'text-blue-600' : 'text-slate-500 hover:text-slate-700'}`}>
                    <div className="flex items-center gap-2">
                      <Settings className="w-4 h-4" /> Ayarlar
                    </div>
                    {activeTab === 'settings' && <div className="absolute bottom-[-1px] left-0 right-0 h-0.5 bg-blue-600 rounded-t-full"></div>}
                  </button>
                </div>
              </div>

              {/* Tab Contents */}
              <div className="flex-1 p-6 overflow-y-auto bg-slate-50/30">
                
                {/* MEMBERS TAB */}
                {activeTab === "members" && (
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        {selectedUsers.length > 0 && (
                          <div className="flex items-center gap-2 animate-in fade-in slide-in-from-left-4">
                            <span className="text-sm font-bold text-slate-600">{selectedUsers.length} seçili</span>
                            <div className="w-px h-4 bg-slate-300"></div>
                            <button onClick={() => setShowTransferModal(true)} className="text-xs font-bold text-blue-600 hover:text-blue-700 bg-blue-50 px-3 py-1.5 rounded-lg border border-blue-200 shadow-sm transition-colors">
                              Aktar
                            </button>
                            <button onClick={handleBulkRemoveUsers} className="text-xs font-bold text-rose-600 hover:text-rose-700 bg-rose-50 px-3 py-1.5 rounded-lg border border-rose-200 shadow-sm transition-colors">
                              Çıkar
                            </button>
                          </div>
                        )}
                      </div>
                      <Link href="/muro-admin/ogrenciler" className="flex items-center gap-2 px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg transition-colors font-bold shadow-md text-xs">
                        <Users className="w-4 h-4" /> Üye Yönetimine Git
                      </Link>
                    </div>

                    <div className="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                      <table className="w-full text-sm text-left">
                        <thead className="bg-slate-50 border-b border-slate-100 text-[10px] font-bold text-slate-500 uppercase tracking-widest">
                          <tr>
                            <th className="px-4 py-3 w-10">
                              <input 
                                type="checkbox" 
                                className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                                checked={selectedUsers.length === groupDetails.users?.length && groupDetails.users?.length > 0}
                                onChange={(e) => {
                                  if (e.target.checked) setSelectedUsers(groupDetails.users.map((u:any) => u.id));
                                  else setSelectedUsers([]);
                                }}
                              />
                            </th>
                            <th className="px-4 py-3">Öğrenci Bilgisi</th>
                            <th className="px-4 py-3">Kayıt Tarihi</th>
                            <th className="px-4 py-3">Rol</th>
                          </tr>
                        </thead>
                        <tbody>
                          {groupDetails.users?.length === 0 ? (
                            <tr>
                              <td colSpan={4} className="px-4 py-8 text-center text-slate-500 text-sm">Bu grupta henüz üye bulunmuyor.</td>
                            </tr>
                          ) : (
                            groupDetails.users?.map((u:any) => (
                              <tr key={u.id} className="border-b border-slate-50 hover:bg-slate-50/50">
                                <td className="px-4 py-3">
                                  <input 
                                    type="checkbox" 
                                    className="w-4 h-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                                    checked={selectedUsers.includes(u.id)}
                                    onChange={(e) => {
                                      if (e.target.checked) setSelectedUsers([...selectedUsers, u.id]);
                                      else setSelectedUsers(selectedUsers.filter(id => id !== u.id));
                                    }}
                                  />
                                </td>
                                <td className="px-4 py-3">
                                  <div className="flex items-center gap-3">
                                    <div className="w-8 h-8 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs shrink-0">
                                      {u.name ? u.name.charAt(0).toUpperCase() : "U"}
                                    </div>
                                    <div className="flex flex-col">
                                      <Link href={`/muro-admin/ogrenciler/${u.id}`} className="font-bold text-slate-800 hover:text-blue-600 transition-colors">
                                        {u.name || "İsimsiz"}
                                      </Link>
                                      <span className="text-[11px] text-slate-500 font-medium">{u.email}</span>
                                    </div>
                                  </div>
                                </td>
                                <td className="px-4 py-3">
                                  <span className="text-xs text-slate-500 font-medium flex items-center gap-1.5">
                                    <Calendar className="w-3.5 h-3.5" />
                                    {dayjs(u.createdAt).format('DD MMM YYYY')}
                                  </span>
                                </td>
                                <td className="px-4 py-3">
                                  <span className="px-2 py-1 rounded-md bg-slate-100 border border-slate-200 text-[10px] font-bold text-slate-600 uppercase">
                                    {u.role === 'STUDENT' ? 'Öğrenci' : u.role}
                                  </span>
                                </td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}

                {/* EXAMS TAB */}
                {activeTab === "exams" && (
                  <div className="space-y-4">
                    <div className="flex items-center justify-between mb-4">
                      <h3 className="font-bold text-slate-800">Atanmış Sınavlar</h3>
                      <Link href="/muro-admin/sinavlar" className="text-xs font-bold text-blue-600 hover:text-blue-700 bg-blue-50 px-3 py-1.5 rounded-lg border border-blue-200 shadow-sm transition-colors">
                        Sınav Yönetimi
                      </Link>
                    </div>
                    {(groupDetails.exams?.length || 0) + (groupDetails.packages?.length || 0) === 0 ? (
                      <div className="p-8 text-center text-slate-500 border border-slate-200 border-dashed rounded-xl bg-white text-sm">
                        Bu gruba atanmış herhangi bir sınav bulunamadı.
                      </div>
                    ) : (
                      <div className="grid grid-cols-1 gap-3">
                        {groupDetails.packages?.map((pkg:any) => (
                          <div key={pkg.id} className="p-4 bg-amber-50 border border-amber-200 rounded-xl shadow-sm flex items-center gap-4 group">
                            <div className="w-10 h-10 rounded-xl bg-amber-100 text-amber-600 flex items-center justify-center shrink-0 group-hover:bg-amber-500 group-hover:text-white transition-colors">
                              <Layers className="w-5 h-5" />
                            </div>
                            <div className="flex-1">
                              <h4 className="font-bold text-slate-800 flex items-center gap-2">
                                {pkg.title}
                                <span className="px-2 py-0.5 bg-amber-200 text-amber-800 text-[10px] rounded-md font-bold">Oturumlu Sınav</span>
                              </h4>
                              <p className="text-xs text-slate-500 font-medium">{pkg.exams?.length || 0} Oturum</p>
                            </div>
                            <Link href="/muro-admin/sinavlar" className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                              <ChevronRight className="w-5 h-5" />
                            </Link>
                          </div>
                        ))}
                        {groupDetails.exams?.map((exam:any) => (
                          <div key={exam.id} className="p-4 bg-white border border-slate-200 rounded-xl shadow-sm flex items-center gap-4 group">
                            <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center shrink-0 group-hover:bg-purple-600 group-hover:text-white transition-colors">
                              <BookOpen className="w-5 h-5" />
                            </div>
                            <div className="flex-1">
                              <h4 className="font-bold text-slate-800">{exam.title}</h4>
                              <p className="text-xs text-slate-500 font-medium">{exam.questionCount} Soru • {exam.durationMinutes} Dakika</p>
                            </div>
                            <Link href={`/muro-admin/sinavlar/${exam.id}`} className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                              <ChevronRight className="w-5 h-5" />
                            </Link>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}

                {/* SETTINGS TAB */}
                {activeTab === "settings" && (
                  <div className="max-w-2xl space-y-8">
                    <form onSubmit={handleUpdateGroup} className="space-y-6 bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
                      <h3 className="font-bold text-lg text-slate-800 mb-4 flex items-center gap-2"><Edit2 className="w-5 h-5"/> Genel Bilgiler</h3>
                      
                      <div className="grid grid-cols-1 gap-5">
                        <div>
                          <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Grup Adı</label>
                          <input name="name" required defaultValue={groupDetails.name} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm font-bold text-slate-900 focus:border-blue-500 focus:bg-white outline-none transition-colors" />
                        </div>
                        <div>
                          <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Açıklama</label>
                          <textarea name="description" defaultValue={groupDetails.description || ""} rows={3} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm font-bold text-slate-900 focus:border-blue-500 focus:bg-white outline-none transition-colors" />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Ücret (₺)</label>
                            <input name="price" type="number" step="0.01" defaultValue={groupDetails.price} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm font-bold text-slate-900 focus:border-blue-500 focus:bg-white outline-none transition-colors" />
                          </div>
                          <div>
                            <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">Son Kullanım (Opsiyonel)</label>
                            <input name="expireAt" type="date" defaultValue={groupDetails.expireAt ? dayjs(groupDetails.expireAt).format('YYYY-MM-DD') : ""} className="w-full bg-slate-50 border border-slate-200 rounded-xl p-3 text-sm font-bold text-slate-900 focus:border-blue-500 focus:bg-white outline-none transition-colors" />
                          </div>
                        </div>
                      </div>

                      <div className="pt-2 flex justify-end">
                        <button type="submit" className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold rounded-xl shadow-md transition-colors shadow-blue-600/20">
                          Değişiklikleri Kaydet
                        </button>
                      </div>
                    </form>

                    <div className="bg-rose-50 p-6 rounded-2xl border border-rose-200 space-y-4">
                      <h3 className="font-bold text-lg text-rose-700 flex items-center gap-2"><AlertTriangle className="w-5 h-5"/> Tehlikeli İşlemler</h3>
                      <div className="flex flex-col gap-3">
                        <div className="flex items-center justify-between p-4 bg-white rounded-xl border border-rose-100">
                          <div>
                            <h4 className="font-bold text-slate-800 text-sm">Grubu Pasife Al</h4>
                            <p className="text-xs text-slate-500">Öğrenciler grubu göremez, sınavlara giremez.</p>
                          </div>
                          <button onClick={handleToggleStatus} className="px-4 py-2 text-xs font-bold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-lg transition-colors border border-slate-200">
                            {groupDetails.isActive ? "Pasife Al" : "Aktife Al"}
                          </button>
                        </div>
                        <div className="flex items-center justify-between p-4 bg-white rounded-xl border border-rose-100">
                          <div>
                            <h4 className="font-bold text-rose-600 text-sm">Grubu Tamamen Sil</h4>
                            <p className="text-xs text-rose-500/80">Bu işlem geri alınamaz. Alt gruplar etkilenebilir.</p>
                          </div>
                          <button onClick={handleDeleteGroup} className="px-4 py-2 text-xs font-bold text-white bg-rose-600 hover:bg-rose-700 rounded-lg transition-colors shadow-md shadow-rose-600/20">
                            Kalıcı Olarak Sil
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </>
          )}
        </div>
      </div>

      {/* CREATE MODAL */}
      {showCreateModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl p-8 relative animate-in zoom-in-95">
            <button onClick={() => { setShowCreateModal(false); setCreatingSubgroupFor(null); }} className="absolute top-6 right-6 text-slate-400 hover:bg-slate-100 p-2 rounded-full"><X className="w-5 h-5"/></button>
            <h2 className="text-2xl font-bold mb-1">{creatingSubgroupFor ? "Alt Grup Oluştur" : "Yeni Ana Grup"}</h2>
            <p className="text-sm text-slate-500 mb-6">Öğrencilerinizi gruplamak için yeni bir kategori.</p>

            <form onSubmit={handleCreateGroup} className="space-y-4">
              <div>
                <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-1.5">Grup Adı</label>
                <input name="name" required className="w-full border border-slate-200 rounded-xl p-3 font-bold text-sm outline-none focus:border-blue-500" placeholder="Örn: 2026 KPSS Kampı" />
              </div>
              <div>
                <label className="block text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-1.5">Açıklama (Opsiyonel)</label>
                <textarea name="description" rows={2} className="w-full border border-slate-200 rounded-xl p-3 font-bold text-sm outline-none focus:border-blue-500"></textarea>
              </div>
              <button type="submit" className="w-full bg-blue-600 text-white font-bold py-3 rounded-xl hover:bg-blue-700 transition-colors mt-2">Oluştur</button>
            </form>
          </div>
        </div>
      )}

      {/* TRANSFER MODAL */}
      {showTransferModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-md shadow-2xl p-8 relative animate-in zoom-in-95">
            <button onClick={() => setShowTransferModal(false)} className="absolute top-6 right-6 text-slate-400 hover:bg-slate-100 p-2 rounded-full"><X className="w-5 h-5"/></button>
            <h2 className="text-xl font-bold mb-1">Üyeleri Aktar</h2>
            <p className="text-sm text-slate-500 mb-6">Seçili {selectedUsers.length} üyeyi hangi gruba aktarmak istiyorsunuz?</p>

            <form onSubmit={executeTransfer} className="space-y-4">
              <div>
                <select name="targetGroupId" required className="w-full border border-slate-200 rounded-xl p-3 font-bold text-sm outline-none focus:border-blue-500 text-slate-700">
                  <option value="">-- Hedef Grubu Seçin --</option>
                  {groups.filter(g => g.id !== groupDetails?.id).map(g => (
                    <option key={g.id} value={g.id}>{g.name}</option>
                  ))}
                </select>
              </div>
              <button type="submit" className="w-full bg-blue-600 text-white font-bold py-3 rounded-xl hover:bg-blue-700 transition-colors">Aktarımı Başlat</button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
