"use client";

import Link from "next/link";
import { useAuth } from "@/context/AuthContext";
import { getDefaultRouteByRole } from "@/lib/auth/permissions";

export default function UnauthorizedPage() {
  const { user } = useAuth();

  const returnRoute = user ? getDefaultRouteByRole(user.roles) : "/login";

  return (
    <main className="unauthorized-page">
      <section className="unauthorized-card">
        <h1>Acceso no autorizado</h1>
        <p>No tienes permisos para ingresar a este módulo.</p>

        <Link href={returnRoute} className="home-link">
          Volver a mi panel
        </Link>
      </section>
    </main>
  );
}