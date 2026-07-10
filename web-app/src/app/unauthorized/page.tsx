import Link from "next/link";
import { APP_ROUTES } from "@/lib/utils/constants";

export default function UnauthorizedPage() {
  return (
    <main className="unauthorized-page">
      <div className="unauthorized-card">
        <h1>Acceso no autorizado</h1>
        <p>No tienes permisos para acceder a esta sección del sistema.</p>
        <Link href={APP_ROUTES.DASHBOARD}>Volver al dashboard</Link>
      </div>
    </main>
  );
}