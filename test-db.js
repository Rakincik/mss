const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function run() {
    try {
        const transactions = await prisma.transaction.findMany({
            orderBy: { createdAt: "desc" }
          });
        console.log("Found", transactions.length, "transactions");
    } catch(e) {
        console.error("DB Error:", e);
    }
}
run();
