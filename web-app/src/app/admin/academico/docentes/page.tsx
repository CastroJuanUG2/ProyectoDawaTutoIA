import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { DocentesList } from "@/components/academico/DocentesList";

export default function DocentesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Docentes"
            description="Listado de docentes registrados para la atención académica."
          />

          <DocentesList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}