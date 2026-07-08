import { apiClient } from "@/lib/api/apiClient";
import {
  ChatMessage,
  ChatRequest,
  ChatResponse,
  FeedbackIARequest,
} from "@/types/ia.types";

export const iaApi = {
  enviarMensaje(payload: ChatRequest) {
    return apiClient.post<ChatResponse, ChatRequest>("/ia/chat", payload);
  },

  listarHistorial() {
    return apiClient.get<ChatMessage[]>("/ia/historial");
  },

  enviarFeedback(idMensaje: number, payload: FeedbackIARequest) {
    return apiClient.post<null, FeedbackIARequest>(
      `/ia/mensajes/${idMensaje}/feedback`,
      payload
    );
  },
};