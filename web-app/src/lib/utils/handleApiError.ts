import { ApiResponse } from "@/types/api.types";

function isApiResponse(value: unknown): value is ApiResponse<unknown> {
  return (
    typeof value === "object" &&
    value !== null &&
    "success" in value &&
    "message" in value
  );
}

export function getApiErrorMessage(error: unknown): string {
  if (isApiResponse(error)) {
    const errorCode = error.error?.code;

    if (errorCode) {
      return `Error ${errorCode}`;
    }

    return error.message || "Error inesperado";
  }

  return "Error inesperado";
}

export function logApiTrace(error: unknown): void {
  if (!isApiResponse(error)) {
    console.error(error);
    return;
  }

  console.error({
    message: error.message,
    service: error.service,
    trace_id: error.trace_id,
    timestamp: error.timestamp,
    error: error.error,
  });
}