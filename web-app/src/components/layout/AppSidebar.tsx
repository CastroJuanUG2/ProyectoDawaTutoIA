"use client";

import Link from "next/link";
import { useAuth } from "@/context/AuthContext";
import { APP_ROUTES } from "@/lib/utils/constants";

export function AppSidebar() {
  const { user } = useAuth();

  const roles = user?.roles ?? [];

  const isAdmin = roles.includes("ADMIN") || roles.includes("COORDINADOR");
  const isDocente = roles.includes("DOCENTE");
  const isEstudiante = roles.includes("ESTUDIANTE");

  return (
    <aside className="app-sidebar">
      <h2>Menú</h2>

      <nav>
        <Link href={APP_ROUTES.DASHBOARD}>Dashboard</Link>
        <Link href={APP_ROUTES.IA_CHAT}>Chat IA</Link>

        {isAdmin && (
          <>
            <Link href={APP_ROUTES.ADMIN}>Panel administrativo</Link>
            <Link href={APP_ROUTES.ADMIN_USUARIOS}>Usuarios</Link>
            <Link href={APP_ROUTES.ADMIN_ROLES}>Roles</Link>
            <Link href={APP_ROUTES.ADMIN_ACADEMICO}>Administración académica</Link>
            <Link href={APP_ROUTES.REPORTES}>Reportes</Link>
          </>
        )}

        {isDocente && (
          <>
            <Link href={APP_ROUTES.DOCENTE}>Panel docente</Link>
            <Link href={APP_ROUTES.DOCENTE_SOLICITUDES}>Solicitudes</Link>
            <Link href={APP_ROUTES.DOCENTE_BITACORAS}>Bitácoras</Link>
          </>
        )}

        {isEstudiante && (
          <>
            <Link href={APP_ROUTES.ESTUDIANTE}>Panel estudiante</Link>
            <Link href={APP_ROUTES.ESTUDIANTE_SOLICITAR_TUTORIA}>
              Solicitar tutoría
            </Link>
            <Link href={APP_ROUTES.ESTUDIANTE_HISTORIAL}>
              Historial de tutorías
            </Link>
          </>
        )}
      </nav>
    </aside>
  );
}