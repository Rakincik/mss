import { getCurrentUserWithGroups } from "@/app/actions/authActions";
import { prisma } from "@/lib/prisma";
import { getCachedExam } from "@/lib/examCache";
import { redirect } from "next/navigation";
import ExamInterface from "./ExamInterface";
import { ExamErrorBoundary } from "@/components/ExamErrorBoundary";

export const dynamic = "force-dynamic";

export default async function SınavOdasiPage({ params }: { params: Promise<{ examId: string }> }) {
  const resolvedParams = await params;
  const examId = resolvedParams.examId;
  const student = await getCurrentUserWithGroups();
  
  if (!student) {
    redirect("/login");
  }

  if (!student.isActive) {
    return <div className="p-10 text-white font-bold text-center mt-20 text-xl">Hesabınız pasife alınmıştır. Sınava giriş yapamazsınız.</div>;
  }

  // 1. Sınavı ÖNBELLEKTEN getir (5 dakika cache — 1000 kişi 1 sorgu)
  const exam = await getCachedExam(examId);

  if (!exam) return <div className="p-10 text-white font-bold text-center mt-20 text-xl">Sınav bulunamadı.</div>;

  // Master Switch ve Tarih Kontrolleri
  if (!exam.isActive) {
    return <div className="p-10 text-white font-bold text-center mt-20 text-xl">Bu sınav henüz aktif edilmemiştir veya erişime kapatılmıştır.</div>;
  }

  const now = new Date();
  if (exam.startTime && new Date(exam.startTime) > now) {
    return <div className="p-10 text-white font-bold text-center mt-20 text-xl text-amber-400">Bu sınav henüz başlamadı. Başlama Tarihi: {new Date(exam.startTime).toLocaleString('tr-TR')}</div>;
  }

  if (exam.endTime && new Date(exam.endTime) < now) {
    return <div className="p-10 text-white font-bold text-center mt-20 text-xl text-red-400">Bu sınavın süresi dolmuştur. Bitiş Tarihi: {new Date(exam.endTime).toLocaleString('tr-TR')}</div>;
  }

  // 2. Yetki kontrolü (Öğrencinin grubu bu sınava atanmış ve aktif mi? VEYA direkt satın aldı mı?)
  const assignedGroup = exam.groups.find(g => (student as any).groups?.some((sg: any) => sg.id === g.id));
  const hasDirectAccess = exam.directUsers?.some((u: any) => u.id === student.id) ?? false;
  
  if (!assignedGroup && !hasDirectAccess && exam.groups.length > 0) {
    return <div className="p-10 text-white font-bold text-center mt-20 text-xl">Bu sınava giriş yetkiniz bulunmamaktadır.</div>;
  }

  // Bağımsız direkt erişimi YOKSA grup kurallarını işlet
  if (!hasDirectAccess && assignedGroup) {
    if (!assignedGroup.isActive) {
       return <div className="p-10 text-white font-bold text-center mt-20 text-xl">Grubunuz pasife alındığı için sınava giremezsiniz.</div>;
    }
    if (assignedGroup.expireAt && new Date() > new Date(assignedGroup.expireAt)) {
       return <div className="p-10 text-white font-bold text-center mt-20 text-xl">Grubunuzun erişim süresi dolmuştur.</div>;
    }
  }

  // 3. Sınav Oturumu (Result) oluştur veya var olanı al
  let result = await prisma.examResult.findFirst({
    where: { examId: exam.id, userId: student.id },
    include: { answers: true }
  });

  if (!result) {
    result = await prisma.examResult.create({
      data: {
        examId: exam.id,
        userId: student.id,
        // Diğerleri varsayılan 0
      },
      include: { answers: true }
    });
  }

  if (result.isFinished) {
    redirect(`/ogrenci/karne/${result.id}`);
  }

  // 4. Öğrencinin daha önce girdiği cevaplar (Sayfa yenilendiyse diye)
  const initialAnswers: Record<number, string> = {};
  result.answers.forEach(a => {
    if (a.selectedOption) {
      initialAnswers[a.questionNumber] = a.selectedOption;
    }
  });

  // 5. Kaydedilmiş çizimleri al
  let initialDrawings = {};
  if (result.drawings) {
    try {
      initialDrawings = typeof result.drawings === 'string' ? JSON.parse(result.drawings) : result.drawings;
    } catch(e) {}
  }

  // GÜVENLİK: Cevap anahtarlarını (correctOption) client'a GÖNDERMİYORUZ!
  // Sadece soru numarası ve konu bilgisi (topic) gönderiyoruz.
  const safeExam = {
    ...exam,
    keys: exam.keys.map((k: any) => ({
      questionNumber: k.questionNumber,
      topic: k.topic || null,
      // correctOption, points, videoUrl KASITLI OLARAK GÖNDERİLMİYOR
    })),
    // Grup ve direkt kullanıcı detaylarını da client'a sızdırma
    groups: undefined,
    directUsers: undefined,
  };

  // Client Component'e MASKELENMİŞ datayı gönderiyoruz
  return (
    <ExamErrorBoundary fallbackMessage="Sınav arayüzünde bir sorun oluştu. Cevaplarınız sunucuda güvenle kayıtlıdır.">
      <ExamInterface 
        exam={safeExam} 
        resultId={result.id} 
        studentId={student.id}
        initialAnswers={initialAnswers} 
        initialDrawings={initialDrawings as any}
        startedAt={result.createdAt.toISOString()}
      />
    </ExamErrorBoundary>
  );
}
