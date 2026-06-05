const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log("Migration started...");
  
  // 1. Create or find default institution
  let defaultInst = await prisma.institution.findFirst({
    where: { name: "Varsayılan Kurum (Mevcut Veriler)" }
  });

  if (!defaultInst) {
    defaultInst = await prisma.institution.create({
      data: {
        name: "Varsayılan Kurum (Mevcut Veriler)",
        subdomain: "default"
      }
    });
    console.log("Created default institution:", defaultInst.id);
  } else {
    console.log("Default institution already exists:", defaultInst.id);
  }

  // 2. Update users
  const userRes = await prisma.user.updateMany({
    where: { institutionId: null },
    data: { institutionId: defaultInst.id }
  });
  console.log(`Updated ${userRes.count} users.`);

  // 3. Update groups
  const groupRes = await prisma.group.updateMany({
    where: { institutionId: null },
    data: { institutionId: defaultInst.id }
  });
  console.log(`Updated ${groupRes.count} groups.`);

  // 4. Update exams
  const examRes = await prisma.exam.updateMany({
    where: { institutionId: null },
    data: { institutionId: defaultInst.id }
  });
  console.log(`Updated ${examRes.count} exams.`);

  // 5. Update transactions
  const transRes = await prisma.transaction.updateMany({
    where: { institutionId: null },
    data: { institutionId: defaultInst.id }
  });
  console.log(`Updated ${transRes.count} transactions.`);

  console.log("Migration completed successfully.");
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
