import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { APP_ROUTES } from "@/lib/utils/constants";

const academicModules = [
  {
    title: "Carreras",
    description: "Consulta las carreras académicas disponibles.",
    href: APP_ROUTES.ADMIN_CARRERAS,
  },
  {
    title: "Asignaturas",
    description: "Consulta las asignaturas registradas en el sistema.",
    href: APP_ROUTES.ADMIN_ASIGNATURAS,
  },
  {
    title: "Docentes",
    description: "Consulta los docentes registrados para tutorías.",
    href: APP_ROUTES.ADMIN_DOCENTES,
  },
  {
    title: "Horarios",
    description: "Consulta y registra horarios de atención docente.",
    href: APP_ROUTES.ADMIN_HORARIOS,
  },
];

export default function AcademicoPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Administración académica</h2>
          <p>
            Módulo académico.
          </p>

          <div className="module-grid">
            {academicModules.map((module) => (
              <Link
                key={module.href}
                href={module.href}
                className="module-card"
              >
                <h3>{module.title}</h3>
                <p>{module.description}</p>
              </Link>
            ))}
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}