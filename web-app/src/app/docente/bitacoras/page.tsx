import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { BitacoraForm } from "@/components/tutorias/BitacoraForm";
import { BitacorasDocenteList } from "@/components/tutorias/BitacorasDocenteList";

export default function BitacorasDocentePage() {
  return (
    <ProtectedLayout allowedRoles={["DOCENTE"]}>
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Bitácoras de atención</span>
              <h2>Registro de bitácora docente</h2>
              <p>
                Registra observaciones, recomendaciones y asistencia del
                estudiante después de una tutoría académica.
              </p>
            </div>
          </div>

          <div className="two-column-layout">
            <div className="panel-card">
              <h3>Nueva bitácora</h3>
              <BitacoraForm />
            </div>

            <div className="panel-card">
              <h3>Bitácoras registradas</h3>
              <BitacorasDocenteList />
            </div>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}