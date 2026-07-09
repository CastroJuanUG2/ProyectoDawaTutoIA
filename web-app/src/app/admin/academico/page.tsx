import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

const academicModules = [
  {
    title: "Facultades",
    description: "Consulta y gestión de facultades registradas.",
    href: "/admin/academico/facultades",
  },
  {
    title: "Carreras",
    description: "Consulta y gestión de carreras académicas.",
    href: "/admin/academico/carreras",
  },
  {
    title: "Asignaturas",
    description: "Consulta y gestión de asignaturas por carrera.",
    href: "/admin/academico/asignaturas",
  },
  {
    title: "Docentes",
    description: "Consulta y gestión de docentes registrados.",
    href: "/admin/academico/docentes",
  },
  {
    title: "Estudiantes",
    description: "Consulta y gestión de estudiantes registrados.",
    href: "/admin/academico/estudiantes",
  },
  {
    title: "Horarios",
    description: "Consulta de horarios de atención docente.",
    href: "/admin/academico/horarios",
  },
];

export default function AcademicoPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Administración académica</h2>
          <p>
            Seleccione un módulo para consultar la información académica
            registrada en el sistema.
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