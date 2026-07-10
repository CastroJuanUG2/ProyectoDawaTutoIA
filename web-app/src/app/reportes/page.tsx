import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { APP_ROUTES } from "@/lib/utils/constants";

export default function ReportesPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <span className="section-label">Módulo pausado</span>
          <h2>Reportes fuera del MVP</h2>
          <p>
            El módulo de reportes no forma parte de los endpoints mínimos del
            primer prototipo funcional. Por ahora queda pausado.
          </p>

          <Link href={APP_ROUTES.DASHBOARD} className="module-card">
            Volver al dashboard
          </Link>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}