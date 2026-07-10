"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { SolicitudTutoria } from "@/types/tutoria.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDateTime } from "@/lib/utils/formatDate";
import { Table } from "@/components/ui/Table";
import { Loading } from "@/components/ui/Loading";
import { TutoriaEstadoBadge } from "@/components/tutorias/TutoriaEstadoBadge";

export function HistorialTutoriasList() {
  const { user } = useAuth();

  const [solicitudes, setSolicitudes] = useState<SolicitudTutoria[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadSolicitudes() {
      if (!user?.id_estudiante) {
        setErrorMessage("El usuario autenticado no tiene estudiante asociado.");
        setIsLoading(false);
        return;
      }

      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await tutoriasApi.listarSolicitudesEstudiante(
          user.id_estudiante
        );

        setSolicitudes(response.data);
      } catch (error) {
        logApiTrace(error);
        setErrorMessage(getApiErrorMessage(error));
      } finally {
        setIsLoading(false);
      }
    }

    loadSolicitudes();
  }, [user]);

  if (isLoading) {
    return <Loading text="Cargando solicitudes de tutoría..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<SolicitudTutoria>
        data={solicitudes}
        emptyMessage="Todavía no tienes solicitudes registradas."
        columns={[
          { header: "ID", accessor: "id_solicitud" },
          { header: "Asignatura", accessor: "id_asignatura" },
          { header: "Tema", accessor: "tema" },
          {
            header: "Estado",
            accessor: (row) => <TutoriaEstadoBadge estado={row.estado} />,
          },
          {
            header: "Fecha registro",
            accessor: (row) => formatDateTime(row.creado_en),
          },
        ]}
      />
    </div>
  );
}