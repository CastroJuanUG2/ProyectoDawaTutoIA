"use client";

import { useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { Asignatura } from "@/types/academico.types";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Loading } from "@/components/ui/Loading";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function AsignaturasList() {
  const [asignaturas, setAsignaturas] = useState<Asignatura[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadAsignaturas() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await academicoApi.listarAsignaturas();
        setAsignaturas(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadAsignaturas();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando asignaturas..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<Asignatura>
        data={asignaturas}
        columns={[
          { header: "ID", accessor: "id_asignatura" },
          { header: "ID Carrera", accessor: "id_carrera" },
          { header: "Código", accessor: "codigo" },
          { header: "Nombre", accessor: "nombre" },
          { header: "Nivel", accessor: "nivel" },
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