import { getCurrentUserWithGroups } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import { UserCircle2 } from "lucide-react";
import ProfileForm from "./ProfileForm";

export const dynamic = "force-dynamic";

export default async function StudentProfilePage() {
  const student = await getCurrentUserWithGroups();
  if (!student) {
    redirect("/login");
  }

  return (
    <div className="font-sans text-slate-800 flex flex-col">
      <main className="flex-1 w-full max-w-2xl mx-auto space-y-8">
        <div>
          <h2 className="text-2xl font-bold flex items-center gap-2 text-slate-800">
            <UserCircle2 className="w-6 h-6 text-blue-600" /> Profil Bilgilerim
          </h2>
          <p className="text-slate-500 mt-1 text-sm">Hesap bilgilerinizi görüntüleyebilir ve güncelleyebilirsiniz.</p>
        </div>

        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden shadow-sm">
          {/* Avatar Section */}
          <div className="p-8 border-b border-slate-100 flex items-center gap-6 bg-gradient-to-br from-slate-50 to-blue-50/30 relative overflow-hidden">
             
             <div className="flex-shrink-0 w-24 h-24 rounded-full bg-blue-600 flex items-center justify-center font-black text-4xl text-white shadow-lg shadow-blue-600/20 border-4 border-white z-10">
               {student.name?.charAt(0).toUpperCase() || "Ö"}
             </div>
             
             <div className="z-10">
               <h3 className="text-2xl font-black text-slate-900">{student.name}</h3>
               <span className="inline-block mt-2 px-3 py-1 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-lg text-[10px] font-bold tracking-widest uppercase">
                 Kayıtlı Sınıf: {student.groups?.[0]?.name || "Bilinmiyor"}
               </span>
             </div>
          </div>

          <div className="p-8">
             <ProfileForm student={student} />
          </div>
        </div>
      </main>
    </div>
  );
}
