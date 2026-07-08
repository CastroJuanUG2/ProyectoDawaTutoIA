"use client";

import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";

export default function AdminPage() {
  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Panel administrativo</h2>
          <p>
            Módulo para supervisar usuarios, roles, administración académica,
            tutorías y reportes generales.
          </p>

          <div className="dashboard-grid">
            <div className="dashboard-card">
              <h3>Usuarios y roles</h3>
              <p>Gestión de accesos y permisos del sistema.</p>
            </div>

            <div className="dashboard-card">
              <h3>Administración académica</h3>
              <p>Facultades, carreras, asignaturas, docentes y estudiantes.</p>
            </div>

            <div className="dashboard-card">
              <h3>Reportes</h3>
              <p>Estadísticas de tutorías y carga académica.</p>
            </div>
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}