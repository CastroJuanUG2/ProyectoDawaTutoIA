import { ChatMessage as ChatMessageType } from "@/types/ia.types";
import { formatDateTime } from "@/lib/utils/formatDate";
import { FeedbackButtons } from "@/components/ia/FeedbackButtons";

interface ChatMessageProps {
  message: ChatMessageType;
}

export function ChatMessage({ message }: ChatMessageProps) {
  const isAssistant = message.rol === "asistente";

  return (
    <article
      className={`chat-message ${
        isAssistant ? "assistant-message" : "user-message"
      }`}
    >
      <div className="chat-message-header">
        <strong>{isAssistant ? "Agente IA" : "Usuario"}</strong>
        <span>{formatDateTime(message.creado_en)}</span>
      </div>

      <p>{message.contenido}</p>

      {message.fuente && (
        <div className="chat-source">
          Fuente consultada: <strong>{message.fuente}</strong>
        </div>
      )}

      {message.requiere_escalamiento && (
        <div className="chat-warning">
          Esta consulta requiere revisión de un docente o coordinador.
        </div>
      )}

      {isAssistant && message.id_mensaje > 0 && (
        <FeedbackButtons idMensaje={message.id_mensaje} />
      )}
    </article>
  );
}