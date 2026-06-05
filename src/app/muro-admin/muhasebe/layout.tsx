import { getCurrentUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import { ReactNode } from "react";

export default async function MuhasebeLayout({ children }: { children: ReactNode }) {
  const user = await getCurrentUser();
  
  if (!user || user.role === "ASISTAN" || user.role === "STUDENT") {
    redirect("/muro-admin");
  }
  
  return <>{children}</>;
}
