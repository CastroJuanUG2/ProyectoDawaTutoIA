"use client";

import { useEffect, useState } from "react";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { EstadoTutoria, Tutoria } from "@/types/tutoria.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDate } from "@/lib/utils/formatDate";
import { Table } from "@/components/ui/Table";
import { Loading } from "@/components/ui/Loading";
import { Button } from "@/components/ui/Button";
import { TutoriaEstadoBadge } from "@/components/tutorias/TutoriaEstadoBadge";

export function SolicitudesDocenteList() {
  const [tutorias, setTutorias] = useState<Tutoria[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState<number | null>(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
    loadTutoriasDocente();
  }, []);

  async function loadTutoriasDocente() {
    try {
      setIsLoading(true);
      setErrorMessage("");

      const response = await tutoriasApi.listarTutoriasDocente();
      setTutorias(response.data);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsLoading(false);
    }
  }

  async function handleCambiarEstado(
    idTutoria: number,
    nuevoEstado: EstadoTutoria
  ) {
    try {
      setUpdatingId(idTutoria);
      setErrorMessage("");
      setSuccessMessage("");

      await tutoriasApi.cambiarEstado(idTutoria, nuevoEstado);

      setTutorias((currentTutorias) =>
        currentTutorias.map((tutoria) =>
          tutoria.id_tutoria === idTutoria
            ? { ...tutoria, estado: nuevoEstado }
            : tutoria
        )
      );

      setSuccessMessage(`Tutoría actualizada a estado ${nuevoEstado}.`);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setUpdatingId(null);
    }
  }

  if (isLoading) {
    return <Loading text="Cargando tutorías asignadas..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}
      {successMessage && <div className="form-success">{successMessage}</div>}

      <Table<Tutoria>
        data={tutorias}
        emptyMessage="No tienes tutorías asignadas por el momento."
        columns={[
          { header: "ID", accessor: "id_tutoria" },
          { header: "Tema", accessor: "tema" },
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
          {
            header: "Acciones",
            accessor: (row) => (
              <div className="table-actions">
                <Button
                  type="button"
                  className="small-button"
                  disabled={
                    updatingId === row.id_tutoria ||
                    row.estado === "CONFIRMADA" ||
                    row.estado === "ATENDIDA" ||
                    row.estado === "CANCELADA"
                  }
                  onClick={() =>
                    handleCambiarEstado(row.id_tutoria, "CONFIRMADA")
                  }
                >
                  Confirmar
                </Button>

                <Button
                  type="button"
                  className="small-button"
                  disabled={
                    updatingId === row.id_tutoria ||
                    row.estado === "ATENDIDA" ||
                    row.estado === "CANCELADA"
                  }
                  onClick={() => handleCambiarEstado(row.id_tutoria, "ATENDIDA")}
                >
                  Atendida
                </Button>

                <Button
                  type="button"
                  className="small-button danger-button"
                  disabled={
                    updatingId === row.id_tutoria ||
                    row.estado === "ATENDIDA" ||
                    row.estado === "CANCELADA"
                  }
                  onClick={() =>
                    handleCambiarEstado(row.id_tutoria, "CANCELADA")
                  }
                >
                  Cancelar
                </Button>
              </div>
            ),
          },
        ]}
      />
    </div>
  );
}