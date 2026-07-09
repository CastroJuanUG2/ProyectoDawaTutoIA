"use client";

import { useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { Estudiante } from "@/types/academico.types";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Loading } from "@/components/ui/Loading";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function EstudiantesList() {
  const [estudiantes, setEstudiantes] = useState<Estudiante[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadEstudiantes() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await academicoApi.listarEstudiantes();
        setEstudiantes(response.data);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadEstudiantes();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando estudiantes..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<Estudiante>
        data={estudiantes}
        columns={[
          { header: "ID", accessor: "id_estudiante" },
          {
            header: "Estudiante",
            accessor: (row) => `${row.nombres} ${row.apellidos}`,
          },
          { header: "Correo", accessor: "correo" },
          { header: "Matrícula", accessor: "matricula" },
          { header: "ID Carrera", accessor: "id_carrera" },
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