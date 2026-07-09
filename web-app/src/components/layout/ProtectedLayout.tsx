"use client";

import { ReactNode, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { UserRole } from "@/types/auth.types";
import { hasRole } from "@/lib/auth/permissions";
import { APP_ROUTES } from "@/lib/utils/constants";
import { Loading } from "@/components/ui/Loading";

interface ProtectedLayoutProps {
  children: ReactNode;
  allowedRoles?: UserRole[];
}

export function ProtectedLayout({
  children,
  allowedRoles,
}: ProtectedLayoutProps) {
  const router = useRouter();
  const { user, token, isAuthenticated, isLoading } = useAuth();

  const [canRender, setCanRender] = useState(false);

  useEffect(() => {
    if (isLoading) {
      return;
    }

    if (!isAuthenticated || !user || !token) {
      router.replace(APP_ROUTES.LOGIN);
      return;
    }

    if (allowedRoles && !hasRole(user.roles, allowedRoles)) {
      router.replace(APP_ROUTES.UNAUTHORIZED);
      return;
    }

    setCanRender(true);
  }, [isLoading, isAuthenticated, user, token, allowedRoles, router]);

  if (isLoading || !canRender) {
    return <Loading text="Validando acceso..." />;
  }

  return <>{children}</>;
}