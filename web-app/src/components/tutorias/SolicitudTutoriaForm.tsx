"use client";

import { FormEvent, useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { Asignatura } from "@/types/academico.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";

export function SolicitudTutoriaForm() {
  const [asignaturas, setAsignaturas] = useState<Asignatura[]>([]);
  const [idAsignatura, setIdAsignatura] = useState("");
  const [tema, setTema] = useState("");
  const [descripcion, setDescripcion] = useState("");
  const [fechaPreferida, setFechaPreferida] = useState("");
  const [horaPreferida, setHoraPreferida] = useState("");

  const [isLoadingAsignaturas, setIsLoadingAsignaturas] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
    async function loadAsignaturas() {
      try {
        setIsLoadingAsignaturas(true);
        setErrorMessage("");

        const response = await academicoApi.listarAsignaturas();
        setAsignaturas(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoadingAsignaturas(false);
      }
    }

    loadAsignaturas();
  }, []);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    setErrorMessage("");
    setSuccessMessage("");

    if (
      !idAsignatura ||
      !tema.trim() ||
      !descripcion.trim() ||
      !fechaPreferida ||
      !horaPreferida
    ) {
      setErrorMessage("Complete todos los campos para solicitar la tutoría.");
      return;
    }

    try {
      setIsSubmitting(true);

      await tutoriasApi.crearSolicitud({
        id_asignatura: Number(idAsignatura),
        tema,
        descripcion,
        fecha_preferida: fechaPreferida,
        hora_preferida: horaPreferida,
      });

      setSuccessMessage("Solicitud de tutoría registrada correctamente.");

      setIdAsignatura("");
      setTema("");
      setDescripcion("");
      setFechaPreferida("");
      setHoraPreferida("");
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
        <label className="input-label">Asignatura</label>

        <select
          className="app-input"
          value={idAsignatura}
          onChange={(event) => setIdAsignatura(event.target.value)}
          disabled={isLoadingAsignaturas}
        >
          <option value="">
            {isLoadingAsignaturas
              ? "Cargando asignaturas..."
              : "Seleccione una asignatura"}
          </option>

          {asignaturas.map((asignatura) => (
            <option
              key={asignatura.id_asignatura}
              value={asignatura.id_asignatura}
            >
              {asignatura.codigo} - {asignatura.nombre}
            </option>
          ))}
        </select>
      </div>

      <Input
        label="Tema de la tutoría"
        type="text"
        value={tema}
        onChange={(event) => setTema(event.target.value)}
        placeholder="Ejemplo: Dudas sobre programación orientada a objetos"
      />

      <div className="input-group">
        <label className="input-label">Descripción</label>
        <textarea
          className="app-input app-textarea"
          value={descripcion}
          onChange={(event) => setDescripcion(event.target.value)}
          placeholder="Describa brevemente la dificultad o consulta académica."
          rows={5}
        />
      </div>

      <div className="form-grid">
        <Input
          label="Fecha preferida"
          type="date"
          value={fechaPreferida}
          onChange={(event) => setFechaPreferida(event.target.value)}
        />

        <Input
          label="Hora preferida"
          type="time"
          value={horaPreferida}
          onChange={(event) => setHoraPreferida(event.target.value)}
        />
      </div>

      <Button type="submit" isLoading={isSubmitting}>
        Registrar solicitud
      </Button>
    </form>
  );
}