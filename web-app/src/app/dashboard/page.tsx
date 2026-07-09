import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function DashboardPage() {
  return (
    <ProtectedLayout>
      <AppShell>
        <section className="page-section">
          <h2>Dashboard principal</h2>
          <p>
            Bienvenido al panel principal del Sistema Web Inteligente de Gestión
            de Tutorías Académicas con Agente de IA.
          </p>

          <div className="dashboard-grid">
            <article className="dashboard-card">
              <h3>Tutorías</h3>
              <p>Consulta solicitudes, estados e historial académico.</p>
            </article>

            <article className="dashboard-card">
              <h3>Agente IA</h3>
              <p>Accede al chat académico para orientación inicial.</p>
            </article>

            <article className="dashboard-card">
              <h3>Seguimiento</h3>
              <p>Revisa bitácoras, reportes y trazabilidad del sistema.</p>
            </article>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}