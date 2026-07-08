"use client";

import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { useAuth } from "@/context/AuthContext";

export default function DashboardPage() {
  const { user } = useAuth();

  return (
    <ProtectedLayout>
      <AppShell>
        <section className="page-section">
          <h2>Panel principal</h2>
          <p>
            Bienvenido, {user?.nombres}. Desde aquí podrás acceder a los módulos
            disponibles según tu rol.
          </p>

          <div className="dashboard-grid">
            <div className="dashboard-card">
              <h3>Mis roles</h3>
              <p>{user?.roles.join(", ")}</p>
            </div>

            <div className="dashboard-card">
              <h3>Acceso rápido</h3>
              <p>Selecciona una opción desde el menú lateral.</p>
            </div>

            <div className="dashboard-card">
              <h3>Estado del sistema</h3>
              <p>Frontend conectado al API Gateway.</p>
            </div>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}