import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function EstudiantePage() {
  return (
    <ProtectedLayout allowedRoles={["ESTUDIANTE"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel del estudiante</h2>
          <p>
            Aquí podrás solicitar tutorías, revisar el estado de tus solicitudes
            y consultar el historial de atención académica.
          </p>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}