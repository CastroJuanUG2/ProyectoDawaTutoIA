import { LoginForm } from "@/components/auth/LoginForm";

export default function LoginPage() {
  return (
    <main className="login-page">
      <section className="login-content">
        <div className="login-info">
          <span className="login-badge">DAWA · Proyecto Final</span>
          <h2>Gestión inteligente de tutorías académicas</h2>
          <p>
            Plataforma web para estudiantes, docentes, coordinadores y
            administradores, con apoyo de un agente de IA integrado al flujo
            académico.
          </p>
        </div>

        <LoginForm />
      </section>
    </main>
  );
}