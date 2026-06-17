import { getCurrentUserWithGroups } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import StudentShell from "./StudentShell";

export const dynamic = "force-dynamic";

export default async function StudentPanelLayout({ children }: { children: React.ReactNode }) {
  const student = await getCurrentUserWithGroups();
  
  if (!student || student.role !== "STUDENT") {
    redirect("/login");
  }

  return (
    <StudentShell student={student}>
      {children}
    </StudentShell>
  );
}
