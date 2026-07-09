"use client";

import { FormEvent, useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { HorarioDocente } from "@/types/academico.types";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function HorariosDocenteList() {
  const [idDocente, setIdDocente] = useState("");
  const [horarios, setHorarios] = useState<HorarioDocente[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    setHorarios([]);
    setErrorMessage("");
  }, [idDocente]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!idDocente.trim()) {
      setErrorMessage("Ingrese el ID del docente.");
      return;
    }

    try {
      setIsLoading(true);
      setErrorMessage("");

      const response = await academicoApi.listarHorariosDocente(
        Number(idDocente)
      );

      setHorarios(response.data);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="data-panel">
      <form className="filter-form" onSubmit={handleSubmit}>
        <Input
          label="ID del docente"
          type="number"
          value={idDocente}
          onChange={(event) => setIdDocente(event.target.value)}
          placeholder="Ejemplo: 1"
        />

        <Button type="submit" isLoading={isLoading}>
          Buscar horarios
        </Button>
      </form>

      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<HorarioDocente>
        data={horarios}
        emptyMessage="Ingrese un docente para consultar sus horarios."
        columns={[
          { header: "ID", accessor: "id_horario" },
          { header: "ID Docente", accessor: "id_docente" },
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
    </div>
  );
}