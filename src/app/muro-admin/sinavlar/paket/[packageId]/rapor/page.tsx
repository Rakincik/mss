import { prisma } from "@/lib/prisma";
import { getCurrentUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Users, Calculator, BarChart, Target, Trophy } from "lucide-react";

export default async function PaketRaporPage({ params }: { params: Promise<{ packageId: string }> }) {
  const user = await getCurrentUser();
  if (!user || user.role === "STUDENT") redirect("/login");
  const resolvedParams = await params;
  const packageId = resolvedParams.packageId;

  const pkg = await prisma.examPackage.findUnique({
    where: { id: packageId },
    include: {
      results: {
        include: { user: true },
        where: { isComputed: true }
      },
      exams: true
    }
  });

  if (!pkg) {
    return <div className="p-10 text-center">Paket bulunamadı.</div>;
  }

  // Ortalamaları Hesapla
  let averages: Record<string, number> = {};
  let scoreCounts: Record<string, number> = {};

  pkg.results.forEach(res => {
    const s = (res.scores as Record<string, number>) || {};
    Object.keys(s).forEach(key => {
      if (key !== "total") {
        averages[key] = (averages[key] || 0) + s[key];
        scoreCounts[key] = (scoreCounts[key] || 0) + 1;
      }
    });
  });

  Object.keys(averages).forEach(key => {
    averages[key] = averages[key] / scoreCounts[key];
  });

  // Sıralama İçin En Popüler Puan Türünü Bul
  let primaryScoreKey = "KPSS_P3";
  if (averages["KPSS_P121"]) primaryScoreKey = "KPSS_P121";
  else if (averages["KPSS_P10"]) primaryScoreKey = "KPSS_P10";
  else if (averages["KPSS_P93"]) primaryScoreKey = "KPSS_P93";
  else if (averages["KPSS_P48"]) primaryScoreKey = "KPSS_P48";

  // Öğrencileri Sırala
  const sortedStudents = [...pkg.results].sort((a, b) => {
    const aScores = (a.scores as Record<string, number>) || {};
    const bScores = (b.scores as Record<string, number>) || {};
    return (bScores[primaryScoreKey] || 0) - (aScores[primaryScoreKey] || 0);
  });

  return (
    <div className="p-8">
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center gap-4">
          <Link href="/muro-admin/sinavlar" className="w-10 h-10 bg-white border border-slate-200 rounded-full flex items-center justify-center hover:bg-slate-50 transition shadow-sm text-slate-500">
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-black text-slate-800">{pkg.title} - Kurum Raporu</h1>
            <p className="text-sm text-slate-500 mt-1">{pkg.description}</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col items-center justify-center text-center">
          <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-full flex items-center justify-center mb-3">
            <Users className="w-6 h-6" />
          </div>
          <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wider">Hesaplanan Karne</span>
          <span className="text-3xl font-black text-slate-800 mt-1">{pkg.results.length}</span>
        </div>

        {Object.entries(averages).map(([key, val]) => (
          <div key={key} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col items-center justify-center text-center relative overflow-hidden">
            <div className="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-full flex items-center justify-center mb-3 relative z-10">
              <BarChart className="w-6 h-6" />
            </div>
            <span className="text-[10px] uppercase font-bold text-slate-400 tracking-wider relative z-10">Ortalama {key.replace("KPSS_", "P")}</span>
            <span className="text-3xl font-black text-slate-800 mt-1 relative z-10">{val.toFixed(2)}</span>
            <div className="absolute -bottom-4 -right-4 w-24 h-24 bg-slate-50 rounded-full z-0"></div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-lg font-bold flex items-center gap-2 text-slate-800">
            <Trophy className="w-5 h-5 text-amber-500" /> Derece Listesi ({primaryScoreKey.replace("KPSS_", "P")} Bazlı)
          </h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm whitespace-nowrap">
            <thead className="bg-slate-50/50 text-slate-500 font-bold uppercase tracking-wider text-[10px]">
              <tr>
                <th className="px-6 py-4 border-b border-slate-100 text-center w-16">Sıra</th>
                <th className="px-6 py-4 border-b border-slate-100">Öğrenci</th>
                {Object.keys(averages).map(key => (
                  <th key={key} className="px-6 py-4 border-b border-slate-100 text-center text-indigo-600">{key.replace("KPSS_", "P")}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {sortedStudents.map((res, index) => {
                const s = (res.scores as Record<string, number>) || {};
                return (
                  <tr key={res.id} className="hover:bg-slate-50 transition-colors group">
                    <td className="px-6 py-4 text-center font-black text-slate-400 group-hover:text-amber-500 transition-colors">
                      #{index + 1}
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-bold text-slate-800">{res.user.name || "İsimsiz Öğrenci"}</div>
                      <div className="text-xs text-slate-500">{res.user.email}</div>
                    </td>
                    {Object.keys(averages).map(key => (
                      <td key={key} className={`px-6 py-4 text-center font-bold ${key === primaryScoreKey ? 'text-indigo-600 bg-indigo-50/30' : 'text-slate-600'}`}>
                        {s[key] ? s[key].toFixed(3) : "-"}
                      </td>
                    ))}
                  </tr>
                )
              })}
              {sortedStudents.length === 0 && (
                <tr>
                  <td colSpan={10} className="px-6 py-10 text-center text-slate-500">
                    Henüz hesaplanmış bir karne bulunmuyor. Önce paket puanlarını hesaplayın.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
