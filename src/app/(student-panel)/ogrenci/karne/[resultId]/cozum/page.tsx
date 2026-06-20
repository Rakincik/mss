import { prisma } from "@/lib/prisma";
import { getCurrentUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import SolutionInterface from "./SolutionInterfaceWrapper";

export default async function SınavCozumEkraniPage({ params }: { params: Promise<{ resultId: string }> }) {
  const resolvedParams = await params;
  const resultId = resolvedParams.resultId;
  const student = await getCurrentUser();

  if (!student) redirect("/login");

  const result = await prisma.examResult.findUnique({
    where: { id: resultId },
    include: {
      exam: { include: { keys: true } },
      answers: true
    }
  });

  if (!result || result.userId !== student.id || !result.exam.solutionPdfUrl) {
    return <div className="p-10 text-slate-800 text-center mt-20">Çözüm kitapçığı bulunamadı veya yetkiniz yok.</div>;
  }

  const isTimePublished = result.exam.showResultsTime && new Date() >= new Date(result.exam.showResultsTime);
  const isReallyPublished = result.exam.isResultsPublished || isTimePublished;

  if (!isReallyPublished) {
    return <div className="p-10 text-slate-800 text-center mt-20">Sonuçlar henüz yayınlanmadı.</div>;
  }

  const initialAnswers: Record<number, string> = {};
  result.answers.forEach(a => {
    initialAnswers[a.questionNumber] = a.selectedOption || "BOŞ";
  });

  return (
    <div className="h-screen w-full">
      <SolutionInterface 
        exam={result.exam} 
        initialAnswers={initialAnswers} 
      />
    </div>
  );
}
