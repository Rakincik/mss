import { writeFile } from "fs/promises";
import path from "path";
import { existsSync, mkdirSync } from "fs";

export async function saveUploadedFile(fileName: string, buffer: Buffer) {
  // Her zaman process.cwd() içine kaydet (Dev için ve standalone sunucusu için)
  const localDir = path.join(process.cwd(), "public", "uploads");
  if (!existsSync(localDir)) {
    mkdirSync(localDir, { recursive: true });
  }
  await writeFile(path.join(localDir, fileName), buffer);

  // Eğer standalone mode'da çalışıyorsak (PM2 ile .next/standalone içinden çalışıyorsak)
  // Dosyayı asıl proje kök dizinindeki public/uploads klasörüne de kopyala
  // Çünkü Nginx statik dosyaları oradan sunuyor olabilir.
  const cwd = process.cwd();
  const isStandalone = cwd.includes(".next" + path.sep + "standalone") || cwd.endsWith("standalone");
  
  if (isStandalone) {
    const rootDir = path.join(cwd, "..", "..", "public", "uploads");
    if (!existsSync(rootDir)) {
      try {
        mkdirSync(rootDir, { recursive: true });
      } catch (e) {
        // İzin hatası vb. olabilir, görmezden gel
      }
    }
    try {
      await writeFile(path.join(rootDir, fileName), buffer);
    } catch (e) {
      console.error("Ana public klasörüne dosya kaydedilemedi:", e);
    }
  }
}
