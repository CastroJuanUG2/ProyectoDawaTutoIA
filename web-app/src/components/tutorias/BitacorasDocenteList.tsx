"use client";

import { useEffect, useState } from "react";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { BitacoraTutoria } from "@/types/tutoria.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDateTime } from "@/lib/utils/formatDate";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Loading } from "@/components/ui/Loading";

export function BitacorasDocenteList() {
  const [bitacoras, setBitacoras] = useState<BitacoraTutoria[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadBitacoras() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await tutoriasApi.listarBitacorasDocente();
        setBitacoras(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadBitacoras();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando bitácoras registradas..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<BitacoraTutoria>
        data={bitacoras}
        emptyMessage="Todavía no has registrado bitácoras de atención."
        columns={[
          { header: "ID", accessor: "id_bitacora" },
          { header: "ID Tutoría", accessor: "id_tutoria" },
          {
            header: "Asistencia",
            accessor: (row) => (
              <Badge variant={row.asistencia_estudiante ? "success" : "danger"}>
                {row.asistencia_estudiante ? "Asistió" : "No asistió"}
              </Badge>
            ),
          },
          {
            header: "Observaciones",
            accessor: (row) =>
              row.observaciones.length > 55
                ? `${row.observaciones.substring(0, 55)}...`
                : row.observaciones,
          },
          {
            header: "Fecha",
            accessor: (row) => formatDateTime(row.creado_en),
          },
        ]}
      />
    </div>
  );
}