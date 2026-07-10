import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { APP_ROUTES } from "@/lib/utils/constants";

export default function RolesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN"]}>
      <AppShell>
        <section className="page-section">
          <span className="section-label">Módulo pausado</span>
          <h2>Roles fuera del MVP</h2>
          <p>
            La gestión de roles queda pausada porque no forma parte de los
            endpoints mínimos del primer prototipo funcional.
          </p>

          <Link href={APP_ROUTES.ADMIN} className="module-card">
            Volver a administración
          </Link>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}