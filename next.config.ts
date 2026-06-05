import type { NextConfig } from "next";
import withSerwistInit from "@serwist/next";

const withSerwist = withSerwistInit({
  swSrc: "src/app/sw.ts",
  swDest: "public/sw.js",
  disable: process.env.NODE_ENV === "development",
});

const nextConfig: NextConfig = {
  // Production output: Docker/VPS deploy için optimize edilmiş standalone bundle
  output: "standalone",
  
  // Gzip sıkıştırma: Sayfa boyutunu ~%60-70 küçültür
  compress: true,
  
  // Güvenlik: X-Powered-By header'ını gizle (sunucu teknolojisi ifşa olmasın)
  poweredByHeader: false,

  experimental: {
    serverActions: {
      bodySizeLimit: "30mb",
    },
  },

  // Resim optimizasyonu
  images: {
    formats: ["image/avif", "image/webp"],
  },
};

export default withSerwist(nextConfig);
