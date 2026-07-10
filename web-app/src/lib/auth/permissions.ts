import { UserRole } from "@/types/auth.types";
import { APP_ROUTES } from "@/lib/utils/constants";

export function hasRole(
  userRoles: UserRole[] | undefined | null,
  allowedRoles: UserRole[]
): boolean {
  if (!Array.isArray(userRoles)) {
    return false;
  }

  return userRoles.some((role) => allowedRoles.includes(role));
}

export function getDefaultRouteByRole(
  roles: UserRole[] | undefined | null
): string {
  if (!Array.isArray(roles)) {
    return APP_ROUTES.DASHBOARD;
  }

  if (roles.includes("ADMIN") || roles.includes("COORDINADOR")) {
    return APP_ROUTES.ADMIN;
  }

  if (roles.includes("DOCENTE")) {
    return APP_ROUTES.DOCENTE;
  }

  if (roles.includes("ESTUDIANTE")) {
    return APP_ROUTES.ESTUDIANTE;
  }

  return APP_ROUTES.DASHBOARD;
}