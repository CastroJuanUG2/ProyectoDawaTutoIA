import Link from "next/link";

export default function HomePage() {
  return (
    <main className="home-page">
      <section className="home-card">
        <h1>Sistema de Tutorías Académicas IA</h1>
        <p>
          Plataforma web para gestionar tutorías académicas, solicitudes
          estudiantiles y orientación inicial mediante agente de IA.
        </p>

        <Link href="/login" className="home-link">
          Ir al inicio de sesión
        </Link>
      </section>
    </main>
  );
}