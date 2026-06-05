"use client";

import { Radar, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, ResponsiveContainer, Tooltip } from 'recharts';

export default function StudentSpiderChart({ data }: { data: any[] }) {
  // data format: [{ subject: "Matematik", A: 80, fullMark: 100 }, ...]
  
  if (!data || data.length === 0) return null;

  return (
    <div className="w-full h-80 bg-white border border-slate-200 rounded-3xl shadow-sm p-4 relative overflow-hidden">
        <h3 className="text-sm font-bold text-slate-800 absolute top-4 left-5 z-10 w-full flex items-center gap-2">
           Yetenek Ağınız (Kazanım Radarı)
        </h3>
        <ResponsiveContainer width="100%" height="100%">
            <RadarChart cx="50%" cy="55%" outerRadius="70%" data={data}>
                <PolarGrid stroke="#e2e8f0" />
                <PolarAngleAxis dataKey="subject" tick={{ fill: '#64748b', fontSize: 11, fontWeight: 'bold' }} />
                <PolarRadiusAxis angle={30} domain={[0, 100]} tick={{ fill: '#94a3b8', fontSize: 10 }} />
                <Tooltip 
                    contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 15px rgba(0,0,0,0.05)' }}
                    itemStyle={{ color: '#3b82f6', fontWeight: 'bold' }}
                    formatter={(value: any) => [`%${value} Başarı`, '']}
                />
                <Radar name="Başarı" dataKey="A" stroke="#3b82f6" strokeWidth={3} fill="#60a5fa" fillOpacity={0.3} />
            </RadarChart>
        </ResponsiveContainer>
    </div>
  );
}
