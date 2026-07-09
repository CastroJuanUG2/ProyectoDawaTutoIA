"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/layout/AppShell";
import { ProtectedLayout } from "@/components/layout/ProtectedLayout";
import { academicoApi } from "@/lib/api/academico.api";
import {
  DiaSemana,
  Docente,
  HorarioDocente,
} from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

const DIAS_SEMANA: DiaSemana[] = [
  "LUNES",
  "MARTES",
  "MIERCOLES",
  "JUEVES",
  "VIERNES",
  "SABADO",
  "DOMINGO",
];

export default function HorariosPage() {
  const [horarios, setHorarios] = useState<HorarioDocente[]>([]);
  const [docentes, setDocentes] = useState<Docente[]>([]);

  const [idDocente, setIdDocente] = useState("");
  const [diaSemana, setDiaSemana] = useState<DiaSemana | "">("");
  const [horaInicio, setHoraInicio] = useState("");
  const [horaFin, setHoraFin] = useState("");

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
      const [horariosResponse, docentesResponse] = await Promise.all([
        academicoApi.listarHorarios(),
        academicoApi.listarDocentes(),
      ]);

      setHorarios(horariosResponse.data);
      setDocentes(docentesResponse.data);
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

    if (!idDocente || !diaSemana || !horaInicio || !horaFin) {
      setErrorMessage("Completa docente, día, hora de inicio y hora de fin.");
      return;
    }

    if (horaInicio >= horaFin) {
      setErrorMessage("La hora de inicio debe ser menor que la hora de fin.");
      return;
    }

    setIsSaving(true);
    setErrorMessage("");

    try {
      await academicoApi.crearHorarioDocente({
        id_docente: Number(idDocente),
        dia_semana: diaSemana,
        hora_inicio: horaInicio,
        hora_fin: horaFin,
      });

      setIdDocente("");
      setDiaSemana("");
      setHoraInicio("");
      setHoraFin("");

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

  function obtenerNombreDocente(id: number): string {
    const docente = docentes.find((item) => item.id_docente === id);

    if (!docente) {
      return "No asignado";
    }

    return `${docente.nombres} ${docente.apellidos}`;
  }

  return (
    <ProtectedLayout allowedRoles={["ADMIN", "COORDINADOR"]}>
      <AppShell>
        <section className="page-section">
          <h2>Horarios de atención</h2>
          <p>Parametrización de disponibilidad docente para tutorías.</p>

          <form className="form-card" onSubmit={handleSubmit}>
            <h3>Nuevo horario</h3>

            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="docente">Docente</label>
                <select
                  id="docente"
                  value={idDocente}
                  onChange={(event) => setIdDocente(event.target.value)}
                >
                  <option value="">Selecciona un docente</option>
                  {docentes.map((docente) => (
                    <option key={docente.id_docente} value={docente.id_docente}>
                      {docente.nombres} {docente.apellidos}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="dia">Día de atención</label>
                <select
                  id="dia"
                  value={diaSemana}
                  onChange={(event) =>
                    setDiaSemana(event.target.value as DiaSemana)
                  }
                >
                  <option value="">Selecciona un día</option>
                  {DIAS_SEMANA.map((dia) => (
                    <option key={dia} value={dia}>
                      {dia}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label htmlFor="horaInicio">Hora inicio</label>
                <input
                  id="horaInicio"
                  type="time"
                  value={horaInicio}
                  onChange={(event) => setHoraInicio(event.target.value)}
                />
              </div>

              <div className="form-group">
                <label htmlFor="horaFin">Hora fin</label>
                <input
                  id="horaFin"
                  type="time"
                  value={horaFin}
                  onChange={(event) => setHoraFin(event.target.value)}
                />
              </div>
            </div>

            {errorMessage && <div className="error-message">{errorMessage}</div>}

            <button type="submit" disabled={isSaving}>
              {isSaving ? "Guardando..." : "Guardar horario"}
            </button>
          </form>

          <div className="table-card">
            <h3>Horarios registrados</h3>

            {isLoading ? (
              <p>Cargando horarios...</p>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Docente</th>
                    <th>Día</th>
                    <th>Hora inicio</th>
                    <th>Hora fin</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {horarios.map((horario) => (
                    <tr key={horario.id_horario}>
                      <td>{horario.id_horario}</td>
                      <td>{obtenerNombreDocente(horario.id_docente)}</td>
                      <td>{horario.dia_semana}</td>
                      <td>{horario.hora_inicio}</td>
                      <td>{horario.hora_fin}</td>
                      <td>{horario.activo ? "Activo" : "Inactivo"}</td>
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