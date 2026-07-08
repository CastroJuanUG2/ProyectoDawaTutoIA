"use client";

import { ReactNode, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { UserRole } from "@/types/auth.types";
import { hasRole } from "@/lib/auth/permissions";
import { APP_ROUTES } from "@/lib/utils/constants";

interface ProtectedLayoutProps {
  children: ReactNode;
  allowedRoles?: UserRole[];
}

export function ProtectedLayout({
  children,
  allowedRoles,
}: ProtectedLayoutProps) {
  const router = useRouter();
  const { user, isAuthenticated, isLoading } = useAuth();

  const [isCheckingAccess, setIsCheckingAccess] = useState(true);
  const [hasAccess, setHasAccess] = useState(false);

  useEffect(() => {
    if (isLoading) {
      return;
    }

    if (!isAuthenticated || !user) {
      setHasAccess(false);
      setIsCheckingAccess(false);
      router.replace(APP_ROUTES.LOGIN);
      return;
    }

    if (allowedRoles && allowedRoles.length > 0) {
      const userHasAllowedRole = hasRole(user.roles, allowedRoles);

      if (!userHasAllowedRole) {
        setHasAccess(false);
        setIsCheckingAccess(false);
        router.replace(APP_ROUTES.UNAUTHORIZED);
        return;
      }
    }

    setHasAccess(true);
    setIsCheckingAccess(false);
  }, [isLoading, isAuthenticated, user, allowedRoles, router]);

  if (isLoading || isCheckingAccess) {
    return (
      <main className="loading-page">
        <div className="loading-card">
          <h2>Validando acceso...</h2>
          <p>Estamos verificando tu sesión y permisos.</p>
        </div>
      </main>
    );
  }

  if (!hasAccess) {
    return null;
  }

  return <>{children}</>;
}