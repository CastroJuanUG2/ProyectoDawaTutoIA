export interface ChatMessage {
  id_mensaje: number;
  rol: "usuario" | "asistente";
  contenido: string;
  creado_en: string;
  fuente?: string;
  requiere_escalamiento?: boolean;
}

export interface ChatRequest {
  mensaje: string;
}

export interface ChatResponse {
  id_conversacion: number;
  id_mensaje: number;
  respuesta: string;
  fuente?: string;
  requiere_escalamiento: boolean;
}

export interface ClasificarSolicitudRequest {
  mensaje: string;
  id_asignatura?: number;
}

export interface ClasificarSolicitudResponse {
  categoria: string;
  prioridad: "BAJA" | "MEDIA" | "ALTA";
  requiere_escalamiento: boolean;
}

export interface SugerirDocenteRequest {
  id_asignatura: number;
  fecha_preferida?: string;
  hora_preferida?: string;
}

export interface SugerirDocenteResponse {
  id_docente: number;
  docente: string;
  motivo: string;
  disponible: boolean;
}

export interface FeedbackIARequest {
  util: boolean;
  comentario?: string;
}