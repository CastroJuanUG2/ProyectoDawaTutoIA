"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { UserRole } from "@/types/auth.types";
import { APP_ROUTES } from "@/lib/utils/constants";

interface MenuItem {
  label: string;
  href: string;
  roles: UserRole[];
}

const MENU_ITEMS: MenuItem[] = [
  {
    label: "Dashboard",
    href: APP_ROUTES.DASHBOARD,
    roles: ["ADMIN", "COORDINADOR", "DOCENTE", "ESTUDIANTE"],
  },
  {
    label: "Administración",
    href: APP_ROUTES.ADMIN,
    roles: ["ADMIN", "COORDINADOR"],
  },
  {
    label: "Usuarios",
    href: APP_ROUTES.ADMIN_USUARIOS,
    roles: ["ADMIN"],
  },
  {
    label: "Roles",
    href: APP_ROUTES.ADMIN_ROLES,
    roles: ["ADMIN"],
  },
  {
    label: "Académico",
    href: APP_ROUTES.ADMIN_ACADEMICO,
    roles: ["ADMIN", "COORDINADOR"],
  },
  {
    label: "Solicitar tutoría",
    href: APP_ROUTES.ESTUDIANTE_SOLICITAR_TUTORIA,
    roles: ["ESTUDIANTE"],
  },
  {
    label: "Historial de tutorías",
    href: APP_ROUTES.ESTUDIANTE_HISTORIAL,
    roles: ["ESTUDIANTE"],
  },
  {
    label: "Solicitudes asignadas",
    href: APP_ROUTES.DOCENTE_SOLICITUDES,
    roles: ["DOCENTE"],
  },
  {
    label: "Bitácoras",
    href: APP_ROUTES.DOCENTE_BITACORAS,
    roles: ["DOCENTE"],
  },
  {
    label: "Chat IA",
    href: APP_ROUTES.IA_CHAT,
    roles: ["ADMIN", "COORDINADOR", "DOCENTE", "ESTUDIANTE"],
  },
  {
    label: "Reportes",
    href: APP_ROUTES.REPORTES,
    roles: ["ADMIN", "COORDINADOR"],
  },
];

export function AppSidebar() {
  const pathname = usePathname();
  const { user } = useAuth();

  const [visibleItems, setVisibleItems] = useState<MenuItem[]>([]);

  useEffect(() => {
    if (!user) {
      setVisibleItems([]);
      return;
    }

    const filteredItems = MENU_ITEMS.filter((item) =>
      item.roles.some((role) => user.roles.includes(role))
    );

    setVisibleItems(filteredItems);
  }, [user]);

  return (
    <aside className="app-sidebar">
      <div className="sidebar-brand">
        <span>UG</span>
        <div>
          <strong>Tutorías IA</strong>
          <small>Frontend</small>
        </div>
      </div>

      <nav className="sidebar-nav">
        {visibleItems.map((item) => {
          const isActive = pathname === item.href;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`sidebar-link ${isActive ? "active" : ""}`}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}