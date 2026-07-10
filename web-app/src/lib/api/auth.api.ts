import { apiClient } from "@/lib/api/apiClient";
import { AuthUser, LoginRequest, LoginResponse } from "@/types/auth.types";

export const authApi = {
  login(payload: LoginRequest) {
    return apiClient.post<LoginResponse, LoginRequest>("/auth/login", payload, {
      auth: false,
    });
  },

  me() {
    return apiClient.get<AuthUser>("/auth/me");
  },

  logout() {
    return apiClient.post<null>("/auth/logout");
  },
};