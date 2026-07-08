"use client";

import { useAuth } from "@/context/AuthContext";

export function AppHeader() {
  const { user, logout } = useAuth();

  return (
    <header className="app-header">
      <div>
        <h1>Sistema de Tutorías Académicas IA</h1>
        <p>
          {user
            ? `${user.nombres} ${user.apellidos} · ${user.roles.join(", ")}`
            : "Usuario no identificado"}
        </p>
      </div>

      <button type="button" className="logout-button" onClick={logout}>
        Cerrar sesión
      </button>
    </header>
  );
}