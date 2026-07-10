import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function FacultadesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <span className="section-label">Módulo pausado</span>
          <h2>Facultades</h2>
          <p>
            Modulo de facultades
          </p>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}