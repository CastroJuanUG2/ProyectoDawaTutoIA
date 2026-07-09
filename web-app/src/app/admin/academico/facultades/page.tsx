import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { FacultadesList } from "@/components/academico/FacultadesList";

export default function FacultadesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Facultades"
            description="Listado de facultades registradas en el sistema académico."
          />

          <FacultadesList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}