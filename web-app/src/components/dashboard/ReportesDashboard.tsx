    "use client";

import { useEffect, useState } from "react";
import { reportesApi } from "@/lib/api/reportes.api";
import {
  DashboardResumen,
  EstudiantesAtendidos,
  TemaRecurrente,
  TutoriasPorDocente,
} from "@/types/reporte.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDate } from "@/lib/utils/formatDate";
import { Loading } from "@/components/ui/Loading";
import { Table } from "@/components/ui/Table";
import { DashboardMetricCard } from "@/components/dashboard/DashboardMetricCard";

const emptyResumen: DashboardResumen = {
  total_estudiantes: 0,
  total_docentes: 0,
  total_solicitudes: 0,
  solicitudes_pendientes: 0,
  tutorias_confirmadas: 0,
  tutorias_atendidas: 0,
  tutorias_canceladas: 0,
  conversaciones_ia: 0,
};

export function ReportesDashboard() {
  const [resumen, setResumen] = useState<DashboardResumen>(emptyResumen);
  const [tutoriasPorDocente, setTutoriasPorDocente] = useState<
    TutoriasPorDocente[]
  >([]);
  const [estudiantesAtendidos, setEstudiantesAtendidos] = useState<
    EstudiantesAtendidos[]
  >([]);
  const [temasRecurrentes, setTemasRecurrentes] = useState<TemaRecurrente[]>(
    []
  );

  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    async function loadDashboard() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await reportesApi.obtenerDashboard();

        setResumen(response.data.resumen);
        setTutoriasPorDocente(response.data.tutorias_por_docente);
        setEstudiantesAtendidos(response.data.estudiantes_atendidos);
        setTemasRecurrentes(response.data.temas_recurrentes);
      } catch (error) {
        const apiError = error as ApiResponse<unknown>;

        logApiTrace(apiError);
        setErrorMessage(getApiErrorMessage(apiError));
      } finally {
        setIsLoading(false);
      }
    }

    loadDashboard();
  }, []);

  if (isLoading) {
    return <Loading text="Cargando reportes académicos..." />;
  }

  return (
    <div className="reportes-dashboard">
      {errorMessage && <div className="form-error">{errorMessage}</div>}

      <section className="metrics-grid">
        <DashboardMetricCard
          title="Estudiantes"
          value={resumen.total_estudiantes}
          description="Total de estudiantes registrados."
        />

        <DashboardMetricCard
          title="Docentes"
          value={resumen.total_docentes}
          description="Total de docentes registrados."
        />

        <DashboardMetricCard
          title="Solicitudes"
          value={resumen.total_solicitudes}
          description="Solicitudes de tutoría registradas."
        />

        <DashboardMetricCard
          title="Pendientes"
          value={resumen.solicitudes_pendientes}
          description="Solicitudes pendientes de atención."
        />

        <DashboardMetricCard
          title="Confirmadas"
          value={resumen.tutorias_confirmadas}
          description="Tutorías confirmadas por docentes."
        />

        <DashboardMetricCard
          title="Atendidas"
          value={resumen.tutorias_atendidas}
          description="Tutorías completadas con seguimiento."
        />

        <DashboardMetricCard
          title="Canceladas"
          value={resumen.tutorias_canceladas}
          description="Tutorías canceladas o no realizadas."
        />

        <DashboardMetricCard
          title="Consultas IA"
          value={resumen.conversaciones_ia}
          description="Interacciones registradas con el agente IA."
        />
      </section>

      <section className="report-grid">
        <article className="report-panel">
          <h3>Tutorías por docente</h3>

          <Table<TutoriasPorDocente>
            data={tutoriasPorDocente}
            emptyMessage="No existen datos de tutorías por docente."
            columns={[
              { header: "ID", accessor: "id_docente" },
              { header: "Docente", accessor: "docente" },
              { header: "Total", accessor: "total_tutorias" },
              { header: "Atendidas", accessor: "atendidas" },
              { header: "Pendientes", accessor: "pendientes" },
              { header: "Canceladas", accessor: "canceladas" },
            ]}
          />
        </article>

        <article className="report-panel">
          <h3>Estudiantes atendidos</h3>

          <Table<EstudiantesAtendidos>
            data={estudiantesAtendidos}
            emptyMessage="No existen estudiantes atendidos registrados."
            columns={[
              { header: "ID", accessor: "id_estudiante" },
              { header: "Estudiante", accessor: "estudiante" },
              { header: "Carrera", accessor: "carrera" },
              { header: "Total tutorías", accessor: "total_tutorias" },
              {
                header: "Última atención",
                accessor: (row) => formatDate(row.ultima_atencion),
              },
            ]}
          />
        </article>

        <article className="report-panel full-width">
          <h3>Temas académicos recurrentes</h3>

          <Table<TemaRecurrente>
            data={temasRecurrentes}
            emptyMessage="No existen temas recurrentes registrados."
            columns={[
              { header: "Tema", accessor: "tema" },
              { header: "Asignatura", accessor: "asignatura" },
              { header: "Total solicitudes", accessor: "total_solicitudes" },
            ]}
          />
        </article>
      </section>
    </div>
  );
}