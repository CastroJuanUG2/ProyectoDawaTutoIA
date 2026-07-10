"use client";

import { FormEvent, useEffect, useState } from "react";
import { iaApi } from "@/lib/api/ia.api";
import { ChatMessage as ChatMessageType } from "@/types/ia.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { Button } from "@/components/ui/Button";
import { Loading } from "@/components/ui/Loading";
import { ChatMessage } from "@/components/ia/ChatMessage";
import { useAuth } from "@/context/AuthContext";

export function ChatBox() {
  const [messages, setMessages] = useState<ChatMessageType[]>([]);
  const [mensaje, setMensaje] = useState("");
  const [isLoadingHistory, setIsLoadingHistory] = useState(true);
  const [isSending, setIsSending] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");
  const { user } = useAuth();

   useEffect(() => {
      async function loadHistorial() {
        if (!user?.id_usuario) {
          setErrorMessage("No se pudo identificar el usuario autenticado.");
          setIsLoadingHistory(false);
          return;
        }

        try {
          setIsLoadingHistory(true);
          setErrorMessage("");

          const response = await iaApi.listarHistorialUsuario(user.id_usuario);
          setMessages(response.data);
        } catch (error) {
          const apiError = error as ApiResponse<unknown>;

          logApiTrace(apiError);
          setErrorMessage(getApiErrorMessage(apiError));
        } finally {
          setIsLoadingHistory(false);
        }
      }

      loadHistorial();
   }, [user]);

  useEffect(() => {
    const chatBody = document.querySelector(".chat-body");

    if (chatBody) {
      chatBody.scrollTop = chatBody.scrollHeight;
    }
  }, [messages]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const texto = mensaje.trim();

    if (!texto) {
      setErrorMessage("Escriba una consulta para el agente de IA.");
      return;
    }

    const userMessage: ChatMessageType = {
      id_mensaje: Date.now() * -1,
      rol: "usuario",
      contenido: texto,
      creado_en: new Date().toISOString(),
    };

    try {
      setIsSending(true);
      setErrorMessage("");
      setMensaje("");

      setMessages((currentMessages) => [...currentMessages, userMessage]);

      const response = await iaApi.enviarMensaje({
        mensaje: texto,
      });

      const assistantMessage: ChatMessageType = {
        id_mensaje: response.data.id_mensaje,
        rol: "asistente",
        contenido: response.data.respuesta,
        creado_en: new Date().toISOString(),
        fuente: response.data.fuente,
        requiere_escalamiento: response.data.requiere_escalamiento,
      };

      setMessages((currentMessages) => [
        ...currentMessages,
        assistantMessage,
      ]);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsSending(false);
    }
  }

  if (isLoadingHistory) {
    return <Loading text="Cargando historial del agente IA..." />;
  }

  return (
    <div className="chat-container">
      <div className="chat-info-panel">
        <h3>Agente académico IA</h3>
        <p>
          Este asistente brinda orientación inicial sobre tutorías, asignaturas,
          horarios y seguimiento académico.
        </p>

        <div className="chat-note">
          Las respuestas son sugerencias de apoyo y no reemplazan la decisión
          de un docente o coordinador.
        </div>
      </div>

      <div className="chat-panel">
        <div className="chat-body">
          {messages.length === 0 ? (
            <div className="chat-empty">
              <h3>Inicia una consulta académica</h3>
              <p>
                Puedes preguntar sobre tutorías, asignaturas, disponibilidad de
                docentes o procesos académicos parametrizados.
              </p>
            </div>
          ) : (
            messages.map((message) => (
              <ChatMessage key={message.id_mensaje} message={message} />
            ))
          )}
        </div>

        {errorMessage && <div className="form-error">{errorMessage}</div>}

        <form className="chat-form" onSubmit={handleSubmit}>
          <textarea
            className="app-input chat-input"
            value={mensaje}
            onChange={(event) => setMensaje(event.target.value)}
            placeholder="Escribe tu consulta académica..."
            rows={3}
            disabled={isSending}
          />

          <Button type="submit" isLoading={isSending}>
            Enviar
          </Button>
        </form>
      </div>
    </div>
  );
}