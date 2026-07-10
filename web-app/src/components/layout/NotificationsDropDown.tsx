"use client";

import { useEffect, useState } from "react";
import { notificacionesApi } from "@/lib/api/notificaciones.api";
import { Notificacion } from "@/types/notificacion.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";
import { formatDateTime } from "@/lib/utils/formatDate";

export function NotificationsDropdown() {
  const [notificaciones, setNotificaciones] = useState<Notificacion[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [readingId, setReadingId] = useState<number | null>(null);
  const [errorMessage, setErrorMessage] = useState("");

  const totalNoLeidas = notificaciones.filter(
    (notificacion) => !notificacion.leida
  ).length;

  useEffect(() => {
    async function loadNotificaciones() {
      try {
        setIsLoading(true);
        setErrorMessage("");

        const response = await notificacionesApi.listar();
        setNotificaciones(response.data);
      } catch (error) {
        logApiTrace(error);
        setErrorMessage(getApiErrorMessage(error));
      } finally {
        setIsLoading(false);
      }
    }

    loadNotificaciones();
  }, []);

  async function handleMarcarLeida(idNotificacion: number) {
    try {
      setReadingId(idNotificacion);
      setErrorMessage("");

      await notificacionesApi.marcarComoLeida(idNotificacion);

      setNotificaciones((currentNotificaciones) =>
        currentNotificaciones.map((notificacion) =>
          notificacion.id_notificacion === idNotificacion
            ? { ...notificacion, leida: true }
            : notificacion
        )
      );
    } catch (error) {
      logApiTrace(error);
      setErrorMessage(getApiErrorMessage(error));
    } finally {
      setReadingId(null);
    }
  }

  return (
    <div className="notifications-wrapper">
      <button
        type="button"
        className="notifications-button"
        onClick={() => setIsOpen((currentValue) => !currentValue)}
      >
        Notificaciones
        {totalNoLeidas > 0 && (
          <span className="notifications-count">{totalNoLeidas}</span>
        )}
      </button>

      {isOpen && (
        <div className="notifications-panel">
          <div className="notifications-header">
            <strong>Notificaciones</strong>
            <span>{totalNoLeidas} no leídas</span>
          </div>

          {isLoading && (
            <p className="notifications-empty">Cargando notificaciones...</p>
          )}

          {errorMessage && <div className="form-error">{errorMessage}</div>}

          {!isLoading && notificaciones.length === 0 && (
            <p className="notifications-empty">
              No tienes notificaciones pendientes.
            </p>
          )}

          {!isLoading &&
            notificaciones.map((notificacion) => (
              <article
                key={notificacion.id_notificacion}
                className={`notification-item ${
                  notificacion.leida ? "read" : "unread"
                }`}
              >
                <div>
                  <strong>{notificacion.titulo}</strong>
                  <p>{notificacion.mensaje}</p>
                  <small>{formatDateTime(notificacion.creado_en)}</small>
                </div>

                {!notificacion.leida && (
                  <button
                    type="button"
                    onClick={() =>
                      handleMarcarLeida(notificacion.id_notificacion)
                    }
                    disabled={readingId === notificacion.id_notificacion}
                  >
                    {readingId === notificacion.id_notificacion
                      ? "Marcando..."
                      : "Leer"}
                  </button>
                )}
              </article>
            ))}
        </div>
      )}
    </div>
  );
}