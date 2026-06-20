import { appendFile, mkdir } from "fs/promises";
import path from "path";
import { existsSync, mkdirSync } from "fs";

/**
 * Merkezi Denetim Loglayıcı (Audit Logger)
 * 
 * Bu modül, sistemdeki kritik işlemleri hem terminale (PM2 logs) hem de
 * sunucudaki fiziksel bir log dosyasına (logs/audit.log) yazar.
 * Standalone modda derleme silinmelerinden etkilenmemesi için kök dizine kaydeder.
 */
export async function logAction(
  action: string, 
  user: { name?: string | null, email?: string | null, role?: string, id?: string } | null | undefined, 
  message: string, 
  details?: any
) {
  try {
    const now = new Date();
    // Türkiye saati ile okunaklı zaman damgası (Örn: 20.06.2026 07:45:12)
    const timeString = now.toLocaleString("tr-TR", { 
      timeZone: "Europe/Istanbul", 
      year: "numeric", 
      month: "2-digit", 
      day: "2-digit", 
      hour: "2-digit", 
      minute: "2-digit", 
      second: "2-digit" 
    });
    
    const role = user?.role || "SYSTEM";
    const userName = user?.name || "Bilinmiyor";
    const userEmail = user?.email || "Email Yok";
    
    let logLine = `[${timeString}] [${role}] [${action}] (${userName} - ${userEmail}) -> ${message}`;
    
    if (details) {
       logLine += ` | Detaylar: ${JSON.stringify(details)}`;
    }
    
    // 1. Terminale bas (pm2 logs ile anlık izleyebilmek için)
    console.info(logLine);
    
    // 2. Fiziksel Dosyaya Yaz (Kalıcı Arşiv)
    const cwd = process.cwd();
    const isStandalone = cwd.includes(".next" + path.sep + "standalone") || cwd.endsWith("standalone");
    
    // Standalone modundaysak kök dizine git, değilsek mevcut dizine
    const baseDir = isStandalone ? path.join(cwd, "..", "..") : cwd;
    const logDir = path.join(baseDir, "logs");
    
    if (!existsSync(logDir)) {
      mkdirSync(logDir, { recursive: true });
    }
    
    // Dosya boyutu çok büyümesin diye aya göre log dosyası ayırabiliriz
    const monthStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    const logFilePath = path.join(logDir, `audit-${monthStr}.log`);
    
    await appendFile(logFilePath, logLine + "\n", "utf8");
    
  } catch (err) {
    console.error("Audit Logger Hatası:", err);
  }
}
