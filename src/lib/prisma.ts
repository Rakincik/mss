import { PrismaClient } from "@prisma/client";

/**
 * Singleton Prisma Client
 * 
 * Next.js development modunda Hot Module Reload (HMR) her dosya değişikliğinde
 * yeni bir PrismaClient oluşturur. Bu da PostgreSQL bağlantı limitini aşar.
 * Production'da ise her serverless fonksiyon farklı bağlantı açar.
 * 
 * Bu dosya TÜM uygulama genelinde tek bir PrismaClient kullanılmasını sağlar.
 * PostgreSQL varsayılan 100 bağlantı limitini korur.
 * 
 * 1000+ eş zamanlı kullanıcı senaryosunda bu ZORUNLUDUR.
 */

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
