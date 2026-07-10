"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { iaApi } from "@/lib/api/ia.api";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { Docente } from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import {
  ClasificarSolicitudResponse,
  SugerirDocenteResponse,
} from "@/types/ia.types";
import {
  SolicitudTutoria,
  Tutoria,
  ValidarDisponibilidadResponse,
} from "@/types/tutoria.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { TutoriaEstadoBadge } from "@/components/tutorias/TutoriaEstadoBadge";

function sumarUnaHora(hora: string): string {
  if (!hora) return "";

  const [hours, minutes] = hora.split(":").map(Number);

  if (Number.isNaN(hours) || Number.isNaN(minutes)) {
    return "";
  }

  const date = new Date();
  date.setHours(hours + 1, minutes, 0, 0);

  return date.toTimeString().slice(0, 5);
}

export function AsignarTutoriaManager() {
  const [docentes, setDocentes] = useState<Docente[]>([]);
  const [solicitudes, setSolicitudes] = useState<SolicitudTutoria[]>([]);

  const [idEstudiante, setIdEstudiante] = useState("");
  const [idSolicitud, setIdSolicitud] = useState("");
  const [idDocente, setIdDocente] = useState("");
  const [fecha, setFecha] = useState("");
  const [horaInicio, setHoraInicio] = useState("");
  const [horaFin, setHoraFin] = useState("");

  const [clasificacion, setClasificacion] =
    useState<ClasificarSolicitudResponse | null>(null);
  const [sugerencia, setSugerencia] = useState<SugerirDocenteResponse | null>(
    null
  );
  const [disponibilidad, setDisponibilidad] =
    useState<ValidarDisponibilidadResponse | null>(null);
  const [tutoriaCreada, setTutoriaCreada] = useState<Tutoria | null>(null);

  const [isLoadingDocentes, setIsLoadingDocentes] = useState(true);
  const [isLoadingSolicitudes, setIsLoadingSolicitudes] = useState(false);
  const [isClassifying, setIsClassifying] = useState(false);
  const [isSuggesting, setIsSuggesting] = useState(false);
  const [isValidating, setIsValidating] = useState(false);
  const [isCreating, setIsCreating] = useState(false);

  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  const solicitudSeleccionada = useMemo(() => {
    return solicitudes.find(
      (solicitud) => solicitud.id_solicitud === Number(idSolicitud)
    );
  }, [solicitudes, idSolicitud]);

  useEffect(() => {
    async function loadDocentes() {
      try {
        setIsLoadingDocentes(true);
        setErrorMessage("");

        const response = await academicoApi.listarDocentes();
        setDocentes(response.data);
      } catch (error) {
        logApiTrace(error);
        setErrorMessage(getApiErrorMessage(error));
      } finally {
        setIsLoadingDocentes(false);
      }
    }

    loadDocentes();
  }, []);

  useEffect(() => {
    setClasificacion(null);
    setSugerencia(null);
    setDisponibilidad(null);
    setTutoriaCreada(null);
    setSuccessMessage("");

    if (!solicitudSeleccionada) {
      return;
    }

    if (solicitudSeleccionada.fecha_preferida) {
      setFecha(solicitudSeleccionada.fecha_preferida);
    }

    if (solicitudSeleccionada.hora_preferida) {
      setHoraInicio(solicitudSeleccionada.hora_preferida);
      setHoraFin(sumarUnaHora(solicitudSeleccionada.hora_preferida));
    }
  }, [solicitudSeleccionada]);

  async function handleBuscarSolicitudes(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setErrorMessage("");
    setSuccessMessage("");
    setSolicitudes([]);
    setIdSolicitud("");
    setClasificacion(null);
    setSugerencia(null);
    setDisponibilidad(null);
    setTutoriaCreada(null);

    if (!idEstudiante.trim()) {
      setErrorMessage("Ingrese el ID del estudiante.");
      return;
    }

    try {
      setIsLoadingSolicitudes(true);

      const response = await tutoriasApi.listarSolicitudesEstudiante(
        Number(idEstudiante)
      );

      setSolicitudes(response.data);
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setIsLoadingSolicitudes(false);
    }
  }

  async function handleClasificarSolicitud() {
    if (!solicitudSeleccionada) {
      setErrorMessage("Seleccione una solicitud para clasificar.");
      return;
    }

    try {
      setIsClassifying(true);
      setErrorMessage("");
      setSuccessMessage("");

      const response = await iaApi.clasificarSolicitud({
        mensaje: `${solicitudSeleccionada.tema}. ${solicitudSeleccionada.descripcion}`,
        id_asignatura: solicitudSeleccionada.id_asignatura,
      });

      setClasificacion(response.data);
      setSuccessMessage("Solicitud clasificada con IA correctamente.");
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setIsClassifying(false);
    }
  }

  async function handleSugerirDocente() {
    if (!solicitudSeleccionada) {
      setErrorMessage("Seleccione una solicitud para sugerir docente.");
      return;
    }

    try {
      setIsSuggesting(true);
      setErrorMessage("");
      setSuccessMessage("");

      const response = await iaApi.sugerirDocente({
        id_asignatura: solicitudSeleccionada.id_asignatura,
        fecha_preferida: fecha || solicitudSeleccionada.fecha_preferida,
        hora_preferida: horaInicio || solicitudSeleccionada.hora_preferida,
      });

      setSugerencia(response.data);
      setIdDocente(String(response.data.id_docente));
      setSuccessMessage("Docente sugerido por IA correctamente.");
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setIsSuggesting(false);
    }
  }

  async function handleValidarDisponibilidad() {
    if (!idDocente || !fecha || !horaInicio || !horaFin) {
      setErrorMessage(
        "Seleccione docente, fecha, hora de inicio y hora de fin."
      );
      return;
    }

    if (horaInicio >= horaFin) {
      setErrorMessage("La hora de inicio debe ser menor que la hora de fin.");
      return;
    }

    try {
      setIsValidating(true);
      setErrorMessage("");
      setSuccessMessage("");
      setDisponibilidad(null);

      const response = await tutoriasApi.validarDisponibilidad({
        id_docente: Number(idDocente),
        fecha,
        hora_inicio: horaInicio,
        hora_fin: horaFin,
      });

      setDisponibilidad(response.data);

      if (response.data.disponible) {
        setSuccessMessage("El docente tiene disponibilidad en ese horario.");
      } else {
        setErrorMessage(
          response.data.motivo || "El docente no está disponible en ese horario."
        );
      }
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setIsValidating(false);
    }
  }

  async function handleCrearTutoria() {
    if (!solicitudSeleccionada || !idDocente || !fecha || !horaInicio || !horaFin) {
      setErrorMessage("Complete la información para crear la tutoría.");
      return;
    }

    if (!disponibilidad?.disponible) {
      setErrorMessage(
        "Debe validar disponibilidad antes de crear la tutoría."
      );
      return;
    }

    try {
      setIsCreating(true);
      setErrorMessage("");
      setSuccessMessage("");

      const response = await tutoriasApi.crearTutoria({
        id_solicitud: solicitudSeleccionada.id_solicitud,
        id_docente: Number(idDocente),
        fecha,
        hora_inicio: horaInicio,
        hora_fin: horaFin,
      });

      setTutoriaCreada(response.data);
      setSuccessMessage("Tutoría creada correctamente.");
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setIsCreating(false);
    }
  }

  return (
    <div className="asignar-tutoria-manager">
      {errorMessage && <div className="form-error">{errorMessage}</div>}
      {successMessage && <div className="form-success">{successMessage}</div>}

      <div className="panel-card">
        <h3>Buscar solicitudes del estudiante</h3>

        <form className="filter-form" onSubmit={handleBuscarSolicitudes}>
          <Input
            label="ID del estudiante"
            type="number"
            value={idEstudiante}
            onChange={(event) => setIdEstudiante(event.target.value)}
            placeholder="Ejemplo: 1"
          />

          <Button type="submit" isLoading={isLoadingSolicitudes}>
            Buscar
          </Button>
        </form>
      </div>

      <div className="panel-card">
        <h3>Solicitudes encontradas</h3>

        {isLoadingSolicitudes ? (
          <p className="inline-loading">Cargando solicitudes...</p>
        ) : (
          <Table<SolicitudTutoria>
            data={solicitudes}
            emptyMessage="Ingrese un estudiante para consultar sus solicitudes."
            columns={[
              { header: "ID", accessor: "id_solicitud" },
              { header: "Asignatura", accessor: "id_asignatura" },
              { header: "Tema", accessor: "tema" },
              {
                header: "Estado",
                accessor: (row) => <TutoriaEstadoBadge estado={row.estado} />,
              },
              {
                header: "Acción",
                accessor: (row) => (
                  <button
                    type="button"
                    className="table-select-button"
                    onClick={() => setIdSolicitud(String(row.id_solicitud))}
                  >
                    Seleccionar
                  </button>
                ),
              },
            ]}
          />
        )}
      </div>

      {solicitudSeleccionada && (
        <div className="two-column-layout">
          <div className="panel-card">
            <h3>Solicitud seleccionada</h3>

            <div className="selected-request">
              <p>
                <strong>ID:</strong> {solicitudSeleccionada.id_solicitud}
              </p>
              <p>
                <strong>Tema:</strong> {solicitudSeleccionada.tema}
              </p>
              <p>
                <strong>Descripción:</strong>{" "}
                {solicitudSeleccionada.descripcion}
              </p>
              <p>
                <strong>Asignatura:</strong>{" "}
                {solicitudSeleccionada.id_asignatura}
              </p>
            </div>

            <div className="action-stack">
              <Button
                type="button"
                onClick={handleClasificarSolicitud}
                isLoading={isClassifying}
              >
                Clasificar con IA
              </Button>

              <Button
                type="button"
                onClick={handleSugerirDocente}
                isLoading={isSuggesting}
              >
                Sugerir docente con IA
              </Button>
            </div>

            {clasificacion && (
              <div className="result-box">
                <h4>Clasificación IA</h4>
                <p>
                  <strong>Categoría:</strong> {clasificacion.categoria}
                </p>
                <p>
                  <strong>Prioridad:</strong> {clasificacion.prioridad}
                </p>
                <p>
                  <strong>Escalamiento:</strong>{" "}
                  {clasificacion.requiere_escalamiento ? "Sí" : "No"}
                </p>
              </div>
            )}

            {sugerencia && (
              <div className="result-box">
                <h4>Docente sugerido</h4>
                <p>
                  <strong>Docente:</strong> {sugerencia.docente}
                </p>
                <p>
                  <strong>Motivo:</strong> {sugerencia.motivo}
                </p>
                <p>
                  <strong>Disponible según IA:</strong>{" "}
                  {sugerencia.disponible ? "Sí" : "No"}
                </p>
              </div>
            )}
          </div>

          <div className="panel-card">
            <h3>Asignar tutoría</h3>

            <div className="tutoria-form">
              <div className="input-group">
                <label className="input-label">Docente</label>

                <select
                  className="app-input"
                  value={idDocente}
                  onChange={(event) => {
                    setIdDocente(event.target.value);
                    setDisponibilidad(null);
                  }}
                  disabled={isLoadingDocentes}
                >
                  <option value="">
                    {isLoadingDocentes
                      ? "Cargando docentes..."
                      : "Seleccione un docente"}
                  </option>

                  {docentes.map((docente) => (
                    <option
                      key={docente.id_docente}
                      value={docente.id_docente}
                    >
                      {docente.nombres} {docente.apellidos}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-grid">
                <Input
                  label="Fecha"
                  type="date"
                  value={fecha}
                  onChange={(event) => {
                    setFecha(event.target.value);
                    setDisponibilidad(null);
                  }}
                />

                <Input
                  label="Hora inicio"
                  type="time"
                  value={horaInicio}
                  onChange={(event) => {
                    const nuevaHora = event.target.value;
                    setHoraInicio(nuevaHora);
                    setHoraFin(sumarUnaHora(nuevaHora));
                    setDisponibilidad(null);
                  }}
                />
              </div>

              <Input
                label="Hora fin"
                type="time"
                value={horaFin}
                onChange={(event) => {
                  setHoraFin(event.target.value);
                  setDisponibilidad(null);
                }}
              />

              <div className="action-stack">
                <Button
                  type="button"
                  onClick={handleValidarDisponibilidad}
                  isLoading={isValidating}
                >
                  Validar disponibilidad
                </Button>

                <Button
                  type="button"
                  onClick={handleCrearTutoria}
                  isLoading={isCreating}
                  disabled={!disponibilidad?.disponible}
                >
                  Crear tutoría
                </Button>
              </div>

              {disponibilidad && (
                <div className="result-box">
                  <h4>Disponibilidad</h4>

                  <Badge variant={disponibilidad.disponible ? "success" : "danger"}>
                    {disponibilidad.disponible
                      ? "Disponible"
                      : "No disponible"}
                  </Badge>

                  {disponibilidad.motivo && <p>{disponibilidad.motivo}</p>}
                </div>
              )}

              {tutoriaCreada && (
                <div className="result-box">
                  <h4>Tutoría creada</h4>
                  <p>
                    <strong>ID:</strong> {tutoriaCreada.id_tutoria}
                  </p>
                  <p>
                    <strong>Estado:</strong>{" "}
                    <TutoriaEstadoBadge estado={tutoriaCreada.estado} />
                  </p>
                  <p>
                    <strong>Fecha:</strong> {tutoriaCreada.fecha}
                  </p>
                  <p>
                    <strong>Horario:</strong> {tutoriaCreada.hora_inicio} -{" "}
                    {tutoriaCreada.hora_fin}
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}