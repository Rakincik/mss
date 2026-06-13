const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const logs = await prisma.securityLog.findMany({
    where: { user: { institutionId: null } },
    include: { user: { select: { name: true, institutionId: true, role: true } } }
  });
  console.log('Logs count:', logs.length);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
