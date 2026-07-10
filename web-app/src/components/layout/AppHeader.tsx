"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { APP_ROUTES } from "@/lib/utils/constants";
import { NotificationsDropdown } from "@/components/layout/NotificationsDropdown";

export function AppHeader() {
  const router = useRouter();
  const { user, logout } = useAuth();

  const [isLoggingOut, setIsLoggingOut] = useState(false);

  async function handleLogout() {
    try {
      setIsLoggingOut(true);
      await logout();
      router.replace(APP_ROUTES.LOGIN);
    } finally {
      setIsLoggingOut(false);
    }
  }

  return (
    <header className="app-header">
      <div>
        <h1>DAWA Tutorías IA</h1>
        <p>Primer prototipo funcional del sistema académico.</p>
      </div>

      <div className="app-header-actions">
        <NotificationsDropdown />

        <div className="app-header-user">
          <div>
            <strong>
              {user?.nombres} {user?.apellidos}
            </strong>
            <span>{user?.roles.join(" · ")}</span>
          </div>

          <button
            type="button"
            className="logout-button"
            onClick={handleLogout}
            disabled={isLoggingOut}
          >
            {isLoggingOut ? "Saliendo..." : "Cerrar sesión"}
          </button>
        </div>
      </div>
    </header>
  );
}