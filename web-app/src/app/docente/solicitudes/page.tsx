import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { SolicitudesDocenteList } from "@/components/tutorias/SolicitudesDocenteList";

export default function SolicitudesDocentePage() {
  return (
    <ProtectedLayout allowedRoles={["DOCENTE"]}>
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Atención docente</span>
              <h2>Solicitudes asignadas</h2>
              <p>
                Revisa las tutorías asignadas, confirma la atención, registra
                cambios de estado o cancela cuando corresponda.
              </p>
            </div>
          </div>

          <SolicitudesDocenteList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}