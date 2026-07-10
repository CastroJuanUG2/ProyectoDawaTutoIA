"use client";

import { useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { Docente } from "@/types/academico.types";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Loading } from "@/components/ui/Loading";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function DocentesList() {
  const [docentes, setDocentes] = useState<Docente[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadDocentes() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await academicoApi.listarDocentes();
        setDocentes(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadDocentes();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando docentes..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<Docente>
        data={docentes}
        columns={[
          { header: "ID", accessor: "id_docente" },
          {
            header: "Docente",
            accessor: (row) => `${row.nombres} ${row.apellidos}`,
          },
          { header: "Correo", accessor: "correo" },
          {
            header: "Especialidad",
            accessor: (row) => row.especialidad || "Sin registrar",
          },
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