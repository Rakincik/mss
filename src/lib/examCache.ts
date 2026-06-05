import { prisma } from "@/lib/prisma";
import { unstable_cache } from "next/cache";

/**
 * Sınav Verisi Önbellek Katmanı
 * 
 * 1000 öğrenci aynı sınava girdiğinde, sınav meta verisi (başlık, süre, soru sayısı,
 * grup atamaları, cevap anahtarları) her seferinde DB'den çekilmez.
 * 
 * Bu modül Next.js `unstable_cache` kullanarak sınav verisini 5 dakika önbellekte tutar.
 * Sınav verisi Admin tarafından güncellendiğinde cache `revalidateTag` ile temizlenir.
 * 
 * Kazanım: 1000 istek × ~50ms DB sorgusu = 50 saniye DB zamanı → 1 sorgu × 50ms = 50ms
 */

// Sınav verisini önbellekle (5 dakika, tag ile invalidate edilebilir)
export const getCachedExam = unstable_cache(
  async (examId: string) => {
    const exam = await prisma.exam.findUnique({
      where: { id: examId },
      include: {
        groups: true,
        directUsers: { select: { id: true } },
        keys: { orderBy: { questionNumber: "asc" } },
      }
    });
    return exam;
  },
  ["exam-data"], // Cache key prefix
  {
    revalidate: 300, // 5 dakika
    tags: ["exam-data"], // revalidateTag("exam-data") ile temizlenebilir
  }
);

// Belirli bir sınavın cache'ini temizle (admin sınavı güncellediğinde)
export async function invalidateExamCache() {
  const { revalidateTag } = await import("next/cache");
  revalidateTag("exam-data", "default");
}
