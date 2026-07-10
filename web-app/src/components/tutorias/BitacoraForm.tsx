"use client";

import { FormEvent, useEffect, useState } from "react";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { Tutoria } from "@/types/tutoria.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { Button } from "@/components/ui/Button";
import { useAuth } from "@/context/AuthContext";

export function BitacoraForm() {
  const [tutorias, setTutorias] = useState<Tutoria[]>([]);
  const [idTutoria, setIdTutoria] = useState("");
  const [observaciones, setObservaciones] = useState("");
  const [recomendaciones, setRecomendaciones] = useState("");
  const [asistenciaEstudiante, setAsistenciaEstudiante] = useState(true);
  cont { user } = useAuth();

  const [isLoadingTutorias, setIsLoadingTutorias] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
  async function loadTutorias() {
    if (!user?.id_docente) {
      setErrorMessage("El usuario autenticado no tiene docente asociado.");
      setIsLoadingTutorias(false);
      return;
    }

    try {
      setIsLoadingTutorias(true);
      setErrorMessage("");

      const response = await tutoriasApi.listarSolicitudesDocente(
        user.id_docente
      );

      const tutoriasValidas = response.data.filter(
        (tutoria) =>
          tutoria.estado === "CONFIRMADA" || tutoria.estado === "ATENDIDA"
      );

      setTutorias(tutoriasValidas);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsLoadingTutorias(false);
    }
  }

  loadTutorias();
 }, [user]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setErrorMessage("");
    setSuccessMessage("");

    if (!idTutoria || !observaciones.trim() || !recomendaciones.trim()) {
      setErrorMessage("Complete todos los campos para registrar la bitácora.");
      return;
    }

    try {
      setIsSubmitting(true);

      await tutoriasApi.registrarBitacora(Number(idTutoria),{
        observaciones,
        recomendaciones,
        asistencia_estudiante: asistenciaEstudiante,
      });

      setSuccessMessage("Bitácora registrada correctamente.");

      setIdTutoria("");
      setObservaciones("");
      setRecomendaciones("");
      setAsistenciaEstudiante(true);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form className="tutoria-form" onSubmit={handleSubmit}>
      {errorMessage && <div className="form-error">{errorMessage}</div>}
      {successMessage && <div className="form-success">{successMessage}</div>}

      <div className="input-group">
        <label className="input-label">Tutoría atendida</label>

        <select
          className="app-input"
          value={idTutoria}
          onChange={(event) => setIdTutoria(event.target.value)}
          disabled={isLoadingTutorias}
        >
          <option value="">
            {isLoadingTutorias
              ? "Cargando tutorías..."
              : "Seleccione una tutoría"}
          </option>

          {tutorias.map((tutoria) => (
            <option key={tutoria.id_tutoria} value={tutoria.id_tutoria}>
              #{tutoria.id_tutoria} - {tutoria.tema} - {tutoria.fecha}
            </option>
          ))}
        </select>
      </div>

      <div className="input-group">
        <label className="input-label">Observaciones del docente</label>
        <textarea
          className="app-input app-textarea"
          value={observaciones}
          onChange={(event) => setObservaciones(event.target.value)}
          placeholder="Describa lo tratado durante la tutoría."
          rows={5}
        />
      </div>

      <div className="input-group">
        <label className="input-label">Recomendaciones académicas</label>
        <textarea
          className="app-input app-textarea"
          value={recomendaciones}
          onChange={(event) => setRecomendaciones(event.target.value)}
          placeholder="Registre recomendaciones, tareas o pasos sugeridos."
          rows={5}
        />
      </div>

      <label className="checkbox-row">
        <input
          type="checkbox"
          checked={asistenciaEstudiante}
          onChange={(event) => setAsistenciaEstudiante(event.target.checked)}
        />
        <span>El estudiante asistió a la tutoría</span>
      </label>

      <Button type="submit" isLoading={isSubmitting}>
        Registrar bitácora
      </Button>
    </form>
  );
}