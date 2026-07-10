"use client";

import { useEffect, useState } from "react";
import { academicoApi } from "@/lib/api/academico.api";
import { Carrera } from "@/types/academico.types";
import { Table } from "@/components/ui/Table";
import { Badge } from "@/components/ui/Badge";
import { Loading } from "@/components/ui/Loading";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

export function CarrerasList() {
  const [carreras, setCarreras] = useState<Carrera[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadCarreras() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await academicoApi.listarCarreras();
        setCarreras(response.data);
      } catch (error) {
        logApiTrace(error);
        setErrorMessage(getApiErrorMessage(error));
      } finally {
        setIsLoading(false);
      }
    }

    loadCarreras();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando carreras..." />;
  }

  return (
    <div className="data-panel">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <Table<Carrera>
        data={carreras}
        columns={[
          { header: "ID", accessor: "id_carrera" },
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