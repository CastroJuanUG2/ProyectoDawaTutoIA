export type EstadoTutoria =
  | "SOLICITADA"
  | "PENDIENTE"
  | "CONFIRMADA"
  | "ATENDIDA"
  | "CANCELADA"
  | "NO_ASISTIDA";

export interface SolicitudTutoria {
  id_solicitud: number;
  id_estudiante: number;
  id_asignatura: number;
  tema: string;
  descripcion: string;
  estado: EstadoTutoria;
  fecha_preferida: string;
  hora_preferida: string;
  creado_en: string;
}

export interface CrearSolicitudTutoriaRequest {
  id_asignatura: number;
  tema: string;
  descripcion: string;
  fecha_preferida: string;
  hora_preferida: string;
}

export interface Tutoria {
  id_tutoria: number;
  id_solicitud: number;
  id_estudiante: number;
  id_docente: number;
  id_asignatura: number;
  fecha: string;
  hora_inicio: string;
  hora_fin: string;
  estado: EstadoTutoria;
  tema: string;
}

export interface BitacoraTutoria {
  id_bitacora: number;
  id_tutoria: number;
  observaciones: string;
  recomendaciones: string;
  asistencia_estudiante: boolean;
  creado_en: string;
}

export interface CrearBitacoraRequest {
  id_tutoria: number;
  observaciones: string;
  recomendaciones: string;
  asistencia_estudiante: boolean;
}