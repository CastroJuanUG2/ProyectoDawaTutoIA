import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function AdminPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel administrativo</h2>
          <p>
            Desde este módulo se administran usuarios, roles, información
            académica, reportes y configuración general del sistema.
          </p>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}