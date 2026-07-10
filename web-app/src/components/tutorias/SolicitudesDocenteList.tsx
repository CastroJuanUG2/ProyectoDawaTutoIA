"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { tutoriasApi } from "@/lib/api/tutorias.api";
import { Tutoria } from "@/types/tutoria.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDate } from "@/lib/utils/formatDate";
import { Table } from "@/components/ui/Table";
import { Loading } from "@/components/ui/Loading";
import { Button } from "@/components/ui/Button";
import { TutoriaEstadoBadge } from "@/components/tutorias/TutoriaEstadoBadge";

export function SolicitudesDocenteList() {
  const { user } = useAuth();

  const [tutorias, setTutorias] = useState<Tutoria[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState<number | null>(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [successMessage, setSuccessMessage] = useState("");

  useEffect(() => {
    async function loadTutoriasDocente() {
      if (!user?.id_docente) {
        setErrorMessage("El usuario autenticado no tiene docente asociado.");
        setIsLoading(false);
        return;
      }

      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await tutoriasApi.listarSolicitudesDocente(
          user.id_docente
        );

        setTutorias(response.data);
      } catch (error) {
        logApiTrace(error);
        setErrorMessage(getApiErrorMessage(error));
      } finally {
        setIsLoading(false);
      }
    }

    loadTutoriasDocente();
  }, [user]);

  async function handleConfirmar(idTutoria: number) {
    try {
      setUpdatingId(idTutoria);
      setErrorMessage("");
      setSuccessMessage("");

      const response = await tutoriasApi.confirmarTutoria(idTutoria);

      setTutorias((currentTutorias) =>
        currentTutorias.map((tutoria) =>
          tutoria.id_tutoria === idTutoria ? response.data : tutoria
        )
      );

      setSuccessMessage("Tutoría confirmada correctamente.");
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setUpdatingId(null);
    }
  }

  async function handleCancelar(idTutoria: number) {
    try {
      setUpdatingId(idTutoria);
      setErrorMessage("");
      setSuccessMessage("");

      const response = await tutoriasApi.cancelarTutoria(idTutoria);

      setTutorias((currentTutorias) =>
        currentTutorias.map((tutoria) =>
          tutoria.id_tutoria === idTutoria ? response.data : tutoria
        )
      );

      setSuccessMessage("Tutoría cancelada correctamente.");
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setUpdatingId(null);
    }
  }

  if (isLoading) {
    return <Loading text="Cargando solicitudes del docente..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}
      {successMessage && <div className="form-success">{successMessage}</div>}

      <Table<Tutoria>
        data={tutorias}
        emptyMessage="No tienes solicitudes asignadas por el momento."
        columns={[
          { header: "ID Tutoría", accessor: "id_tutoria" },
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
                  onClick={() => handleConfirmar(row.id_tutoria)}
                >
                  Confirmar
                </Button>

                <Button
                  type="button"
                  className="small-button danger-button"
                  disabled={
                    updatingId === row.id_tutoria ||
                    row.estado === "ATENDIDA" ||
                    row.estado === "CANCELADA"
                  }
                  onClick={() => handleCancelar(row.id_tutoria)}
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