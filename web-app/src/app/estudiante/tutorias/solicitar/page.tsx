import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { SolicitudTutoriaForm } from "@/components/tutorias/SolicitudTutoriaForm";
import { MisSolicitudesList } from "@/components/tutorias/MisSolicitudesList";

export default function SolicitarTutoriaPage() {
  return (
    <ProtectedLayout allowedRoles={["ESTUDIANTE"]}>
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Tutorías académicas</span>
              <h2>Solicitar tutoría</h2>
              <p>
                Registra una solicitud de tutoría indicando la asignatura, el
                tema y el horario preferido. La solicitud será revisada según la
                disponibilidad docente.
              </p>
            </div>
          </div>

          <div className="two-column-layout">
            <div className="panel-card">
              <h3>Nueva solicitud</h3>
              <SolicitudTutoriaForm />
            </div>

            <div className="panel-card">
              <h3>Mis solicitudes recientes</h3>
              <MisSolicitudesList />
            </div>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}