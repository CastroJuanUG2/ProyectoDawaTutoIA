import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { HorariosDocenteList } from "@/components/academico/HorariosDocenteList";

export default function HorariosPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Horarios de atención docente"
            description="Consulta los horarios disponibles de un docente registrado."
          />

          <HorariosDocenteList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}