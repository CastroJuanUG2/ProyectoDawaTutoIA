import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { AsignaturasList } from "@/components/academico/AsignaturasList";

export default function AsignaturasPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Asignaturas"
            description="Listado de asignaturas disponibles dentro del sistema."
          />

          <AsignaturasList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}