import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function DocentePage() {
  return (
    <ProtectedLayout allowedRoles={["DOCENTE"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel del docente</h2>
          <p>
            Aquí podrás revisar solicitudes asignadas, atender tutorías y
            registrar bitácoras de seguimiento académico.
          </p>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}