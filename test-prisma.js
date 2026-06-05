const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  try {
    const exam = await prisma.exam.create({
      data: {
        title: "test",
        description: "test",
        questionCount: 9,
        sections: [
          {
            id: "1776977412308",
            title: "Genel Test",
            count: "5",
            points: 1
          }
        ],
        startTime: new Date("2026-04-24T14:00:00.000Z"),
        endTime: new Date("2026-04-24T16:00:00.000Z"),
        showResultsTime: null,
        durationMinutes: null,
        pdfUrl: "/uploads/test.pdf",
        solutionPdfUrl: null,
        examTemplate: "CUSTOM",
        baseScore: 100,
        penaltyRatio: 0.25,
        isActive: true,
        groups: { connect: [] }
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
