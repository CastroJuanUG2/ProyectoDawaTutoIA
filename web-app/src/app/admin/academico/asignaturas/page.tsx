"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { academicoApi } from "@/lib/api/academico.api";
import { Asignatura, Carrera } from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export default function AsignaturasPage() {
  const [asignaturas, setAsignaturas] = useState<Asignatura[]>([]);
  const [carreras, setCarreras] = useState<Carrera[]>([]);

  const [idCarrera, setIdCarrera] = useState("");
  const [nombre, setNombre] = useState("");
  const [codigo, setCodigo] = useState("");
  const [nivel, setNivel] = useState("");

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
      const [carrerasResponse, asignaturasResponse] = await Promise.all([
        academicoApi.listarCarreras(),
        academicoApi.listarAsignaturas(),
      ]);

      setCarreras(carrerasResponse.data);
      setAsignaturas(asignaturasResponse.data);
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

    if (!idCarrera || !nombre.trim() || !codigo.trim() || !nivel.trim()) {
      setErrorMessage("Completa carrera, nombre, código y nivel.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      await academicoApi.crearAsignatura({
        id_carrera: Number(idCarrera),
        nombre,
        codigo,
        nivel,
      });

      setIdCarrera("");
      setNombre("");
      setCodigo("");
      setNivel("");

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
          <h2>Asignaturas</h2>
          <p>Registro y consulta de asignaturas por carrera.</p>

          <form className="form-card" onSubmit={handleSubmit}>
            <h3>Nueva asignatura</h3>

            <div className="form-grid">
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
                <label htmlFor="nombre">Nombre</label>
                <input
                  id="nombre"
                  value={nombre}
                  onChange={(event) => setNombre(event.target.value)}
                  placeholder="Desarrollo de Aplicaciones Web"
                />
              </div>

              <div className="form-group">
                <label htmlFor="codigo">Código</label>
                <input
                  id="codigo"
                  value={codigo}
                  onChange={(event) => setCodigo(event.target.value)}
                  placeholder="DAWA"
                />
              </div>

              <div className="form-group">
                <label htmlFor="nivel">Nivel</label>
                <input
                  id="nivel"
                  value={nivel}
                  onChange={(event) => setNivel(event.target.value)}
                  placeholder="7"
                />
              </div>
            </div>

            {errorMessage && <div className="error-message">{errorMessage}</div>}

            <button type="submit" disabled={isSaving}>
              {isSaving ? "Guardando..." : "Guardar asignatura"}
            </button>
          </form>

          <div className="table-card">
            <h3>Asignaturas registradas</h3>

            {isLoading ? (
              <p>Cargando asignaturas...</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Carrera</th>
                    <th>Nivel</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {asignaturas.map((asignatura) => (
                    <tr key={asignatura.id_asignatura}>
                      <td>{asignatura.id_asignatura}</td>
                      <td>{asignatura.codigo}</td>
                      <td>{asignatura.nombre}</td>
                      <td>{obtenerNombreCarrera(asignatura.id_carrera)}</td>
                      <td>{asignatura.nivel}</td>
                      <td>{asignatura.activo ? "Activo" : "Inactivo"}</td>
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