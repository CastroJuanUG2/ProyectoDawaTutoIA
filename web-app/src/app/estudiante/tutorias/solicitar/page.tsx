"use client";

import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { SolicitudTutoriaForm } from "@/components/tutorias/SolicitudTutoriaForm";

export default function SolicitarTutoriaPage() {
  return (
    <ProtectedLayout allowedRoles={["ESTUDIANTE"]}>
      <AppShell>
        <section className="page-section">
          <h2>Solicitar tutoría</h2>
          <p>
            Registra una solicitud de tutoría académica indicando la asignatura,
            el tema de consulta y tu horario preferido.
          </p>

          <SolicitudTutoriaForm />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}