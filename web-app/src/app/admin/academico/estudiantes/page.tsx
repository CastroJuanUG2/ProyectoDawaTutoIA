"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { academicoApi } from "@/lib/api/academico.api";
import { usuariosApi } from "@/lib/api/usuarios.api";
import { Carrera, Estudiante } from "@/types/academico.types";
import { Usuario } from "@/types/usuario.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export default function EstudiantesPage() {
  const [estudiantes, setEstudiantes] = useState<Estudiante[]>([]);
  const [usuarios, setUsuarios] = useState<Usuario[]>([]);
  const [carreras, setCarreras] = useState<Carrera[]>([]);

  const [idUsuario, setIdUsuario] = useState("");
  const [idCarrera, setIdCarrera] = useState("");
  const [matricula, setMatricula] = useState("");

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
      const [estudiantesResponse, usuariosResponse, carrerasResponse] =
        await Promise.all([
          academicoApi.listarEstudiantes(),
          usuariosApi.listar(),
          academicoApi.listarCarreras(),
        ]);

      setEstudiantes(estudiantesResponse.data);
      setCarreras(carrerasResponse.data);

      const usuariosEstudiantes = usuariosResponse.data.filter((usuario) =>
        usuario.roles.includes("ESTUDIANTE")
      );

      setUsuarios(usuariosEstudiantes);
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

    if (!idUsuario || !idCarrera || !matricula.trim()) {
      setErrorMessage("Selecciona usuario, carrera y matrícula.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      await academicoApi.crearEstudiante({
        id_usuario: Number(idUsuario),
        id_carrera: Number(idCarrera),
        matricula,
      });

      setIdUsuario("");
      setIdCarrera("");
      setMatricula("");

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

  function obtenerNombreCarrera(id: number): string {
    return (
      carreras.find((carrera) => carrera.id_carrera === id)?.nombre ??
      "No asignada"
    );
  }

  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Estudiantes</h2>
          <p>Registro y consulta de estudiantes por carrera.</p>

          <form className="form-card" onSubmit={handleSubmit}>
            <h3>Nuevo estudiante</h3>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="usuario">Usuario</label>
                <select
                  id="usuario"
                  value={idUsuario}
                  onChange={(event) => setIdUsuario(event.target.value)}
                >
                  <option value="">Selecciona un usuario estudiante</option>
                  {usuarios.map((usuario) => (
                    <option key={usuario.id_usuario} value={usuario.id_usuario}>
                      {usuario.nombres} {usuario.apellidos} - {usuario.correo}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="carrera">Carrera</label>
                <select
                  id="carrera"
                  value={idCarrera}
                  onChange={(event) => setIdCarrera(event.target.value)}
                >
                  <option value="">Selecciona una carrera</option>
                  {carreras.map((carrera) => (
                    <option key={carrera.id_carrera} value={carrera.id_carrera}>
                      {carrera.nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="matricula">Matrícula</label>
                <input
                  id="matricula"
                  value={matricula}
                  onChange={(event) => setMatricula(event.target.value)}
                  placeholder="2026-0001"
                />
              </div>
            </div>

            {errorMessage && <div className="error-message">{errorMessage}</div>}

            <button type="submit" disabled={isSaving}>
              {isSaving ? "Guardando..." : "Guardar estudiante"}
            </button>
          </form>

          <div className="table-card">
            <h3>Estudiantes registrados</h3>

            {isLoading ? (
              <p>Cargando estudiantes...</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Estudiante</th>
                    <th>Correo</th>
                    <th>Matrícula</th>
                    <th>Carrera</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {estudiantes.map((estudiante) => (
                    <tr key={estudiante.id_estudiante}>
                      <td>{estudiante.id_estudiante}</td>
                      <td>
                        {estudiante.nombres} {estudiante.apellidos}
                      </td>
                      <td>{estudiante.correo}</td>
                      <td>{estudiante.matricula}</td>
                      <td>{obtenerNombreCarrera(estudiante.id_carrera)}</td>
                      <td>{estudiante.activo ? "Activo" : "Inactivo"}</td>
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