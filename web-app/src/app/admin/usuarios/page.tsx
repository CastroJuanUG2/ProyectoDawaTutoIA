import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { APP_ROUTES } from "@/lib/utils/constants";

export default function UsuariosPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN"]}>
      <AppShell>
        <section className="page-section">
          <span className="section-label">Módulo pausado</span>
          <h2>Usuarios fuera del MVP</h2>
          <p>
            La gestión de usuarios no se trabajará en el primer prototipo porque
            no está dentro de los endpoints mínimos definidos.
          </p>

          <Link href={APP_ROUTES.ADMIN} className="module-card">
            Volver a administración
          </Link>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}