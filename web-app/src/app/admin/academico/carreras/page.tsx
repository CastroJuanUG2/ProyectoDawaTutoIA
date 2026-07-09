import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { CarrerasList } from "@/components/academico/CarrerasList";

export default function CarrerasPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Carreras"
            description="Listado de carreras académicas registradas por facultad."
          />

          <CarrerasList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}