"use client";

import { Component, ReactNode } from "react";
import { WifiOff, RefreshCw, AlertTriangle } from "lucide-react";

interface Props {
  children: ReactNode;
  fallbackMessage?: string;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

/**
 * Sınav Error Boundary
 * 
 * Sınav arayüzünde beklenmedik bir JavaScript hatası olduğunda
 * tüm sayfa çökmek yerine kullanıcı dostu bir hata ekranı gösterilir.
 * 
 * "Tekrar Dene" butonu ile sayfa yeniden yüklenir.
 * Kritik bir sınav anında beyaz ekran görmek yerine bu ekran görülür.
 */
export class ExamErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error("ExamErrorBoundary caught an error:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex items-center justify-center min-h-screen bg-slate-50 p-6">
          <div className="bg-white border border-slate-200 rounded-3xl p-10 max-w-md w-full shadow-xl text-center">
            <div className="w-20 h-20 bg-amber-50 border-2 border-amber-200 rounded-2xl flex items-center justify-center mx-auto mb-6">
              <AlertTriangle className="w-10 h-10 text-amber-500" />
            </div>
            <h2 className="text-2xl font-black text-slate-800 mb-3">Beklenmedik Bir Hata Oluştu</h2>
            <p className="text-slate-500 text-sm font-medium mb-2">
              {this.props.fallbackMessage || "Sınav arayüzünde bir sorun meydana geldi. Cevaplarınız sunucuda güvenle kayıtlıdır."}
            </p>
            <p className="text-slate-400 text-xs font-mono mb-8 bg-slate-50 p-3 rounded-xl border border-slate-100 break-all">
              {this.state.error?.message || "Bilinmeyen hata"}
            </p>
            <button 
              onClick={() => window.location.reload()}
              className="w-full flex items-center justify-center gap-2 py-3.5 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl shadow-md transition-all"
            >
              <RefreshCw className="w-5 h-5" /> Sayfayı Yenile
            </button>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}
