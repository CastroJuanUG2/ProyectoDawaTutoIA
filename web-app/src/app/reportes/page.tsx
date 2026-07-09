import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { ReportesDashboard } from "@/components/dashboard/ReportesDashboard";

export default function ReportesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Reportes académicos</span>
              <h2>Dashboard administrativo</h2>
              <p>
                Visualiza indicadores sobre solicitudes, tutorías atendidas,
                carga docente, estudiantes atendidos y uso del agente de IA.
              </p>
            </div>
          </div>

          <ReportesDashboard />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}