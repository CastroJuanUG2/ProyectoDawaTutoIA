"use client";

import { createContext, ReactNode, useContext,useEffect, useState} from "react";
import { useRouter } from "next/navigation";
import { authApi } from "@/lib/api/auth.api";
import { clearAuthStorage, getAuthUser, getToken, saveAuthUser, saveToken} from "@/lib/auth/authStorage";
import { getDefaultRouteByRole } from "@/lib/auth/permissions";
import { AuthUser, LoginRequest } from "@/types/auth.types";
import { ApiResponse } from "@/types/api.types";
import { getApiErrorMessage, logApiTrace } from "@/lib/utils/handleApiError";

interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (payload: LoginRequest) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export function AuthProvider({ children }: AuthProviderProps) {
  const router = useRouter();

  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const isAuthenticated = Boolean(user && token);

  useEffect(() => {
    const storedToken = getToken();
    const storedUser = getAuthUser<AuthUser>();

    if (storedToken && storedUser) {
      setToken(storedToken);
      setUser(storedUser);
    }

    setIsLoading(false);
  }, []);

  async function login(payload: LoginRequest): Promise<void> {
    setIsLoading(true);

    try {
      const response = await authApi.login(payload);

      const accessToken = response.data.access_token;
      const authUser = response.data.usuario;

      saveToken(accessToken);
      saveAuthUser(authUser);

      setToken(accessToken);
      setUser(authUser);

      const defaultRoute = getDefaultRouteByRole(authUser.roles);
      router.push(defaultRoute);
    } catch (error) {
      const apiError = error as ApiResponse<unknown>;

      if (apiError?.trace_id) {
        logApiTrace(apiError);
      }

      throw new Error(getApiErrorMessage(apiError));
    } finally {
      setIsLoading(false);
    }
  }

  function logout(): void {
    clearAuthStorage();

    setToken(null);
    setUser(null);

    router.push("/login");
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated,
        isLoading,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error("useAuth debe usarse dentro de AuthProvider.");
  }

  return context;
}