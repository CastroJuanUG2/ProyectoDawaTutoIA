import { ApiResponse } from "@/types/api.types";

export function getApiErrorMessage(response: ApiResponse<unknown>): string {
  const errorCode = response.error?.code;

  if (errorCode) {
    return `Error ${errorCode}`;
  }

  return response.message || "Error inesperado";
}

export function logApiTrace(response: ApiResponse<unknown>): void {
  console.error({
    message: response.message,
    service: response.service,
    trace_id: response.trace_id,
    timestamp: response.timestamp,
    error: response.error,
  });
}