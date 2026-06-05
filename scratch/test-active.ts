import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  try {
    const exam = await prisma.exam.findFirst();
    if (!exam) {
      console.log("No exam found");
      return;
    }
    console.log("Found exam:", exam.id, "isActive:", exam.isActive);
    await prisma.exam.update({
      where: { id: exam.id },
      data: { isActive: !exam.isActive }
    });
    console.log("Update successful");
  } catch (e: any) {
    console.error("Error:", e.message);
  } finally {
    await prisma.$disconnect();
  }
}

main();
