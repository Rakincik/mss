"use client";

import { useState, useEffect, useCallback, memo } from "react";
import { Clock } from "lucide-react";

interface ExamTimerProps {
  durationMinutes: number | null;
  startedAt?: string;
  onTimeUp: () => void;
  isFinishing: boolean;
}

/**
 * İzole Edilmiş Sınav Zamanlayıcı Bileşeni
 * 
 * Bu bileşen, her saniye sadece KENDİSİNİ yeniden çizer (re-render).
 * Ana ExamInterface bileşenini her saniye yeniden çizme yükünden kurtarır.
 * Bu, düşük güçlü cihazlarda (tablet, eski telefon) ciddi performans kazancı sağlar.
 */
function ExamTimerComponent({ durationMinutes, startedAt, onTimeUp, isFinishing }: ExamTimerProps) {
  const [timeLeft, setTimeLeft] = useState<number | null>(null);

  useEffect(() => {
    if (!durationMinutes || !startedAt) {
      if (!isFinishing) setTimeLeft(null);
      return;
    }

    const durationMs = durationMinutes * 60 * 1000;
    const start = new Date(startedAt).getTime();
    const end = start + durationMs;

    const interval = setInterval(() => {
      if (isFinishing) return;
      const now = new Date().getTime();
      const difference = end - now;

      if (difference <= 0) {
        clearInterval(interval);
        setTimeLeft(0);
        onTimeUp();
      } else {
        setTimeLeft(Math.floor(difference / 1000));
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [durationMinutes, startedAt, onTimeUp, isFinishing]);

  return (
    <div className="flex flex-col">
      <span className="text-xl font-mono font-black text-slate-800 tracking-wider">OPTİK FORM</span>
      {timeLeft !== null && (
        <span className={`text-sm md:text-base font-black mt-1 px-3 py-1 rounded-lg w-max border ${timeLeft < 300 ? 'bg-red-50 text-red-600 border-red-200 animate-[pulse_1.5s_ease-in-out_infinite]' : 'bg-slate-100 text-slate-700 border-slate-200'}`}>
          KALAN SÜRE: {Math.floor(timeLeft / 60)}:{String(timeLeft % 60).padStart(2, '0')}
        </span>
      )}
      {durationMinutes && timeLeft === null && (
        <span className="text-sm font-bold mt-1 text-slate-500 px-2">SÜRE HESAPLANIYOR...</span>
      )}
    </div>
  );
}

export const ExamTimer = memo(ExamTimerComponent);
