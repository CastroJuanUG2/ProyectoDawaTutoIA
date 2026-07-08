"use client";

import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function EstudiantePage() {
  return (
    <ProtectedLayout allowedRoles={["ESTUDIANTE"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel estudiante</h2>
          <p>
            Desde este módulo el estudiante podrá solicitar tutorías, consultar
            el estado de sus solicitudes y revisar su historial académico.
          </p>

          <div className="dashboard-grid">
            <div className="dashboard-card">
              <h3>Solicitar tutoría</h3>
              <p>Registra una nueva solicitud según asignatura y tema.</p>
            </div>

            <div className="dashboard-card">
              <h3>Historial</h3>
              <p>Consulta las tutorías solicitadas y atendidas.</p>
            </div>

            <div className="dashboard-card">
              <h3>Agente de IA</h3>
              <p>Recibe orientación inicial antes de crear una solicitud.</p>
            </div>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}