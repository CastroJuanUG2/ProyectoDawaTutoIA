import {
  clearAuthStorage,
  getBearerToken,
  getToken,
  isTokenExpired,
} from "@/lib/auth/authStorage";
import { ApiRequestOptions, ApiResponse } from "@/types/api.types";

const API_GATEWAY_URL = process.env.NEXT_PUBLIC_API_GATEWAY_URL;

if (!API_GATEWAY_URL) {
  throw new Error("La variable NEXT_PUBLIC_API_GATEWAY_URL no está configurada.");
}

function buildUrl(endpoint: string): string {
  const normalizedEndpoint = endpoint.startsWith("/")
    ? endpoint
    : `/${endpoint}`;

  return `${API_GATEWAY_URL}${normalizedEndpoint}`;
}

function redirectToLogin(): void {
  if (typeof window === "undefined") return;

  if (window.location.pathname !== "/login") {
    window.location.replace("/login");
  }
}

function buildFrontendError<T>(
  code: string,
  message: string,
  details?: unknown
): ApiResponse<T> {
  return {
    success: false,
    message,
    service: "front-end-web",
    trace_id: "frontend-local",
    timestamp: new Date().toISOString(),
    data: null as T,
    error: {
      code,
      details,
    },
  };
}

async function parseJsonResponse<T>(
  response: Response
): Promise<ApiResponse<T> | null> {
  const contentType = response.headers.get("content-type");

  if (!contentType?.includes("application/json")) {
    return null;
  }

  return (await response.json()) as ApiResponse<T>;
}

function shouldClearSession(
  response: Response,
  result: ApiResponse<unknown> | null
): boolean {
  const errorCode = result?.error?.code;

  return (
    response.status === 401 ||
    errorCode === "AUTH_TOKEN_EXPIRED" ||
    errorCode === "AUTH_INVALID_TOKEN" ||
    errorCode === "AUTH_UNAUTHORIZED"
  );
}

async function request<T>(
  endpoint: string,
  options: ApiRequestOptions = {}
): Promise<ApiResponse<T>> {
  const { auth = true, headers, ...restOptions } = options;

  const token = getToken();

  if (auth && isTokenExpired(token)) {
    clearAuthStorage();
    redirectToLogin();

    throw buildFrontendError<T>(
      "AUTH_TOKEN_EXPIRED",
      "Error AUTH_TOKEN_EXPIRED"
    );
  }

  const requestHeaders: HeadersInit = {
    "Content-Type": "application/json",
    ...headers,
  };

  const bearerToken = getBearerToken();

  if (auth && bearerToken) {
    requestHeaders.Authorization = bearerToken;
  }

  try {
    const response = await fetch(buildUrl(endpoint), {
      ...restOptions,
      headers: requestHeaders,
      cache: "no-store",
    });

    const result = await parseJsonResponse<T>(response);

    if (auth && shouldClearSession(response, result)) {
      clearAuthStorage();
      redirectToLogin();

      throw (
        result ??
        buildFrontendError<T>(
          "AUTH_UNAUTHORIZED",
          "Error AUTH_UNAUTHORIZED"
        )
      );
    }

    if (!result) {
      throw buildFrontendError<T>(
        "API_INVALID_RESPONSE",
        "Error API_INVALID_RESPONSE"
      );
    }

    if (!response.ok || !result.success) {
      throw result;
    }

    return result;
  } catch (error) {
    if (
      typeof error === "object" &&
      error !== null &&
      "success" in error &&
      "message" in error
    ) {
      throw error;
    }

    throw buildFrontendError<T>(
      "API_NETWORK_ERROR",
      "Error API_NETWORK_ERROR",
      error
    );
  }
}

export const apiClient = {
  get<T>(endpoint: string, options?: ApiRequestOptions): Promise<ApiResponse<T>> {
    return request<T>(endpoint, {
      ...options,
      method: "GET",
    });
  },

  post<T, B = unknown>(
    endpoint: string,
    body?: B,
    options?: ApiRequestOptions
  ): Promise<ApiResponse<T>> {
    return request<T>(endpoint, {
      ...options,
      method: "POST",
      body: body ? JSON.stringify(body) : undefined,
    });
  },

  put<T, B = unknown>(
    endpoint: string,
    body?: B,
    options?: ApiRequestOptions
  ): Promise<ApiResponse<T>> {
    return request<T>(endpoint, {
      ...options,
      method: "PUT",
      body: body ? JSON.stringify(body) : undefined,
    });
  },

  patch<T, B = unknown>(
    endpoint: string,
    body?: B,
    options?: ApiRequestOptions
  ): Promise<ApiResponse<T>> {
    return request<T>(endpoint, {
      ...options,
      method: "PATCH",
      body: body ? JSON.stringify(body) : undefined,
    });
  },

  delete<T>(
    endpoint: string,
    options?: ApiRequestOptions
  ): Promise<ApiResponse<T>> {
    return request<T>(endpoint, {
      ...options,
      method: "DELETE",
    });
  },
};