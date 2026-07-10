export interface Notificacion {
  id_notificacion: number;
  titulo: string;
  mensaje: string;
  leida: boolean;
  tipo?: "INFO" | "WARNING" | "SUCCESS" | "ERROR";
  creado_en: string;
}

export interface MarcarNotificacionLeidaResponse {
  id_notificacion: number;
  leida: boolean;
}