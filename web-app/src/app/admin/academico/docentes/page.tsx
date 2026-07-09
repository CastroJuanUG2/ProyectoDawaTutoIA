"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { academicoApi } from "@/lib/api/academico.api";
import { usuariosApi } from "@/lib/api/usuarios.api";
import { Docente } from "@/types/academico.types";
import { Usuario } from "@/types/usuario.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export default function DocentesPage() {
  const [docentes, setDocentes] = useState<Docente[]>([]);
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);

  const [idUsuario, setIdUsuario] = useState("");
  const [especialidad, setEspecialidad] = useState("");

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    cargarDatos();
  }, []);

  async function cargarDatos() {
    setIsLoading(true);
    setErrorMessage("");

    try {
      const [docentesResponse, usuariosResponse] = await Promise.all([
        academicoApi.listarDocentes(),
        usuariosApi.listar(),
      ]);

      setDocentes(docentesResponse.data);

      const usuariosDocentes = usuariosResponse.data.filter((usuario) =>
        usuario.roles.includes("DOCENTE")
      );

      setUsuarios(usuariosDocentes);
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

    if (!idUsuario) {
      setErrorMessage("Selecciona un usuario con rol DOCENTE.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      await academicoApi.crearDocente({
        id_usuario: Number(idUsuario),
        especialidad: especialidad.trim() || undefined,
      });

      setIdUsuario("");
      setEspecialidad("");

      await cargarDatos();
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
          <h2>Docentes</h2>
          <p>Registro y consulta de docentes académicos.</p>

          <form className="form-card" onSubmit={handleSubmit}>
            <h3>Nuevo docente</h3>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="usuario">Usuario</label>
                <select
                  id="usuario"
                  value={idUsuario}
                  onChange={(event) => setIdUsuario(event.target.value)}
                >
                  <option value="">Selecciona un usuario docente</option>
                  {usuarios.map((usuario) => (
                    <option key={usuario.id_usuario} value={usuario.id_usuario}>
                      {usuario.nombres} {usuario.apellidos} - {usuario.correo}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="especialidad">Especialidad</label>
                <input
                  id="especialidad"
                  value={especialidad}
                  onChange={(event) => setEspecialidad(event.target.value)}
                  placeholder="Programación, Base de Datos, Redes..."
                />
              </div>
            </div>

            {errorMessage && <div className="error-message">{errorMessage}</div>}

            <button type="submit" disabled={isSaving}>
              {isSaving ? "Guardando..." : "Guardar docente"}
            </button>
          </form>

          <div className="table-card">
            <h3>Docentes registrados</h3>

            {isLoading ? (
              <p>Cargando docentes...</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Docente</th>
                    <th>Correo</th>
                    <th>Especialidad</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {docentes.map((docente) => (
                    <tr key={docente.id_docente}>
                      <td>{docente.id_docente}</td>
                      <td>
                        {docente.nombres} {docente.apellidos}
                      </td>
                      <td>{docente.correo}</td>
                      <td>{docente.especialidad || "No registrada"}</td>
                      <td>{docente.activo ? "Activo" : "Inactivo"}</td>
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