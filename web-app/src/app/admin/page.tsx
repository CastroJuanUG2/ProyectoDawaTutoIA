import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { APP_ROUTES } from "@/lib/utils/constants";

export default function AdminPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel administrativo</h2>
          <p>
            Desde este módulo se gestionan los flujos académicos principales del
            primer prototipo funcional.
          </p>

          <div className="module-grid">
            <Link href={APP_ROUTES.ADMIN_ACADEMICO} className="module-card">
              <h3>Administración académica</h3>
              <p>Carreras, asignaturas, docentes y horarios.</p>
            </Link>

            <Link
              href={APP_ROUTES.ADMIN_ASIGNAR_TUTORIA}
              className="module-card"
            >
              <h3>Asignar tutoría</h3>
              <p>
                Validar disponibilidad, sugerir docente con IA y crear tutoría.
              </p>
            </Link>

            <Link href={APP_ROUTES.IA_CHAT} className="module-card">
              <h3>Chat IA</h3>
              <p>Consultar orientación académica mediante el agente de IA.</p>
            </Link>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}