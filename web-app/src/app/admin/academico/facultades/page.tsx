"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { academicoApi } from "@/lib/api/academico.api";
import { Facultad } from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export default function FacultadesPage() {
  const [facultades, setFacultades] = useState<Facultad[]>([]);
  const [nombre, setNombre] = useState("");
  const [codigo, setCodigo] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    cargarFacultades();
  }, []);

  async function cargarFacultades() {
    setIsLoading(true);
    setErrorMessage("");

    try {
      const response = await academicoApi.listarFacultades();
      setFacultades(response.data);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      if (apiError?.trace_id) {
        logApiTrace(apiError);
      }

      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsLoading(false);
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!nombre.trim() || !codigo.trim()) {
      setErrorMessage("Completa el nombre y el código de la facultad.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      await academicoApi.crearFacultad({
        nombre,
        codigo,
      });

      setNombre("");
      setCodigo("");

      await cargarFacultades();
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      if (apiError?.trace_id) {
        logApiTrace(apiError);
      }

      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Facultades</h2>
          <p>Registro y consulta de facultades académicas.</p>

          <form className="form-card" onSubmit={handleSubmit}>
            <h3>Nueva facultad</h3>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="nombre">Nombre</label>
                <input
                  id="nombre"
                  value={nombre}
                  onChange={(event) => setNombre(event.target.value)}
                  placeholder="Facultad de Ciencias Matemáticas y Físicas"
                />
              </div>

              <div className="form-group">
                <label htmlFor="codigo">Código</label>
                <input
                  id="codigo"
                  value={codigo}
                  onChange={(event) => setCodigo(event.target.value)}
                  placeholder="FCMF"
                />
              </div>
            </div>

            {errorMessage && <div className="error-message">{errorMessage}</div>}

            <button type="submit" disabled={isSaving}>
              {isSaving ? "Guardando..." : "Guardar facultad"}
            </button>
          </form>

          <div className="table-card">
            <h3>Facultades registradas</h3>

            {isLoading ? (
              <p>Cargando facultades...</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {facultades.map((facultad) => (
                    <tr key={facultad.id_facultad}>
                      <td>{facultad.id_facultad}</td>
                      <td>{facultad.codigo}</td>
                      <td>{facultad.nombre}</td>
                      <td>{facultad.activo ? "Activo" : "Inactivo"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </section>
      </AppShell>
    </ProtectedLayout>
  );
}