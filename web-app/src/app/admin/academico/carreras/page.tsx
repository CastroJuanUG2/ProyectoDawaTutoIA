"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { academicoApi } from "@/lib/api/academico.api";
import { Carrera, Facultad } from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export default function CarrerasPage() {
  const [carreras, setCarreras] = useState<Carrera[]>([]);
  const [facultades, setFacultades] = useState<Facultad[]>([]);

  const [idFacultad, setIdFacultad] = useState("");
  const [nombre, setNombre] = useState("");
  const [codigo, setCodigo] = useState("");

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
      const [facultadesResponse, carrerasResponse] = await Promise.all([
        academicoApi.listarFacultades(),
        academicoApi.listarCarreras(),
      ]);

      setFacultades(facultadesResponse.data);
      setCarreras(carrerasResponse.data);
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

    if (!idFacultad || !nombre.trim() || !codigo.trim()) {
      setErrorMessage("Completa la facultad, el nombre y el código.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      await academicoApi.crearCarrera({
        id_facultad: Number(idFacultad),
        nombre,
        codigo,
      });

      setIdFacultad("");
      setNombre("");
      setCodigo("");

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

  function obtenerNombreFacultad(id: number): string {
    return (
      facultades.find((facultad) => facultad.id_facultad === id)?.nombre ??
      "No asignada"
    );
  }

  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Carreras</h2>
          <p>Registro y consulta de carreras por facultad.</p>

          <form className="form-card" onSubmit={handleSubmit}>
            <h3>Nueva carrera</h3>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="facultad">Facultad</label>
                <select
                  id="facultad"
                  value={idFacultad}
                  onChange={(event) => setIdFacultad(event.target.value)}
                >
                  <option value="">Selecciona una facultad</option>
                  {facultades.map((facultad) => (
                    <option
                      key={facultad.id_facultad}
                      value={facultad.id_facultad}
                    >
                      {facultad.nombre}
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
                  placeholder="Software"
                />
              </div>

              <div className="form-group">
                <label htmlFor="codigo">Código</label>
                <input
                  id="codigo"
                  value={codigo}
                  onChange={(event) => setCodigo(event.target.value)}
                  placeholder="SOFT"
                />
              </div>
            </div>

            {errorMessage && <div className="error-message">{errorMessage}</div>}

            <button type="submit" disabled={isSaving}>
              {isSaving ? "Guardando..." : "Guardar carrera"}
            </button>
          </form>

          <div className="table-card">
            <h3>Carreras registradas</h3>

            {isLoading ? (
              <p>Cargando carreras...</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Facultad</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {carreras.map((carrera) => (
                    <tr key={carrera.id_carrera}>
                      <td>{carrera.id_carrera}</td>
                      <td>{carrera.codigo}</td>
                      <td>{carrera.nombre}</td>
                      <td>{obtenerNombreFacultad(carrera.id_facultad)}</td>
                      <td>{carrera.activo ? "Activo" : "Inactivo"}</td>
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