"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Card } from "@/components/ui/Card";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function LoginForm() {
  const router = useRouter();
  const { login } = useAuth();

  const [correo, setCorreo] = useState("");
  const [password, setPassword] = useState("");
  const [formError, setFormError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setFormError("");

    if (!correo.trim() || !password.trim()) {
      setFormError("Ingrese correo y contraseña.");
      return;
    }

    try {
      setIsSubmitting(true);

      const redirectTo = await login({
        correo,
        password,
      });

      router.push(redirectTo);
    } catch (error) {

      logApiTrace(error);
      setFormError(getApiErrorMessage(error));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <Card className="login-card">
      <div className="login-header">
        <h1>Sistema de Tutorías Académicas</h1>
        <p>Ingrese sus credenciales para acceder al sistema.</p>
      </div>

      <form onSubmit={handleSubmit} className="login-form">
        <Input
          label="Correo institucional"
          type="email"
          value={correo}
          onChange={(event) => setCorreo(event.target.value)}
          placeholder="usuario@ug.edu.ec"
          autoComplete="email"
        />

        <Input
          label="Contraseña"
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Ingrese su contraseña"
          autoComplete="current-password"
        />

        {formError && <div className="form-error">{formError}</div>}

        <Button type="submit" isLoading={isSubmitting}>
          Iniciar sesión
        </Button>
      </form>
    </Card>
  );
}