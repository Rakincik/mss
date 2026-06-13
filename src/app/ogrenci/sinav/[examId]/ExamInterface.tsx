"use client";

import { useState, useEffect, useCallback, useRef, useMemo } from "react";
import { Document, Page, pdfjs } from "react-pdf";
import "react-pdf/dist/Page/AnnotationLayer.css";
import "react-pdf/dist/Page/TextLayer.css";
import { Clock, ShieldAlert, CheckCircle2, ChevronLeft, ChevronRight, Maximize, Minimize, Pen, Highlighter, Eraser, Move, Trash2, FileText, ListChecks, WifiOff, ZoomIn, ZoomOut } from "lucide-react";
import { useRouter } from "next/navigation";
import { ExamTimer } from "./ExamTimer";
import { useToast } from "@/hooks/useToast";
import dynamic from 'next/dynamic';

const DrawingCanvas = dynamic(() => import('./DrawingCanvas').then(mod => mod.DrawingCanvas), { ssr: false });
import { fetchWithRetry, getQueueSize } from "@/lib/fetchWithRetry";

// PDF.js worker setup - Yerel (Next.js Asset Bundle) Çözümü
pdfjs.GlobalWorkerOptions.workerSrc = new URL(
  "pdfjs-dist/build/pdf.worker.min.mjs",
  import.meta.url
).toString();

interface ExamInterfaceProps {
  exam: any;
  resultId: string;
  studentId: string;
  initialAnswers: Record<number, string>;
  initialDrawings?: Record<number, any[]>;
  startedAt?: string;
}

const MAX_DRAWING_SIZE_BYTES = 1_500_000; // 1.5MB client limit (server 2MB)

export default function ExamInterface({ exam, resultId, studentId, initialAnswers, initialDrawings, startedAt }: ExamInterfaceProps) {
  const router = useRouter();
  const { showToast } = useToast();
  
  // PDF States
  const [numPages, setNumPages] = useState<number | null>(null);
  const [pageNumber, setPageNumber] = useState(1);
  const [scale, setScale] = useState(1.2);
  const [pdfError, setPdfError] = useState<string | null>(null);
  
  // Exam States
  const [answers, setAnswers] = useState<Record<number, string>>(initialAnswers);
  const [isFinishing, setIsFinishing] = useState(false);
  const [isOffline, setIsOffline] = useState(false);
  const [drawingLimitReached, setDrawingLimitReached] = useState(false);

  // Add offline listener
  useEffect(() => {
    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    setIsOffline(!navigator.onLine);
    
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);
  const [showConfirmModal, setShowConfirmModal] = useState(false);
  const [securityWarning, setSecurityWarning] = useState<string | null>(null);
  const [activeSectionId, setActiveSectionId] = useState<string | null>(null);

  // Parse sections for optical form tabs (memoized — exam.sections değişmediği sürece yeniden hesaplanmaz)
  const parsedSections = useMemo(() => {
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
  }, [exam.sections]);

  // Drawing Canvas States
  const [pageDimensions, setPageDimensions] = useState({ width: 0, height: 0 });
  const [drawings, setDrawings] = useState<Record<number, any[]>>(initialDrawings || {});
  const [drawingMode, setDrawingMode] = useState<any>("pan");
  const [penColor, setPenColor] = useState<string>("#2563eb");
  const [penThickness, setPenThickness] = useState<number>(2);

  // Refs for stable forceFinishExam (prevents ExamTimer interval resets)
  const isFinishingRef = useRef(false);
  const drawingsRef = useRef(drawings);
  drawingsRef.current = drawings;

  const forceFinishExam = useCallback(async () => {
    if (isFinishingRef.current) return;
    isFinishingRef.current = true;
    setIsFinishing(true);

    // Bekleyen debounce'ları flush et
    const flushPromises: Promise<any>[] = [];
    const keys = Object.keys(dirtyAnswers.current);
    if (keys.length > 0) {
      const payload = keys.map(k => ({
        resultId,
        questionNumber: Number(k),
        selectedOption: dirtyAnswers.current[Number(k)]
      }));
      
      flushPromises.push(
        fetch("/api/student-answer-batch", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ answers: payload })
        }).then(() => {}).catch(() => {})
      );
      dirtyAnswers.current = {};
    }
    if (drawingDebounceTimer.current) {
      clearTimeout(drawingDebounceTimer.current);
    }

    await fetch("/api/finish-exam", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ resultId })
    });
    showToast("Süreniz doldu! Sınavınız otomatik olarak sonlandırıldı.", "info");
    router.push("/ogrenci/dashboard");
    router.refresh();
  }, [resultId, router, showToast]);  // Stable deps — answers/drawings artık ref üzerinden okunuyor

  // Dirty Answers Queue for Batching
  const dirtyAnswers = useRef<Record<number, string>>({});
  const drawingDebounceTimer = useRef<NodeJS.Timeout | null>(null);

  // Interval for batching answers every 10 seconds
  useEffect(() => {
    const STORAGE_KEY = `exam_answers_${exam.id}_${resultId}`;
    
    const interval = setInterval(async () => {
      if (isFinishing) return;
      const keys = Object.keys(dirtyAnswers.current);
      if (keys.length === 0) return;

      const payload = keys.map(k => ({
        resultId,
        questionNumber: Number(k),
        selectedOption: dirtyAnswers.current[Number(k)]
      }));

      try {
        await fetchWithRetry("/api/student-answer-batch", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ answers: payload })
        });
        // Clear dirty queue on success
        keys.forEach(k => delete dirtyAnswers.current[Number(k)]);
      } catch (e) {
        console.error("Batch save failed, will retry on next interval");
      }
    }, 10000);

    return () => clearInterval(interval);
  }, [resultId, exam.id, isFinishing]);

  const saveDrawings = async (newDrawings: Record<number, any[]>) => {
    try {
      const payload = JSON.stringify({ resultId, drawings: newDrawings });
      
      // Client-side boyut kontrolü
      if (payload.length > MAX_DRAWING_SIZE_BYTES) {
        setDrawingLimitReached(true);
        console.warn(`[Drawing] Payload ${(payload.length / 1024).toFixed(0)}KB — limit aşıldı, kayıt atlandı.`);
        return;
      }
      setDrawingLimitReached(false);
      
      await fetchWithRetry("/api/save-drawing", {
         method: "POST",
         headers: { "Content-Type": "application/json" },
         body: payload
      });
    } catch(e) {}
  };

  // Debounced drawing save (3 saniye)
  const debouncedSaveDrawings = (newDrawings: Record<number, any[]>) => {
    if (drawingDebounceTimer.current) clearTimeout(drawingDebounceTimer.current);
    drawingDebounceTimer.current = setTimeout(() => {
      saveDrawings(newDrawings);
    }, 3000);
  };

  const handleStrokesChange = (strokes: any[]) => {
    const newD = { ...drawings, [pageNumber]: strokes };
    // Boyut kontrolü — temizleme (strokes=[]) her zaman izin ver
    if (strokes.length > 0 && drawingLimitReached) return;
    setDrawings(newD);
    debouncedSaveDrawings(newD);
  };

  const handleStrokeAdd = (stroke: any) => {
    if (drawingLimitReached) return; // Limit aşıldıysa yeni çizim ekleme
    const current = drawings[pageNumber] || [];
    const newD = { ...drawings, [pageNumber]: [...current, stroke] };
    setDrawings(newD);
    debouncedSaveDrawings(newD);
  };
  
  // Security Telemetry Logger — Throttled (aynı actionType için 30 saniyede max 1 log)
  const telemetryThrottle = useRef<Record<string, number>>({});
  const logTelemetry = useCallback(async (actionType: string, details?: string) => {
    const now = Date.now();
    const lastLog = telemetryThrottle.current[actionType] || 0;
    if (now - lastLog < 30000) return; // 30 saniye throttle
    telemetryThrottle.current[actionType] = now;

    try {
      await fetchWithRetry("/api/telemetry", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ examId: exam.id, actionType, details })
      });
    } catch (e) {
      console.error("Telemetry failed");
    }
  }, [exam.id]);

  // Telemetry Event Listeners
  useEffect(() => {
    const handleBlur = () => {
      // Eğer zaten bitirme işlemindeyse fırlatma
      if (isFinishing) return;
      logTelemetry("BLUR", `Ekran görüntüsü aracı veya başka sekme algılandı. (Sayfa: ${pageNumber})`);
      setSecurityWarning("Sınav ekranından ayrıldığınız veya ekran görüntüsü aracı kullandığınız tespit edildi!");
    };

    const handleContextMenu = (e: MouseEvent) => {
      e.preventDefault();
      logTelemetry("DEVTOOLS_OPEN", "Sağ tık yapılmaya çalışıldı.");
    };

    const handleKeyDown = (e: KeyboardEvent) => {
      // F12, PrintScreen, Ctrl+C, Ctrl+P gibi tuşları engelle
      if (e.key === "F12" || e.key === "PrintScreen" || 
         (e.ctrlKey && (e.key === "c" || e.key === "C" || e.key === "p" || e.key === "P" || e.key === "s" || e.key === "S"))) {
        e.preventDefault();
        logTelemetry("PRINT_SCREEN", `Zararlı klavye kısayolu kullanımı (${e.key})`);
      }
    };

    window.addEventListener("blur", handleBlur);
    document.addEventListener("contextmenu", handleContextMenu);
    document.addEventListener("keydown", handleKeyDown);

    return () => {
      window.removeEventListener("blur", handleBlur);
      document.removeEventListener("contextmenu", handleContextMenu);
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [logTelemetry, pageNumber, isFinishing]);

  // Answer Selection (Batched & LocalStorage Backup)
  const handleOptionSelect = (questionNum: number, optionValue: string) => {
    // Optimistic UI Update
    setAnswers(prev => ({
      ...prev,
      [questionNum]: optionValue
    }));

    // Add to dirty queue for interval batching
    dirtyAnswers.current[questionNum] = optionValue;
    
    // Backup to local storage to prevent data loss on sudden disconnect
    try {
      const STORAGE_KEY = `exam_answers_${exam.id}_${resultId}`;
      const currentStorage = JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
      currentStorage[questionNum] = optionValue;
      localStorage.setItem(STORAGE_KEY, JSON.stringify(currentStorage));
    } catch (e) {
      console.error("LocalStorage save failed", e);
    }
  };

  const handleFinishExam = async () => {
    setIsFinishing(true);

    // Bekleyen tüm cevapları hemen flush et
    const flushPromises: Promise<any>[] = [];
    const keys = Object.keys(dirtyAnswers.current);
    if (keys.length > 0) {
      const payload = keys.map(k => ({
        resultId,
        questionNumber: Number(k),
        selectedOption: dirtyAnswers.current[Number(k)]
      }));
      
      flushPromises.push(
        fetch("/api/student-answer-batch", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ answers: payload })
        }).then(() => {}).catch(() => {})
      );
      
      dirtyAnswers.current = {};
    }

    // Bekleyen çizim flush
    if (drawingDebounceTimer.current) {
      clearTimeout(drawingDebounceTimer.current);
      flushPromises.push(saveDrawings(drawings).catch(() => {}));
    }

    // Tüm flush'lar tamamlansın
    await Promise.all(flushPromises);

    await fetch("/api/finish-exam", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ resultId })
    });
    
    router.push("/ogrenci/dashboard");
    router.refresh();
  };

  function onDocumentLoadSuccess({ numPages }: { numPages: number }) {
    setNumPages(numPages);
  }

  function onDocumentLoadError(error: Error) {
    console.error("PDF Yüklenirken Hata:", error);
    setPdfError(`Dosya okunamadı: ${error.message} (Yöneticiye bildirin)`);
  }

  // Mobile tab state
  const [mobileTab, setMobileTab] = useState<'pdf' | 'optik'>('pdf');

  return (
    <div className="flex flex-col lg:flex-row h-screen bg-slate-50 font-sans overflow-hidden select-none text-slate-800">
      
      {/* Mobile Tab Bar */}
      <div className="lg:hidden h-12 bg-white border-b border-slate-200 flex items-center shrink-0 z-30">
        <button 
          onClick={() => setMobileTab('pdf')}
          className={`flex-1 h-full flex items-center justify-center gap-2 text-sm font-bold transition-colors ${mobileTab === 'pdf' ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50/50' : 'text-slate-500'}`}
        >
          <FileText className="w-4 h-4" /> Sınav PDF
        </button>
        <button 
          onClick={() => setMobileTab('optik')}
          className={`flex-1 h-full flex items-center justify-center gap-2 text-sm font-bold transition-colors ${mobileTab === 'optik' ? 'text-blue-600 border-b-2 border-blue-600 bg-blue-50/50' : 'text-slate-500'}`}
        >
          <ListChecks className="w-4 h-4" /> Optik Form
        </button>
      </div>

      {/* SOL PANEL: PDF GÖRÜNÜMÜ */}
      <div className={`flex-1 flex flex-col border-r border-slate-200 bg-white relative ${mobileTab === 'optik' ? 'hidden lg:flex' : 'flex'}`}>
        <div className="h-14 border-b border-slate-200 bg-white flex items-center justify-between px-3 md:px-6 shrink-0 z-10 shadow-sm">
          <div className="flex items-center gap-4">
            <span className="font-bold text-slate-700 tracking-widest uppercase text-[10px] md:text-xs truncate max-w-[150px] md:max-w-none">
              {exam.title}
            </span>
          </div>
          <div className="flex items-center gap-3">
            <button onClick={() => setScale(s => Math.max(0.5, s - 0.2))} className="p-2 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-blue-600 transition-colors" title="Uzaklaştır">
              <Minimize className="w-4 h-4" />
            </button>
            <span className="text-xs font-mono font-bold text-slate-600 w-12 text-center">{Math.round(scale * 100)}%</span>
            <button onClick={() => setScale(s => Math.min(3, s + 0.2))} className="p-2 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-blue-600 transition-colors" title="Yakınlaştır">
              <Maximize className="w-4 h-4" />
            </button>
          </div>
        </div>


        {/* Floating Toolbar (Sanal Kalem) - Mobilde gizli */}
        <div className="hidden md:flex absolute top-1/2 left-6 -translate-y-1/2 bg-white/90 backdrop-blur-md rounded-2xl shadow-[0_8px_30px_rgba(0,0,0,0.08)] border border-slate-200 p-2 flex-col gap-2 z-50">
          <button 
            onClick={() => setDrawingMode('pan')} 
            title="Ekranda Gezin (Pan)"
            className={`p-3 rounded-xl transition-all ${drawingMode==='pan' ? 'bg-blue-50 text-blue-600 shadow-sm' : 'text-slate-500 hover:bg-slate-50'}`}
          ><Move className="w-5 h-5"/></button>
          <button 
            onClick={() => setDrawingMode('pen')} 
            title="Kalem Aracı"
            className={`p-3 rounded-xl transition-all ${drawingMode==='pen' ? 'bg-blue-50 text-blue-600 shadow-sm' : 'text-slate-500 hover:bg-slate-50'}`}
          ><Pen className="w-5 h-5"/></button>
          <button 
            onClick={() => setDrawingMode('highlighter')} 
            title="Fosforlu Kalem"
            className={`p-3 rounded-xl transition-all ${drawingMode==='highlighter' ? 'bg-amber-50 text-amber-600 shadow-sm' : 'text-slate-500 hover:bg-slate-50'}`}
          ><Highlighter className="w-5 h-5"/></button>
          <button 
            onClick={() => setDrawingMode('eraser')} 
            title="Silgi"
            className={`p-3 rounded-xl transition-all ${drawingMode==='eraser' ? 'bg-slate-100 text-slate-800 shadow-sm' : 'text-slate-500 hover:bg-slate-50'}`}
          ><Eraser className="w-5 h-5"/></button>
          
          <div className="w-full h-px bg-slate-200 my-1"></div>
          
          {drawingMode === 'pen' && (
            <div className="flex flex-col gap-3 py-2 animate-in fade-in zoom-in-95">
              <button title="Mavi Kalem" onClick={()=>setPenColor('#2563eb')} className={`w-7 h-7 rounded-full bg-blue-600 mx-auto transition-all ${penColor==='#2563eb'?'ring-2 ring-offset-2 ring-blue-600 scale-110':''}`}></button>
              <button title="Kırmızı Kalem" onClick={()=>setPenColor('#dc2626')} className={`w-7 h-7 rounded-full bg-red-600 mx-auto transition-all ${penColor==='#dc2626'?'ring-2 ring-offset-2 ring-red-600 scale-110':''}`}></button>
              <button title="Siyah Kalem" onClick={()=>setPenColor('#1e293b')} className={`w-7 h-7 rounded-full bg-slate-800 mx-auto transition-all ${penColor==='#1e293b'?'ring-2 ring-offset-2 ring-slate-800 scale-110':''}`}></button>
            </div>
          )}
          
          {drawingMode === 'highlighter' && (
             <div className="flex flex-col gap-3 py-2 animate-in fade-in zoom-in-95">
               <div className="w-7 h-7 rounded-full bg-amber-400 mx-auto ring-2 ring-offset-2 ring-amber-400 opacity-50"></div>
             </div>
          )}

          <div className="w-full h-px bg-slate-200 my-1"></div>
          <button 
            onClick={() => {
               if(confirm("Bu sayfadaki tüm çizimlerinizi silmek istediğinize emin misiniz?")) {
                  handleStrokesChange([]);
               }
            }} 
            title="Sayfayı Temizle"
            className="p-3 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-colors mt-1"
          ><Trash2 className="w-5 h-5"/></button>
        </div>

        {/* Görünmez Koruyucu Kalkan (Kaldırıldı, Draw Events Bloke Olmasın) */}

        {/* PDF Render Alanı */}
        <div className="flex-1 overflow-auto custom-scrollbar p-4 md:p-8 bg-slate-100 relative max-h-[calc(100vh-170px)] lg:max-h-[calc(100vh-120px)]">
          {securityWarning && (
            <div className="absolute inset-0 z-50 bg-white/90 backdrop-blur-md flex items-center justify-center p-6 text-center">
              <div className="max-w-md">
                <ShieldAlert className="w-20 h-20 text-red-500 mx-auto mb-6 animate-pulse" />
                <h2 className="text-3xl font-black text-slate-900 mb-2">{securityWarning}</h2>
                <p className="text-slate-600 mb-8">Odak dışına çıktığınız (başka sekmeye geçmek veya ekran görüntüsü almak) tespit edildi. Bu ihlal yönetici tablosuna ve güvenlik kayıtlarına işlendi!</p>
                <button 
                  onClick={() => setSecurityWarning(null)}
                  className="px-8 py-3 bg-red-600 hover:bg-red-500 text-white font-bold rounded-xl shadow-sm"
                >
                  Sınava Geri Dön
                </button>
              </div>
            </div>
          )}

          {pdfError ? (
            <div className="text-red-500 flex flex-col items-center justify-center h-full max-w-md text-center">
              <ShieldAlert className="w-12 h-12 mb-4 opacity-50" />
              <p className="font-medium">{pdfError}</p>
            </div>
          ) : (
            <>
              {/* Zoom Controls */}
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
                file={exam.pdfUrl}
                onLoadSuccess={onDocumentLoadSuccess}
              onLoadError={onDocumentLoadError}
              loading={<div className="animate-pulse text-blue-600 font-bold">Sınav Yükleniyor...</div>}
              className="pdf-document drop-shadow-md mx-auto w-fit"
            >
              <div className="relative inline-block">
                <Page 
                  pageNumber={pageNumber} 
                  scale={scale} 
                  renderTextLayer={false} 
                  renderAnnotationLayer={false}
                  className="pdf-page bg-white"
                  onLoadSuccess={(page) => setPageDimensions({ width: page.originalWidth, height: page.originalHeight })}
                />
                {pageDimensions.width > 0 && (
                  <DrawingCanvas 
                    width={pageDimensions.width * scale}
                    height={pageDimensions.height * scale}
                    scale={scale}
                    mode={drawingMode}
                    color={penColor}
                    thickness={drawingMode === 'highlighter' ? 18 : penThickness}
                    strokes={drawings[pageNumber] || []}
                    onStrokeAdd={handleStrokeAdd}
                    onStrokesChange={handleStrokesChange}
                  />
                )}
              </div>
            </Document>
            </>
          )}
        </div>

        {/* PDF Sayfa Kontrolleri (Footer) */}
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

      {/* Offline Banner */}
      {isOffline && (
        <div className="bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-2 text-sm text-center font-medium shadow-sm z-50 relative">
          <WifiOff className="inline-block w-4 h-4 mr-2 mb-1" />
          İnternet bağlantınız koptu. Sınava devam edebilirsiniz, cevaplarınız cihazınıza kaydediliyor. İnternet geldiğinde otomatik olarak gönderilecek.
        </div>
      )}

      {/* Çizim Alanı Dolu Uyarısı */}
      {drawingLimitReached && (
        <div className="bg-amber-50 border-l-4 border-amber-500 text-amber-700 p-2 text-sm text-center font-medium shadow-sm z-50 relative">
          ✏️ Çizim alanı doldu. Mevcut çizimleriniz korunuyor ancak yeni çizim eklenemez. Sayfadaki çizimleri temizleyerek alan açabilirsiniz.
        </div>
      )}

      {/* Main Content */}
      <div className={`w-full lg:w-[450px] bg-slate-50 flex flex-col shrink-0 shadow-[-5px_0_15px_rgba(0,0,0,0.03)] z-20 ${mobileTab === 'pdf' ? 'hidden lg:flex' : 'flex'}`}>
        <div className="h-16 md:h-20 border-b border-slate-200 flex items-center justify-between px-4 md:px-6 shrink-0 bg-white shadow-sm z-10">
          <div className="flex items-center gap-3">
            <Clock className="w-6 h-6 md:w-8 md:h-8 text-blue-600" />
            <ExamTimer 
              durationMinutes={exam.durationMinutes}
              startedAt={startedAt}
              onTimeUp={forceFinishExam}
              isFinishing={isFinishing}
            />
          </div>
        </div>

        {/* Section Selector */}
        {parsedSections.length > 1 && (() => {
          const totalAnswered = Object.keys(answers).filter(k => answers[Number(k)] && answers[Number(k)] !== 'BOŞ').length;
          const activeSec = parsedSections.find((s: any) => s.id === activeSectionId);
          const currentAnswered = activeSec 
            ? Array.from({length: activeSec.count}, (_, i) => activeSec.startQ + i).filter(q => answers[q] && answers[q] !== 'BOŞ').length
            : totalAnswered;
          const currentTotal = activeSec ? activeSec.count : exam.questionCount;
          const progressPct = Math.round((currentAnswered / currentTotal) * 100);

          return (
            <div className="border-b border-slate-200 bg-white px-4 py-3 shrink-0">
              <div className="flex items-center gap-3">
                <select
                  value={activeSectionId || "__ALL__"}
                  onChange={(e) => setActiveSectionId(e.target.value === "__ALL__" ? null : e.target.value)}
                  className="flex-1 bg-slate-50 border border-slate-200 rounded-xl px-3 py-2.5 text-sm font-bold text-slate-700 outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-200 transition-all appearance-none cursor-pointer"
                  style={{ backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%2364748b' viewBox='0 0 16 16'%3E%3Cpath d='M8 11L3 6h10l-5 5z'/%3E%3C/svg%3E")`, backgroundRepeat: 'no-repeat', backgroundPosition: 'right 12px center' }}
                >
                  <option value="__ALL__">📋 Tüm Sorular ({totalAnswered}/{exam.questionCount})</option>
                  {parsedSections.map((sec: any) => {
                    const ans = Array.from({length: sec.count}, (_, i) => sec.startQ + i)
                      .filter(q => answers[q] && answers[q] !== 'BOŞ').length;
                    return (
                      <option key={sec.id} value={sec.id}>
                        {sec.title} ({ans}/{sec.count})
                      </option>
                    );
                  })}
                </select>
              </div>
              <div className="mt-2 h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <div 
                  className={`h-full rounded-full transition-all duration-500 ${progressPct === 100 ? 'bg-emerald-500' : 'bg-blue-500'}`}
                  style={{ width: `${progressPct}%` }}
                />
              </div>
            </div>
          );
        })()}

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
                      const selected = answers[qNum];
                      return (
                        <div key={qNum} className="flex items-center p-2 md:p-3 rounded-xl bg-white border border-slate-200 shadow-sm hover:border-blue-300 transition-colors">
                          <span className="font-mono font-black text-base md:text-lg text-slate-400 w-8 md:w-10 text-right pr-2 md:pr-4 border-r border-slate-200">
                            {i + 1}.
                          </span>
                          <div className="flex items-center gap-1.5 md:gap-2 pl-2 md:pl-4">
                            {["A", "B", "C", "D", "E"].map(opt => (
                              <button
                                key={opt}
                                onClick={() => handleOptionSelect(qNum, opt)}
                                className={`w-8 h-8 md:w-9 md:h-9 rounded-full border-2 text-xs md:text-sm font-black flex items-center justify-center transition-all duration-150 ${
                                  selected === opt
                                  ? 'bg-blue-600 border-blue-600 text-white shadow-md scale-110 z-10'
                                  : 'bg-white border-slate-300 text-slate-500 hover:border-blue-400 hover:text-blue-500'
                                }`}
                              >
                                {opt}
                              </button>
                            ))}
                            <button
                              onClick={() => handleOptionSelect(qNum, "BOŞ")}
                              className={`ml-1 md:ml-2 px-2 md:px-3 h-8 md:h-9 rounded-lg border-2 text-[10px] font-black flex items-center justify-center transition-all ${
                                !selected || selected === "BOŞ"
                                ? 'bg-slate-100 border-slate-200 text-slate-700 shadow-inner'
                                : 'bg-white border-slate-200 text-slate-400 hover:border-slate-300'
                              }`}
                            >
                              BOŞ
                            </button>
                          </div>
                        </div>
                      );
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
                        const selected = answers[qNum];
                        return (
                          <div key={qNum} className="flex items-center p-2 md:p-3 rounded-xl bg-white border border-slate-200 shadow-sm hover:border-blue-300 transition-colors">
                            <span className="font-mono font-black text-base md:text-lg text-slate-400 w-8 md:w-10 text-right pr-2 md:pr-4 border-r border-slate-200">
                              {i + 1}.
                            </span>
                            <div className="flex items-center gap-1.5 md:gap-2 pl-2 md:pl-4">
                              {["A", "B", "C", "D", "E"].map(opt => (
                                <button
                                  key={opt}
                                  onClick={() => handleOptionSelect(qNum, opt)}
                                  className={`w-8 h-8 md:w-9 md:h-9 rounded-full border-2 text-xs md:text-sm font-black flex items-center justify-center transition-all duration-150 ${
                                    selected === opt
                                    ? 'bg-blue-600 border-blue-600 text-white shadow-md scale-110 z-10'
                                    : 'bg-white border-slate-300 text-slate-500 hover:border-blue-400 hover:text-blue-500'
                                  }`}
                                >
                                  {opt}
                                </button>
                              ))}
                              <button
                                onClick={() => handleOptionSelect(qNum, "BOŞ")}
                                className={`ml-1 md:ml-2 px-2 md:px-3 h-8 md:h-9 rounded-lg border-2 text-[10px] font-black flex items-center justify-center transition-all ${
                                  !selected || selected === "BOŞ"
                                  ? 'bg-slate-100 border-slate-200 text-slate-700 shadow-inner'
                                  : 'bg-white border-slate-200 text-slate-400 hover:border-slate-300'
                                }`}
                              >
                                BOŞ
                              </button>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                ));
              } else {
                return Array.from({ length: exam.questionCount }).map((_, i) => {
                  const qNum = 1 + i;
                  const selected = answers[qNum];
                  return (
                    <div key={qNum} className="flex items-center p-2 md:p-3 rounded-xl bg-white border border-slate-200 shadow-sm hover:border-blue-300 transition-colors">
                      <span className="font-mono font-black text-base md:text-lg text-slate-400 w-8 md:w-10 text-right pr-2 md:pr-4 border-r border-slate-200">
                        {qNum}.
                      </span>
                      <div className="flex items-center gap-1.5 md:gap-2 pl-2 md:pl-4">
                        {["A", "B", "C", "D", "E"].map(opt => (
                          <button
                            key={opt}
                            onClick={() => handleOptionSelect(qNum, opt)}
                            className={`w-8 h-8 md:w-9 md:h-9 rounded-full border-2 text-xs md:text-sm font-black flex items-center justify-center transition-all duration-150 ${
                              selected === opt
                              ? 'bg-blue-600 border-blue-600 text-white shadow-md scale-110 z-10'
                              : 'bg-white border-slate-300 text-slate-500 hover:border-blue-400 hover:text-blue-500'
                            }`}
                          >
                            {opt}
                          </button>
                        ))}
                        <button
                          onClick={() => handleOptionSelect(qNum, "BOŞ")}
                          className={`ml-1 md:ml-2 px-2 md:px-3 h-8 md:h-9 rounded-lg border-2 text-[10px] font-black flex items-center justify-center transition-all ${
                            !selected || selected === "BOŞ"
                            ? 'bg-slate-100 border-slate-200 text-slate-700 shadow-inner'
                            : 'bg-white border-slate-200 text-slate-400 hover:border-slate-300'
                          }`}
                        >
                          BOŞ
                        </button>
                      </div>
                    </div>
                  );
                });
              }
            })()}
          </div>
        </div>

        <div className="p-4 md:p-6 border-t border-slate-200 bg-white shrink-0 shadow-[0_-5px_15px_rgba(0,0,0,0.03)] z-10">
          <button 
            disabled={isFinishing}
            onClick={() => setShowConfirmModal(true)}
            className="w-full flex items-center justify-center gap-2 py-3.5 bg-emerald-600 hover:bg-emerald-500 disabled:bg-slate-300 text-white font-black text-lg rounded-xl shadow-[0_4px_15px_rgba(5,150,105,0.2)] transition-all active:scale-95"
          >
            {isFinishing ? "KAYDEDİLİYOR..." : (
              <>
                <CheckCircle2 className="w-6 h-6" /> SINAVI BİTİR
              </>
            )}
          </button>
          <p className="text-center text-xs text-slate-500 mt-4 font-medium flex items-center justify-center gap-2">
             Tüm cevaplar anlık olarak sisteme işlenmektedir.
          </p>
        </div>
      </div>

      {/* Sınavı Bitir Onayı Popup */}
      {showConfirmModal && (
        <div className="fixed inset-0 z-[100] bg-slate-900/60 backdrop-blur flex items-center justify-center p-4 md:p-6">
          <div className="bg-white rounded-3xl p-8 max-w-sm w-full shadow-2xl border-4 border-slate-100 flex flex-col items-center text-center">
            <CheckCircle2 className="w-16 h-16 text-emerald-500 mb-6" />
            <h2 className="text-2xl font-black text-slate-800 mb-2">Sınavı Teslim Et</h2>
            <p className="text-slate-500 text-sm font-medium mb-8 leading-relaxed">
               Cevap formunu hocanıza teslim etmek üzeresiniz. Onayladıktan sonra karnenizi beklemeye başlarsınız ve cevaplarınızı değiştiremezsiniz!
            </p>
            <div className="flex flex-col gap-3 w-full">
              <button 
                onClick={() => {
                  setShowConfirmModal(false);
                  handleFinishExam();
                }}
                className="w-full py-3.5 px-4 bg-emerald-600 hover:bg-emerald-500 text-white font-bold rounded-xl shadow-[0_4px_15px_rgba(5,150,105,0.2)] transition-all"
              >
                Onaylıyorum, Bitir
              </button>
              <button 
                onClick={() => setShowConfirmModal(false)}
                className="w-full py-3.5 px-4 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-xl transition-colors"
              >
                Geri Dön
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
