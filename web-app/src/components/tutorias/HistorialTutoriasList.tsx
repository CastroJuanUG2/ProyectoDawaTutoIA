"use client";

import { useEffect, useState } from "react";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { Tutoria } from "@/types/tutoria.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDate } from "@/lib/utils/formatDate";
import { Table } from "@/components/ui/Table";
import { Loading } from "@/components/ui/Loading";
import { TutoriaEstadoBadge } from "@/components/tutorias/TutoriaEstadoBadge";

export function HistorialTutoriasList() {
  const [tutorias, setTutorias] = useState<Tutoria[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadHistorial() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await tutoriasApi.listarHistorialEstudiante();
        setTutorias(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadHistorial();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando historial de tutorías..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<Tutoria>
        data={tutorias}
        emptyMessage="Todavía no existe historial de tutorías."
        columns={[
          { header: "ID", accessor: "id_tutoria" },
          { header: "Tema", accessor: "tema" },
          { header: "Docente", accessor: "id_docente" },
          { header: "Asignatura", accessor: "id_asignatura" },
          {
            header: "Fecha",
            accessor: (row) => formatDate(row.fecha),
          },
          { header: "Inicio", accessor: "hora_inicio" },
          { header: "Fin", accessor: "hora_fin" },
          {
            header: "Estado",
            accessor: (row) => <TutoriaEstadoBadge estado={row.estado} />,
          },
        ]}
      />
    </div>
  );
}