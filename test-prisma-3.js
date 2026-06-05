const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  try {
    const exam = await prisma.exam.create({
      data: {
        title: "test",
        description: "test",
        questionCount: 9,
        sections: null,
        startTime: new Date(),
        endTime: null,
        showResultsTime: null,
        durationMinutes: null,
        pdfUrl: "/uploads/test.pdf",
        solutionPdfUrl: null,
        examTemplate: "CUSTOM",
        baseScore: 100,
        penaltyRatio: 0.25,
        isActive: true,
        groups: { connect: [{ id: "NOT_EXIST_GROUP_UUID" }] }
      }
    });
    console.log("SUCCESS:", exam.id);
  } catch (err) {
    console.error("PRISMA ERROR:\n", err.message);
  } finally {
    await prisma.$disconnect();
  }
}

main();
