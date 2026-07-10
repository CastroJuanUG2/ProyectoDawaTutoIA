import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { AcademicPageHeader } from "@/components/academico/AcademicPageHeader";
import { HorariosManager } from "@/components/academico/HorariosManager";

export default function HorariosPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <AcademicPageHeader
            title="Horarios de atención docente"
            description="Consulta y registra horarios de disponibilidad para docentes tutores."
          />

          <HorariosManager />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}