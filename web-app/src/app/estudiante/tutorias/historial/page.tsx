import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { HistorialTutoriasList } from "@/components/tutorias/HistorialTutoriasList";

export default function HistorialTutoriasPage() {
  return (
    <ProtectedLayout allowedRoles={["ESTUDIANTE"]}>
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Tutorías académicas</span>
              <h2>Historial de tutorías</h2>
              <p>
                Consulta las tutorías registradas, sus horarios, estados y
                seguimiento académico.
              </p>
            </div>
          </div>

          <HistorialTutoriasList />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}