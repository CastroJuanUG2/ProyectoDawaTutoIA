export interface ChatMessage {
  id_mensaje: number;
  rol: "usuario" | "asistente";
  contenido: string;
  creado_en: string;
  fuente?: string;
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

export interface FeedbackIARequest {
  util: boolean;
  comentario?: string;
}