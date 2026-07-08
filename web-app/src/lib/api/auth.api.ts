import { apiClient } from "@/lib/api/apiClient";
import { LoginRequest, LoginResponse } from "@/types/auth.types";

export const authApi = {
  login(payload: LoginRequest) {
    return apiClient.post<LoginResponse, LoginRequest>("/auth/login", payload, {
      auth: false,
    });
  },

  logout() {
    return apiClient.post<null>("/auth/logout");
  },

  validarToken() {
    return apiClient.get<{ valido: boolean }>("/auth/validar-token");
  },
};