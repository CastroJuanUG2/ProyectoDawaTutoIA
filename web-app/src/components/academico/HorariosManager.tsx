"use client";

import { FormEvent, useCallback, useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { Docente, HorarioDocente } from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";

const DIAS_SEMANA = [
  "LUNES",
  "MARTES",
  "MIERCOLES",
  "JUEVES",
  "VIERNES",
  "SABADO",
];

export function HorariosManager() {
  const [docentes, setDocentes] = useState<Docente[]>([]);
  const [horarios, setHorarios] = useState<HorarioDocente[]>([]);

  const [idDocenteConsulta, setIdDocenteConsulta] = useState("");
  const [idDocenteHorario, setIdDocenteHorario] = useState("");
  const [diaSemana, setDiaSemana] = useState("");
  const [horaInicio, setHoraInicio] = useState("");
  const [horaFin, setHoraFin] = useState("");

  const [isLoadingDocentes, setIsLoadingDocentes] = useState(true);
  const [isLoadingHorarios, setIsLoadingHorarios] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
    async function loadDocentes() {
      try {
        setIsLoadingDocentes(true);
        setErrorMessage("");

        const response = await academicoApi.listarDocentes();
        setDocentes(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoadingDocentes(false);
      }
    }

    loadDocentes();
  }, []);

  const loadHorarios = useCallback(async (idDocente: number) => {
    try {
      setIsLoadingHorarios(true);
      setErrorMessage("");

      const response = await academicoApi.listarHorariosDocente(idDocente);
      setHorarios(response.data);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsLoadingHorarios(false);
    }
  }, []);

  useEffect(() => {
    if (!idDocenteConsulta) {
      setHorarios([]);
      return;
    }

    setIdDocenteHorario(idDocenteConsulta);
    loadHorarios(Number(idDocenteConsulta));
  }, [idDocenteConsulta, loadHorarios]);

  async function handleCrearHorario(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setErrorMessage("");
    setSuccessMessage("");

    if (!idDocenteHorario || !diaSemana || !horaInicio || !horaFin) {
      setErrorMessage("Complete todos los campos para registrar el horario.");
      return;
    }

    if (horaInicio >= horaFin) {
      setErrorMessage("La hora de inicio debe ser menor que la hora de fin.");
      return;
    }

    try {
      setIsSubmitting(true);

      const idDocente = Number(idDocenteHorario);

      await academicoApi.crearHorario({
        id_docente: idDocente,
        dia_semana: diaSemana,
        hora_inicio: horaInicio,
        hora_fin: horaFin,
      });

      setSuccessMessage("Horario registrado correctamente.");

      setDiaSemana("");
      setHoraInicio("");
      setHoraFin("");

      setIdDocenteConsulta(String(idDocente));
      await loadHorarios(idDocente);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="horarios-manager">
      {errorMessage && <div className="form-error">{errorMessage}</div>}
      {successMessage && <div className="form-success">{successMessage}</div>}

      <div className="two-column-layout">
        <div className="panel-card">
          <h3>Registrar horario</h3>

          <form className="tutoria-form" onSubmit={handleCrearHorario}>
            <div className="input-group">
              <label className="input-label">Docente</label>

              <select
                className="app-input"
                value={idDocenteHorario}
                onChange={(event) => setIdDocenteHorario(event.target.value)}
                disabled={isLoadingDocentes}
              >
                <option value="">
                  {isLoadingDocentes
                    ? "Cargando docentes..."
                    : "Seleccione un docente"}
                </option>

                {docentes.map((docente) => (
                  <option key={docente.id_docente} value={docente.id_docente}>
                    {docente.nombres} {docente.apellidos}
                  </option>
                ))}
              </select>
            </div>

            <div className="input-group">
              <label className="input-label">Día de atención</label>

              <select
                className="app-input"
                value={diaSemana}
                onChange={(event) => setDiaSemana(event.target.value)}
              >
                <option value="">Seleccione un día</option>

                {DIAS_SEMANA.map((dia) => (
                  <option key={dia} value={dia}>
                    {dia}
                  </option>
                ))}
              </select>
            </div>

            <div className="form-grid">
              <Input
                label="Hora inicio"
                type="time"
                value={horaInicio}
                onChange={(event) => setHoraInicio(event.target.value)}
              />

              <Input
                label="Hora fin"
                type="time"
                value={horaFin}
                onChange={(event) => setHoraFin(event.target.value)}
              />
            </div>

            <Button type="submit" isLoading={isSubmitting}>
              Guardar horario
            </Button>
          </form>
        </div>

        <div className="panel-card">
          <h3>Consultar horarios</h3>

          <div className="input-group horarios-filter">
            <label className="input-label">Docente</label>

            <select
              className="app-input"
              value={idDocenteConsulta}
              onChange={(event) => setIdDocenteConsulta(event.target.value)}
              disabled={isLoadingDocentes}
            >
              <option value="">
                {isLoadingDocentes
                  ? "Cargando docentes..."
                  : "Seleccione un docente"}
              </option>

              {docentes.map((docente) => (
                <option key={docente.id_docente} value={docente.id_docente}>
                  {docente.nombres} {docente.apellidos}
                </option>
              ))}
            </select>
          </div>

          {isLoadingHorarios ? (
            <p className="inline-loading">Cargando horarios...</p>
          ) : (
            <Table<HorarioDocente>
              data={horarios}
              emptyMessage="Seleccione un docente para consultar sus horarios."
              columns={[
                { header: "ID", accessor: "id_horario" },
                { header: "Día", accessor: "dia_semana" },
                { header: "Inicio", accessor: "hora_inicio" },
                { header: "Fin", accessor: "hora_fin" },
                {
                  header: "Estado",
                  accessor: (row) => (
                    <Badge variant={row.activo ? "success" : "danger"}>
                      {row.activo ? "Activo" : "Inactivo"}
                    </Badge>
                  ),
                },
              ]}
            />
          )}
        </div>
      </div>
    </div>
  );
}