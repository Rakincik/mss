import { ReactNode } from "react";
import { getCurrentUser, logoutUser } from "@/app/actions/authActions";
import { redirect } from "next/navigation";
import AdminShell from "./AdminShell";

export default async function AdminLayout({ children }: { children: ReactNode }) {
  const user = await getCurrentUser();
  
  if (!user || user.role === "STUDENT") {
    redirect("/login");
  }
  return (
    <AdminShell user={{ 
      name: user.name, 
      role: user.role,
      isImpersonating: (user as any).isSuperAdminImpersonating,
      institutionName: (user as any).institution?.name
    }}>
      {children}
    </AdminShell>
  );
}
