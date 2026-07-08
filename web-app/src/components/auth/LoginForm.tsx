"use client";

import { FormEvent, useState } from "react";
import { useAuth } from "@/context/AuthContext";

export function LoginForm() {
  const { login, isLoading } = useAuth();

  const [correo, setCorreo] = useState("");
  const [password, setPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState("");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setErrorMessage("");

    if (!correo.trim() || !password.trim()) {
      setErrorMessage("Ingresa tu correo y contraseña.");
      return;
    }

    try {
      await login({
        correo,
        password,
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Error inesperado";

      setErrorMessage("No se puedo ingresar, vuelva a intentarlo de nuevo COD_ERROR " +message);
    }
  }

  return (
    <form className="login-card" onSubmit={handleSubmit}>
      <div className="login-header">
        <h1>Inicio de sesión</h1>
        <p>Sistema de Tutorías Académicas con Agente de IA</p>
      </div>

      <div className="form-group">
        <label htmlFor="correo">Correo institucional</label>
        <input
          id="correo"
          type="email"
          value={correo}
          onChange={(event) => setCorreo(event.target.value)}
          placeholder="usuario@ug.edu.ec"
          autoComplete="email"
        />
      </div>

      <div className="form-group">
        <label htmlFor="password">Contraseña</label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Ingresa tu contraseña"
          autoComplete="current-password"
        />
      </div>

      {errorMessage && (
        <div className="error-message">
          {errorMessage}
        </div>
      )}

      <button type="submit" disabled={isLoading}>
        {isLoading ? "Ingresando..." : "Ingresar"}
      </button>
    </form>
  );
}