import type { Metadata } from "next";
import "./globals.css";
import { AuthProvider } from "@/context/AuthContext";

export const metadata: Metadata = {
  title: "Sistema de Tutorías Académicas IA",
  description:
    "Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es">
      <body>
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}