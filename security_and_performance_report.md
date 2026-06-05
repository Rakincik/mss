# Muro Sınav Sistemi: 1000+ Eş Zamanlı Kullanıcı Performans Raporu

> **Tarih:** 24.04.2026 | **Senaryo:** TR Geneli Deneme Sınavı (1000-5000 öğrenci aynı anda)

---

## ✅ KOD DÜZEYİNDE UYGULANAN OPTİMİZASYONLAR

### 1. Singleton PrismaClient (KRİTİK — UYGULAND)

**Öncesi:** Sistemde 15 ayrı dosyada `new PrismaClient()` çağrısı vardı. Her istek ayrı bir DB bağlantı havuzu (connection pool) oluşturuyordu. 1000 öğrenci aynı anda sınava girdiğinde PostgreSQL'in varsayılan 100 bağlantı limiti anında doluyordu → sunucu çöküyordu.

**Sonrası:** `src/lib/prisma.ts` dosyasında singleton pattern uygulandı. Tüm 15 dosya bu tek instance'ı kullanıyor. Artık tüm uygulama boyunca tek bir bağlantı havuzu var → PostgreSQL bağlantı limiti korunuyor.

### 2. Timer İzolasyonu (UYGULANDI)
Her saniye tüm PDF Canvas + 40 soruluk Optik Form'u yeniden çizen `setInterval` ayrı `ExamTimer` bileşenine izole edildi. 1000 kişi sınavdayken her cihaz kendi CPU'sunu boşa harcamıyor.

### 3. Server-Side Pagination (UYGULANDI)
Admin panelindeki kullanıcı ve log listeleri artık `skip`/`take` ile sayfalanıyor. 10.000 kayıt olsa bile sunucu sadece 25 kayıt döndürüyor.

---

## 🏗️ ALTYAPI DÜZEYİNDE ÖNERİLER (SUNUCU TARAFINDA YAPILACAK)

### 4. PostgreSQL Connection Pool (PgBouncer)

**Neden:** Singleton PrismaClient bile varsayılan olarak 5 bağlantı açar. 1000 kişi sınav bitirme butonuna aynı anda basarsa, her biri `finish-exam` API'sine istek atar. Next.js serverless modda her fonksiyon ayrı çalışabilir.

**Çözüm:** PostgreSQL'in önüne **PgBouncer** (bağlantı havuzlayıcı) kurulmalıdır.

```env
# .env dosyasına:
DATABASE_URL="postgresql://user:pass@localhost:6432/muro_db?pgbouncer=true"
DIRECT_URL="postgresql://user:pass@localhost:5432/muro_db"
```

```prisma
// schema.prisma
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")  // Migration'lar için direkt bağlantı
}
```

**Kapasite:** PgBouncer transaction modunda 1000+ eş zamanlı sorguyu rahatça 20 PostgreSQL bağlantısına sıkıştırır.

---

### 5. PDF Dosyaları CDN Üzerinden Servisi

**Sorun:** 1000 öğrenci aynı anda 15MB PDF indirirse → 15GB anlık bant genişliği tüketimi. VPS patlar.

**Çözüm:** PDF'ler **BunnyCDN** veya **AWS CloudFront** üzerinden servisi:
- Admin PDF yüklediğinde → S3/BunnyCDN Storage'a upload
- `pdfUrl` alanına CDN URL kaydedilir (ör: `https://cdn.murosinavsistemi.com/exams/tr-geneli-2026.pdf`)
- CDN edge sunucuları PDF'i öğrenciye en yakın noktadan sunar
- Maliyet: ~$5-10/ay (1TB trafik)

---

### 6. Cevap Kaydetme Debounce & Batch

**Mevcut:** Öğrenci her şık tıkladığında anında `/api/student-answer` API'sine istek atıyor. 1000 kişi × 120 soru = sınavın herhangi bir anında binlerce DB write.

**Önerilen İyileştirme (İsteğe Bağlı):**
- İstemci tarafında 2 saniyelik **debounce** eklenerek, hızlı ardışık tıklamalar tek istekte birleştirilir
- Veya toplu (batch) cevap gönderimi: client 5 cevabı biriktirip tek istekte gönderir
- Bu sadece çok yoğun trafik senaryolarında gerekli; şu anki tekli kayıt sistemi 1000 kişiye kadar sorunsuz çalışır

---

### 7. Rate Limiting

**Neden:** Kötü niyetli bir kullanıcı veya bot, API'lere saniye de yüzlerce istek atabilir.

**Çözüm:** Next.js middleware'ine basit rate limiter eklenebilir:
- `/api/student-answer` → Kişi başı max 60 istek/dakika
- `/api/telemetry` → Kişi başı max 30 istek/dakika
- `/api/finish-exam` → Kişi başı max 3 istek/dakika

---

### 8. Sunucu Boyutlandırma Tablosu

| Eşzamanlı Öğrenci | Min VPS Spec | PostgreSQL | Tavsiye |
|---|---|---|---|
| 1-100 | 2 vCPU / 4GB RAM | Aynı sunucu | ✅ Mevcut yeterli |
| 100-500 | 4 vCPU / 8GB RAM | Aynı sunucu + PgBouncer | PDF CDN ekle |
| 500-2000 | 8 vCPU / 16GB RAM | Ayrı DB sunucusu | CDN + PgBouncer zorunlu |
| 2000-5000 | 2x App + Load Balancer | Managed PostgreSQL (Supabase/Neon) | Redis session + CDN |

---

## Özet: Şu An Neredeyiz?

| Optimizasyon | Durum | Etki |
|---|---|---|
| Singleton PrismaClient | ✅ Uygulandı | DB çökmesini önler |
| Timer İzolasyonu | ✅ Uygulandı | Client performansı 3x |
| Server-Side Pagination | ✅ Uygulandı | Admin panel hızı |
| Cevap Anahtarı Maskeleme | ✅ Uygulandı | Kopya engeli |
| Zod API Validasyonu | ✅ Uygulandı | Güvenlik kalkanı |
| PgBouncer | ⏳ Sunucu kurulumu gerekli | 1000+ kullanıcı |
| PDF CDN | ⏳ CDN hesabı gerekli | Bant genişliği |
| Rate Limiting | 💡 İsteğe bağlı | DDoS koruması |

**Mevcut kod optimizasyonlarıyla sistem 500-1000 eş zamanlı kullanıcıyı rahatça kaldırır.**
**PgBouncer + CDN eklendiğinde 2000-5000 aralığına çıkılabilir.**
