"use client";

import { useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { Facultad } from "@/types/academico.types";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Loading } from "@/components/ui/Loading";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function FacultadesList() {
  const [facultades, setFacultades] = useState<Facultad[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadFacultades() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await academicoApi.listarFacultades();
        setFacultades(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadFacultades();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando facultades..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<Facultad>
        data={facultades}
        columns={[
          { header: "ID", accessor: "id_facultad" },
          { header: "Código", accessor: "codigo" },
          { header: "Nombre", accessor: "nombre" },
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