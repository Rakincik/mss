import { NextRequest, NextResponse } from "next/server";

/**
 * PDF Koruma Middleware'i
 * 
 * /uploads/* altındaki tüm dosyaları (sınav PDF'leri, çözüm kitapçıkları)
 * sadece giriş yapmış kullanıcılara açar.
 * 
 * URL'i bilen anonim bir kullanıcı artık PDF'i doğrudan indiremez.
 * Service Worker cache'i etkilenmez çünkü öğrenci zaten giriş yapmış
 * durumda olduğunda ilk isteği cookie ile gönderir.
 */
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Sadece /uploads/ altındaki dosyaları koru
  if (pathname.startsWith("/uploads/")) {
    const sessionCookie = request.cookies.get("muro_session")?.value
      || request.cookies.get("muro_student_id")?.value;

    if (!sessionCookie) {
      return new NextResponse("Yetkisiz erişim. Lütfen giriş yapın.", {
        status: 401,
        headers: { "Content-Type": "text/plain; charset=utf-8" },
      });
    }

    // Giriş yapmış kullanıcı — isteği devam ettir
    const response = NextResponse.next();
    response.headers.set("X-Content-Type-Options", "nosniff");
    return response;
  }

  // /muro-admin koruması
  if (pathname.startsWith("/muro-admin")) {
    const sessionCookie = request.cookies.get("muro_session")?.value;
    if (!sessionCookie) {
      return NextResponse.redirect(new URL("/login", request.url));
    }
  }

  // /ogrenci koruması
  if (pathname.startsWith("/ogrenci")) {
    const sessionCookie = request.cookies.get("muro_session")?.value || request.cookies.get("muro_student_id")?.value;
    if (!sessionCookie) {
      return NextResponse.redirect(new URL("/login", request.url));
    }
  }

  return NextResponse.next();
}

// Middleware sadece bu yollarda çalışsın (performans için)
export const config = {
  matcher: [
    "/uploads/:path*",
    "/muro-admin/:path*",
    "/ogrenci/:path*"
  ],
};
