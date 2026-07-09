"use client";

import Link from "next/link";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function AcademicoPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Administración académica</h2>
          <p>
            Desde este módulo se administran las facultades, carreras,
            asignaturas, docentes, estudiantes y horarios de atención.
          </p>

          <div className="dashboard-grid">
            <Link className="dashboard-card module-link" href="/admin/academico/facultades">
              <h3>Facultades</h3>
              <p>Registrar y consultar facultades académicas.</p>
            </Link>

            <Link className="dashboard-card module-link" href="/admin/academico/carreras">
              <h3>Carreras</h3>
              <p>Gestionar carreras vinculadas a una facultad.</p>
            </Link>

            <Link className="dashboard-card module-link" href="/admin/academico/asignaturas">
              <h3>Asignaturas</h3>
              <p>Administrar asignaturas por carrera y nivel.</p>
            </Link>

            <Link className="dashboard-card module-link" href="/admin/academico/docentes">
              <h3>Docentes</h3>
              <p>Consultar docentes registrados en el sistema.</p>
            </Link>

            <Link className="dashboard-card module-link" href="/admin/academico/estudiantes">
              <h3>Estudiantes</h3>
              <p>Consultar estudiantes registrados.</p>
            </Link>

            <Link className="dashboard-card module-link" href="/admin/academico/horarios">
              <h3>Horarios</h3>
              <p>Revisar horarios de atención docente.</p>
            </Link>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}