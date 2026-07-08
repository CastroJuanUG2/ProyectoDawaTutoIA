import { getToken } from "@/lib/auth/authStorage";
import { ApiRequestOptions, ApiResponse } from "@/types/api.types";

const API_GATEWAY_URL = process.env.NEXT_PUBLIC_API_GATEWAY_URL;

if (!API_GATEWAY_URL) {
  throw new Error("No se puede establecer conexión con el sistema");
}

async function request<T>(
  endpoint: string,
  options: ApiRequestOptions = {}
): Promise<ApiResponse<T>> {
  const { auth = true, headers, ...restOptions } = options;

  const token = getToken();

  const requestHeaders: HeadersInit = {
    "Content-Type": "application/json",
    ...headers,
  };

  if (auth && token) {
    requestHeaders.Authorization = `Bearer ${token}`;
  }

  const url = `${API_GATEWAY_URL}${endpoint}`;

  const response = await fetch(url, {
    ...restOptions,
    headers: requestHeaders,
  });

  const result = (await response.json()) as ApiResponse<T>;

  if (!response.ok || !result.success) {
    throw result;
  }

  return result;
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