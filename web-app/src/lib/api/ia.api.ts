import { apiClient } from "@/lib/api/apiClient";
import {
  ChatMessage,
  ChatRequest,
  ChatResponse,
  ClasificarSolicitudRequest,
  ClasificarSolicitudResponse,
  FeedbackIARequest,
  SugerirDocenteRequest,
  SugerirDocenteResponse,
} from "@/types/ia.types";

export const iaApi = {
  enviarMensaje(payload: ChatRequest) {
    return apiClient.post<ChatResponse, ChatRequest>("/ia/chat", payload);
  },

  clasificarSolicitud(payload: ClasificarSolicitudRequest) {
    return apiClient.post<
      ClasificarSolicitudResponse,
      ClasificarSolicitudRequest
    >("/ia/clasificar-solicitud", payload);
  },

  sugerirDocente(payload: SugerirDocenteRequest) {
    return apiClient.post<SugerirDocenteResponse, SugerirDocenteRequest>(
      "/ia/sugerir-docente",
      payload
    );
  },

  listarHistorialUsuario(idUsuario: number) {
    return apiClient.get<ChatMessage[]>(`/ia/usuarios/${idUsuario}/historial`);
  },

  enviarFeedback(idMensaje: number, payload: FeedbackIARequest) {
    return apiClient.post<null, FeedbackIARequest>(
      `/ia/mensajes/${idMensaje}/feedback`,
      payload
    );
  },
};