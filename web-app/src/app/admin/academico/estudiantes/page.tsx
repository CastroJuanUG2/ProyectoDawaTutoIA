import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { EstudiantesList } from "@/components/academico/EstudiantesList";

export default function EstudiantesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Estudiantes"
            description="Listado de estudiantes registrados dentro del sistema."
          />

          <EstudiantesList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}