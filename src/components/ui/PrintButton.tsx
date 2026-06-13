"use client";

import { Download } from "lucide-react";

export default function PrintButton() {
  return (
    <button 
      onClick={() => window.print()} 
      className="flex items-center gap-2 px-5 py-2.5 bg-indigo-50 hover:bg-indigo-100 border border-indigo-200 text-indigo-700 rounded-xl font-bold transition-colors shadow-sm text-sm print:hidden"
    >
      <Download className="w-4 h-4" /> PDF İndir / Yazdır
    </button>
  );
}
