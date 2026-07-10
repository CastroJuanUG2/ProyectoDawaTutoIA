import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AsignarTutoriaManager } from "@/components/tutorias/AsignarTutoriaManager";

export default function AsignarTutoriaPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Tutorías académicas</span>
              <h2>Asignar tutoría</h2>
              <p>
                Valida disponibilidad docente, usa IA para clasificar la
                solicitud, sugiere un docente y crea la tutoría académica.
              </p>
            </div>
          </div>

          <AsignarTutoriaManager />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}