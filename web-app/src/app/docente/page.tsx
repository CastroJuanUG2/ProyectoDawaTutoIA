"use client";

import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function DocentePage() {
  return (
    <ProtectedLayout allowedRoles={["DOCENTE"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel docente</h2>
          <p>
            Desde este módulo el docente podrá revisar solicitudes, atender
            tutorías y registrar bitácoras de atención.
          </p>

          <div className="dashboard-grid">
            <div className="dashboard-card">
              <h3>Solicitudes pendientes</h3>
              <p>Consulta las solicitudes asignadas o disponibles.</p>
            </div>

            <div className="dashboard-card">
              <h3>Atención de tutorías</h3>
              <p>Confirma, atiende o cancela tutorías según corresponda.</p>
            </div>

            <div className="dashboard-card">
              <h3>Bitácoras</h3>
              <p>Registra observaciones y recomendaciones académicas.</p>
            </div>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}