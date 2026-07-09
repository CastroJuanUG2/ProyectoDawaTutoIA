"use client";

import { useEffect, useState } from "react";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { SolicitudTutoria } from "@/types/tutoria.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDateTime } from "@/lib/utils/formatDate";
import { Table } from "@/components/ui/Table";
import { Loading } from "@/components/ui/Loading";
import { TutoriaEstadoBadge } from "@/components/tutorias/TutoriaEstadoBadge";

export function MisSolicitudesList() {
  const [solicitudes, setSolicitudes] = useState<SolicitudTutoria[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadSolicitudes() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await tutoriasApi.listarMisSolicitudes();
        setSolicitudes(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadSolicitudes();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando solicitudes de tutoría..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<SolicitudTutoria>
        data={solicitudes}
        emptyMessage="Todavía no tienes solicitudes de tutoría registradas."
        columns={[
          { header: "ID", accessor: "id_solicitud" },
          { header: "Asignatura", accessor: "id_asignatura" },
          { header: "Tema", accessor: "tema" },
          {
            header: "Estado",
            accessor: (row) => <TutoriaEstadoBadge estado={row.estado} />,
          },
          {
            header: "Fecha de registro",
            accessor: (row) => formatDateTime(row.creado_en),
          },
        ]}
      />
    </div>
  );
}