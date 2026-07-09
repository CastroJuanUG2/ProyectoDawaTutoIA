"use client";

import { useState } from "react";
import { iaApi } from "@/lib/api/ia.api";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

interface FeedbackButtonsProps {
  idMensaje: number;
}

export function FeedbackButtons({ idMensaje }: FeedbackButtonsProps) {
  const [isSending, setIsSending] = useState(false);
  const [feedbackSent, setFeedbackSent] = useState<"util" | "no_util" | null>(
    null
  );
  const [errorMessage, setErrorMessage] = useState("");

  async function handleFeedback(util: boolean) {
    try {
      setIsSending(true);
      setErrorMessage("");

      await iaApi.enviarFeedback(idMensaje, {
        util,
      });

      setFeedbackSent(util ? "util" : "no_util");
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      logApiTrace(apiError);
      setErrorMessage(getApiErrorMessage(apiError));
    } finally {
      setIsSending(false);
    }
  }

  if (feedbackSent) {
    return (
      <div className="feedback-status">
        Feedback registrado:{" "}
        <strong>{feedbackSent === "util" ? "Útil" : "No útil"}</strong>
      </div>
    );
  }

  return (
    <div className="feedback-box">
      <span>¿La respuesta fue útil?</span>

      <button
        type="button"
        className="feedback-button"
        onClick={() => handleFeedback(true)}
        disabled={isSending}
      >
        Sí
      </button>

      <button
        type="button"
        className="feedback-button secondary"
        onClick={() => handleFeedback(false)}
        disabled={isSending}
      >
        No
      </button>

      {errorMessage && <small className="input-error">{errorMessage}</small>}
    </div>
  );
}