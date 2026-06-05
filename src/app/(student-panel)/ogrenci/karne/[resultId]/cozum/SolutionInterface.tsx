"use client";

import { useState } from "react";
import { Document, Page, pdfjs } from "react-pdf";
import "react-pdf/dist/Page/AnnotationLayer.css";
import "react-pdf/dist/Page/TextLayer.css";
import { ChevronLeft, ChevronRight, Maximize, Minimize, FileText, ListChecks, ZoomIn, ZoomOut, CheckCircle2, XCircle, Home } from "lucide-react";
import { useRouter } from "next/navigation";
import Link from "next/link";

pdfjs.GlobalWorkerOptions.workerSrc = new URL(
  "pdfjs-dist/build/pdf.worker.min.mjs",
  import.meta.url
).toString();

interface SolutionInterfaceProps {
  exam: any;
  initialAnswers: Record<number, string>;
}

export default function SolutionInterface({ exam, initialAnswers }: SolutionInterfaceProps) {
  const router = useRouter();
  
  const [numPages, setNumPages] = useState<number | null>(null);
  const [pageNumber, setPageNumber] = useState(1);
  const [scale, setScale] = useState(1.2);
  const [pdfError, setPdfError] = useState<string | null>(null);
  const [activeSectionId, setActiveSectionId] = useState<string | null>(null);
  const [mobileTab, setMobileTab] = useState<'pdf' | 'optik'>('pdf');

  const parsedSections = (() => {
    if (!exam.sections) return [];
    const raw = typeof exam.sections === 'string' ? JSON.parse(exam.sections) : exam.sections;
    let currentQ = 0;
    return raw.map((s: any) => {
      const count = typeof s.count === 'string' ? parseInt(s.count) || 0 : s.count || 0;
      const startQ = currentQ + 1;
      const endQ = currentQ + count;
      currentQ += count;
      return { id: s.id, title: s.title, count, startQ, endQ };
    });
  })();

  const answerKeysMap = new Map();
  if (exam.keys) {
    exam.keys.forEach((k: any) => {
      answerKeysMap.set(k.questionNumber, k.correctOption);
    });
  }

  function onDocumentLoadSuccess({ numPages }: { numPages: number }) {
    setNumPages(numPages);
  }

  function onDocumentLoadError(error: Error) {
    setPdfError(`PDF Yüklenemedi: ${error.message}`);
  }

  return (
    <div className="flex flex-col lg:flex-row h-screen bg-slate-50 font-sans overflow-hidden select-none text-slate-800">
      
      {/* Mobile Tab Bar */}
      <div className="lg:hidden h-12 bg-white border-b border-slate-200 flex items-center shrink-0 z-30">
        <button 
          onClick={() => setMobileTab('pdf')}
          className={`flex-1 h-full flex items-center justify-center gap-2 text-sm font-bold transition-colors ${mobileTab === 'pdf' ? 'text-emerald-600 border-b-2 border-emerald-600 bg-emerald-50/50' : 'text-slate-500'}`}
        >
          <FileText className="w-4 h-4" /> Çözüm Kitapçığı
        </button>
        <button 
          onClick={() => setMobileTab('optik')}
          className={`flex-1 h-full flex items-center justify-center gap-2 text-sm font-bold transition-colors ${mobileTab === 'optik' ? 'text-emerald-600 border-b-2 border-emerald-600 bg-emerald-50/50' : 'text-slate-500'}`}
        >
          <ListChecks className="w-4 h-4" /> Benim Optiğim
        </button>
      </div>

      {/* SOL PANEL: PDF GÖRÜNÜMÜ */}
      <div className={`flex-1 flex flex-col border-r border-slate-200 bg-white relative ${mobileTab === 'optik' ? 'hidden lg:flex' : 'flex'}`}>
        <div className="h-14 border-b border-slate-200 bg-white flex items-center justify-between px-3 md:px-6 shrink-0 z-10 shadow-sm">
          <div className="flex items-center gap-4">
            <Link href={`/ogrenci/karne/${exam.results?.[0]?.id || ''}`} onClick={(e) => { e.preventDefault(); router.back(); }} className="flex items-center gap-2 text-slate-500 hover:text-slate-800 transition-colors font-bold text-sm bg-slate-100 px-3 py-1.5 rounded-lg">
              <ChevronLeft className="w-4 h-4" /> Karneme Dön
            </Link>
            <span className="font-bold text-slate-700 tracking-widest uppercase text-[10px] md:text-xs truncate max-w-[150px] md:max-w-none hidden md:inline-block">
              {exam.title} - ÇÖZÜM KİTAPÇIĞI
            </span>
          </div>
          <div className="flex items-center gap-3">
            <button onClick={() => setScale(s => Math.max(0.5, s - 0.2))} className="p-2 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-emerald-600 transition-colors" title="Uzaklaştır">
              <Minimize className="w-4 h-4" />
            </button>
            <span className="text-xs font-mono font-bold text-slate-600 w-12 text-center">{Math.round(scale * 100)}%</span>
            <button onClick={() => setScale(s => Math.min(3, s + 0.2))} className="p-2 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-emerald-600 transition-colors" title="Yakınlaştır">
              <Maximize className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-auto custom-scrollbar p-4 md:p-8 bg-slate-100 relative max-h-[calc(100vh-100px)]">
          {pdfError ? (
             <div className="text-red-500 flex flex-col items-center justify-center h-full max-w-md mx-auto text-center">
               <FileText className="w-12 h-12 mb-4 opacity-50" />
               <p className="font-medium">{pdfError}</p>
             </div>
          ) : (
            <>
              <div className="sticky top-0 z-40 mb-4 flex justify-end">
               <div className="bg-white/90 backdrop-blur-sm shadow-sm border border-slate-200/60 rounded-xl px-2 py-1.5 inline-flex items-center gap-1">
                 <button onClick={() => setScale(s => Math.max(0.5, s - 0.1))} className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-500 transition-colors tooltip" title="Uzaklaştır"><ZoomOut className="w-4 h-4" /></button>
                 <span className="text-xs font-bold w-12 text-center text-slate-700 select-none">{Math.round(scale * 100)}%</span>
                 <button onClick={() => setScale(s => Math.min(3.0, s + 0.1))} className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-500 transition-colors tooltip" title="Yakınlaştır"><ZoomIn className="w-4 h-4" /></button>
                 <div className="w-px h-4 bg-slate-200 mx-1"></div>
                 <button onClick={() => setScale(1.2)} className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-500 transition-colors tooltip" title="Sıfırla"><Maximize className="w-4 h-4" /></button>
               </div>
              </div>
              
              <Document
                file={exam.solutionPdfUrl}
                onLoadSuccess={onDocumentLoadSuccess}
                onLoadError={onDocumentLoadError}
                loading={<div className="animate-pulse text-emerald-600 font-bold text-center mt-20">Çözüm Kitapçığı Yükleniyor...</div>}
                className="pdf-document drop-shadow-md mx-auto w-fit"
              >
                <Page 
                  pageNumber={pageNumber} 
                  scale={scale} 
                  renderTextLayer={false} 
                  renderAnnotationLayer={false}
                  className="pdf-page bg-white"
                />
              </Document>
            </>
          )}
        </div>

        {/* PDF Footer */}
        <div className="h-14 md:h-16 border-t border-slate-200 bg-white flex items-center justify-center gap-3 md:gap-6 shrink-0 shadow-[0_-5px_15px_rgba(0,0,0,0.02)] z-20 px-2">
          <button 
            disabled={pageNumber <= 1} 
            onClick={() => setPageNumber(prev => prev - 1)}
            className="flex items-center gap-1 md:gap-2 px-2 md:px-4 py-2 bg-white border border-slate-200 hover:bg-slate-50 disabled:opacity-30 disabled:pointer-events-none text-slate-700 rounded-xl font-bold transition-all shadow-sm text-xs md:text-sm"
          >
            <ChevronLeft className="w-4 h-4 md:w-5 md:h-5" /> <span className="hidden sm:inline">Önceki Sayfa</span><span className="sm:hidden">Önceki</span>
          </button>
          
          <span className="font-mono text-slate-500 bg-slate-50 px-3 md:px-4 py-2 rounded-xl border border-slate-100 text-xs md:text-sm">
            <span className="text-slate-800 font-bold">{pageNumber}</span> / {numPages || "?"}
          </span>
          
          <button 
            disabled={numPages === null || pageNumber >= numPages} 
            onClick={() => setPageNumber(prev => prev + 1)}
            className="flex items-center gap-1 md:gap-2 px-2 md:px-4 py-2 bg-white border border-slate-200 hover:bg-slate-50 disabled:opacity-30 disabled:pointer-events-none text-slate-700 rounded-xl font-bold transition-all shadow-sm text-xs md:text-sm"
          >
            <span className="hidden sm:inline">Sonraki Sayfa</span><span className="sm:hidden">Sonraki</span> <ChevronRight className="w-4 h-4 md:w-5 md:h-5" />
          </button>
        </div>
      </div>

      {/* SAĞ PANEL: OPTİK FORM SONUÇLARI */}
      <div className={`w-full lg:w-[450px] bg-slate-50 flex flex-col shrink-0 shadow-[-5px_0_15px_rgba(0,0,0,0.03)] z-20 ${mobileTab === 'pdf' ? 'hidden lg:flex' : 'flex'}`}>
        <div className="h-16 md:h-20 border-b border-slate-200 flex items-center justify-between px-4 md:px-6 shrink-0 bg-white shadow-sm z-10">
          <div>
            <h2 className="font-bold text-slate-800 flex items-center gap-2">
              <CheckCircle2 className="w-5 h-5 text-emerald-500" /> Optik Kontrol
            </h2>
            <p className="text-xs text-slate-500 mt-0.5">Yanıtlarınız ve doğru cevaplar</p>
          </div>
        </div>

        {parsedSections.length > 1 && (
          <div className="border-b border-slate-200 bg-white px-4 py-3 shrink-0">
            <select
              value={activeSectionId || "__ALL__"}
              onChange={(e) => setActiveSectionId(e.target.value === "__ALL__" ? null : e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm font-bold text-slate-700 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-200 transition-all appearance-none cursor-pointer"
              style={{ backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M8 11L3 6h10l-5 5z'/%3E%3C/svg%3E")`, backgroundRepeat: 'no-repeat', backgroundPosition: 'right 12px center' }}
            >
              <option value="__ALL__">📋 Tüm Bölümler</option>
              {parsedSections.map((sec: any) => (
                <option key={sec.id} value={sec.id}>{sec.title}</option>
              ))}
            </select>
          </div>
        )}

        <div className="flex-1 overflow-y-auto px-3 md:px-6 py-4 md:py-6 custom-scrollbar scroll-smooth">
          <div className="flex flex-col gap-3">
            {(() => {
              if (activeSectionId && activeSectionId !== "__ALL__" && parsedSections.length > 0) {
                const sec = parsedSections.find((s: any) => s.id === activeSectionId);
                if (!sec) return null;
                return (
                  <div className="flex flex-col gap-3">
                    {Array.from({ length: sec.endQ - sec.startQ + 1 }).map((_, i) => {
                      const qNum = sec.startQ + i;
                      return <QuestionRow key={qNum} qNum={qNum} initialAnswers={initialAnswers} answerKeysMap={answerKeysMap} />;
                    })}
                  </div>
                );
              } else if (parsedSections.length > 0) {
                return parsedSections.map((sec: any) => (
                  <div key={sec.id} className="mb-6 last:mb-0">
                    <div className="bg-slate-100 border border-slate-200 text-slate-500 font-black text-[10px] uppercase tracking-widest px-3 py-1.5 rounded-lg mb-3 inline-flex items-center gap-2">
                      <ListChecks className="w-3.5 h-3.5" /> {sec.title}
                    </div>
                    <div className="flex flex-col gap-3">
                      {Array.from({ length: sec.endQ - sec.startQ + 1 }).map((_, i) => {
                        const qNum = sec.startQ + i;
                        return <QuestionRow key={qNum} qNum={qNum} initialAnswers={initialAnswers} answerKeysMap={answerKeysMap} />;
                      })}
                    </div>
                  </div>
                ));
              } else {
                return Array.from({ length: exam.questionCount }).map((_, i) => {
                  const qNum = 1 + i;
                  return <QuestionRow key={qNum} qNum={qNum} initialAnswers={initialAnswers} answerKeysMap={answerKeysMap} />;
                });
              }
            })()}
          </div>
        </div>

      </div>
    </div>
  );
}

function QuestionRow({ qNum, initialAnswers, answerKeysMap }: { qNum: number, initialAnswers: Record<number, string>, answerKeysMap: Map<number, string> }) {
  const selected = initialAnswers[qNum];
  const correct = answerKeysMap.get(qNum);
  
  const isIptal = correct === "IPTAL";
  const isEmpty = !selected || selected === "BOŞ";
  const isCorrect = !isIptal && !isEmpty && selected === correct;
  const isWrong = !isIptal && !isEmpty && selected !== correct;

  return (
    <div className={`flex items-center p-2 md:p-3 rounded-xl border shadow-sm transition-colors ${
      isIptal ? 'bg-slate-50 border-slate-200 opacity-60' :
      isCorrect ? 'bg-emerald-50 border-emerald-200' :
      isWrong ? 'bg-rose-50 border-rose-200' :
      'bg-white border-slate-200'
    }`}>
      <span className="font-mono font-black text-base md:text-lg text-slate-400 w-8 md:w-10 text-right pr-2 md:pr-4 border-r border-slate-200 shrink-0">
        {qNum}.
      </span>
      <div className="flex items-center gap-1.5 md:gap-2 pl-2 md:pl-4 flex-1">
        {["A", "B", "C", "D", "E"].map(opt => {
          let stateClass = "bg-white border-slate-200 text-slate-300 opacity-50";
          
          if (isIptal) {
             stateClass = "bg-slate-100 border-slate-200 text-slate-400 opacity-50";
          } else {
             if (opt === correct && opt === selected) {
                stateClass = "bg-emerald-500 border-emerald-500 text-white shadow-md scale-110 z-10 ring-2 ring-emerald-200 ring-offset-1";
             } else if (opt === correct && opt !== selected) {
                stateClass = "bg-white border-emerald-500 text-emerald-600 border-2 shadow-sm scale-105";
             } else if (opt === selected && opt !== correct) {
                stateClass = "bg-rose-500 border-rose-500 text-white shadow-md scale-110 z-10 line-through decoration-white/50";
             } else {
                stateClass = "bg-white border-slate-200 text-slate-300";
             }
          }

          return (
            <div
              key={opt}
              className={`w-7 h-7 md:w-8 md:h-8 rounded-full border-2 text-xs font-black flex items-center justify-center transition-all duration-150 ${stateClass}`}
            >
              {opt}
            </div>
          );
        })}
        
        <div className="ml-auto shrink-0 flex items-center">
           {isIptal ? (
             <span className="px-2 py-1 bg-slate-200 text-slate-500 text-[9px] font-bold rounded uppercase tracking-widest">İptal Edildi</span>
           ) : isCorrect ? (
             <CheckCircle2 className="w-5 h-5 text-emerald-500" />
           ) : isWrong ? (
             <XCircle className="w-5 h-5 text-rose-500" />
           ) : (
             <span className="px-2 py-1 bg-slate-100 text-slate-400 text-[9px] font-bold rounded uppercase tracking-widest border border-slate-200">Boş</span>
           )}
        </div>
      </div>
    </div>
  );
}
