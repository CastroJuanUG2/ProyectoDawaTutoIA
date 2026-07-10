import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { AppShell } from "@/components/layout/AppShell";
import { ChatBox } from "@/components/ia/ChatBox";

export default function IAChatPage() {
  return (
    <ProtectedLayout
      allowedRoles={["ADMIN", "COORDINADOR", "DOCENTE", "ESTUDIANTE"]}
    >
      <AppShell>
        <section className="page-section">
          <div className="academic-page-header">
            <div>
              <span className="section-label">Agente de IA</span>
              <h2>Chat académico inteligente</h2>
              <p>
                Consulta información académica, solicita orientación inicial y
                recibe apoyo para clasificar necesidades de tutoría.
              </p>
            </div>
          </div>

          <ChatBox />
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}