export interface DashboardResumen {
  total_estudiantes: number;
  total_docentes: number;
  total_solicitudes: number;
  solicitudes_pendientes: number;
  tutorias_confirmadas: number;
  tutorias_atendidas: number;
  tutorias_canceladas: number;
  conversaciones_ia: number;
}

export interface TutoriasPorDocente {
  id_docente: number;
  docente: string;
  total_tutorias: number;
  atendidas: number;
  pendientes: number;
  canceladas: number;
}

export interface EstudiantesAtendidos {
  id_estudiante: number;
  estudiante: string;
  carrera: string;
  total_tutorias: number;
  ultima_atencion: string;
}

export interface TemaRecurrente {
  tema: string;
  asignatura: string;
  total_solicitudes: number;
}

export interface DashboardReportesResponse {
  resumen: DashboardResumen;
  tutorias_por_docente: TutoriasPorDocente[];
  estudiantes_atendidos: EstudiantesAtendidos[];
  temas_recurrentes: TemaRecurrente[];
}