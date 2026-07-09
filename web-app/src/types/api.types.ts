export interface ApiErrorDetail {
  code: string;
  details?: unknown;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  service: string;
  trace_id: string;
  timestamp: string;
  data: T;
  error?: ApiErrorDetail;
}

export interface ApiRequestOptions extends RequestInit {
  auth?: boolean;
}

export interface ApiErrorDetail {
  code: string;
  details?: unknown;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  service: string;
  trace_id: string;
  timestamp: string;
  data: T;
  error?: ApiErrorDetail;
}

export interface ApiRequestOptions extends RequestInit {
  auth?: boolean;
}