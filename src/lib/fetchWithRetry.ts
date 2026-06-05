/**
 * Akıllı Fetch — Otomatik Retry + Offline Queue
 * 
 * Sınav sırasında internet kesilirse veya sunucu geçici olarak yanıt vermezse:
 * 1. İlk başarısız istekte 1 saniye bekleyip tekrar dene
 * 2. İkinci başarısızlıkta 2 saniye bekle
 * 3. Üçüncü başarısızlıkta 4 saniye bekle
 * 4. 3 deneme sonrasında offline kuyruğa al
 * 
 * Kuyrukta biriken istekler internet geri geldiğinde otomatik gönderilir.
 */

type QueuedRequest = {
  url: string;
  options: RequestInit;
  timestamp: number;
};

// Offline istek kuyruğu (bellekte tutuluyor, sayfa yenilenene kadar yaşar)
const offlineQueue: QueuedRequest[] = [];
let isProcessingQueue = false;

// Exponential backoff ile retry
export async function fetchWithRetry(
  url: string,
  options: RequestInit,
  maxRetries: number = 3
): Promise<Response | null> {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, options);
      if (response.ok) {
        // Başarılı — kuyruktaki istekleri de gönder
        processQueue();
        return response;
      }
      // 5xx server hatası — retry edebiliriz
      if (response.status >= 500 && attempt < maxRetries) {
        await sleep(Math.pow(2, attempt) * 1000); // 1s, 2s, 4s
        continue;
      }
      return response; // 4xx hataları direkt döndür
    } catch (err) {
      // Network hatası (offline, timeout vb.)
      if (attempt < maxRetries) {
        await sleep(Math.pow(2, attempt) * 1000);
        continue;
      }
      // Son deneme de başarısız — kuyruğa ekle
      offlineQueue.push({
        url,
        options: { ...options },
        timestamp: Date.now()
      });
      console.warn(`[RetryFetch] Request queued for later: ${url} (${offlineQueue.length} in queue)`);
      return null;
    }
  }
  return null;
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Kuyrukta biriken istekleri gönder
async function processQueue() {
  if (isProcessingQueue || offlineQueue.length === 0) return;
  isProcessingQueue = true;

  while (offlineQueue.length > 0) {
    const request = offlineQueue[0];
    
    // 10 dakikadan eski istekleri at (artık geçerliliği kalmamış olabilir)
    if (Date.now() - request.timestamp > 10 * 60 * 1000) {
      offlineQueue.shift();
      continue;
    }

    try {
      const response = await fetch(request.url, request.options);
      if (response.ok) {
        offlineQueue.shift(); // Başarılı — kuyruktan çıkar
      } else {
        break; // Sunucu hala sorunlu — durakla
      }
    } catch {
      break; // Hala offline — durakla
    }
  }

  isProcessingQueue = false;
}

// İnternet geri geldiğinde kuyruğu işle
if (typeof window !== "undefined") {
  window.addEventListener("online", () => {
    console.log("[RetryFetch] Back online — processing queue...");
    processQueue();
  });
}

// Kuyruk durumunu sorgula
export function getQueueSize(): number {
  return offlineQueue.length;
}
