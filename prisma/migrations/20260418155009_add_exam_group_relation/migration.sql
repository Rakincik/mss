-- CreateTable
CREATE TABLE "_ExamToGroup" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ExamToGroup_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE INDEX "_ExamToGroup_B_index" ON "_ExamToGroup"("B");

-- AddForeignKey
ALTER TABLE "_ExamToGroup" ADD CONSTRAINT "_ExamToGroup_A_fkey" FOREIGN KEY ("A") REFERENCES "Exam"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ExamToGroup" ADD CONSTRAINT "_ExamToGroup_B_fkey" FOREIGN KEY ("B") REFERENCES "Group"("id") ON DELETE CASCADE ON UPDATE CASCADE;
