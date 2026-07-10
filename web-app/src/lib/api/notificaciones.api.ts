import { apiClient } from "@/lib/api/apiClient";
import {
  MarcarNotificacionLeidaResponse,
  Notificacion,
} from "@/types/notificacion.types";

export const notificacionesApi = {
  listar() {
    return apiClient.get<Notificacion[]>("/notificaciones");
  },

  marcarComoLeida(idNotificacion: number) {
    return apiClient.patch<MarcarNotificacionLeidaResponse>(
      `/notificaciones/${idNotificacion}/leer`
    );
  },
};