import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function EstudiantesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <span className="section-label">Módulo pausado</span>
          <h2>Estudiantes</h2>
          <p>
                Módulo de acceso a estudiantes
          </p>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}