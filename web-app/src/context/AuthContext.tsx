"use client";

import {
  createContext,
  ReactNode,
  useContext,
  useEffect,
  useState,
} from "react";
import { authApi } from "@/lib/api/auth.api";
import {
  AuthUser,
  LoginRequest,
} from "@/types/auth.types";
import {
  clearAuthStorage,
  getAuthUser,
  getToken,
  saveAuthUser,
  saveToken,
} from "@/lib/auth/authStorage";
import { getDefaultRouteByRole } from "@/lib/auth/permissions";

interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (payload: LoginRequest) => Promise<string>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const storedToken = getToken();
    const storedUser = getAuthUser<AuthUser>();

    if (storedToken && storedUser) {
      setToken(storedToken);
      setUser(storedUser);
    }

    setIsLoading(false);
  }, []);

  async function login(payload: LoginRequest): Promise<string> {
    const response = await authApi.login(payload);

    const accessToken = response.data.access_token;
    const authUser = response.data.usuario;

    saveToken(accessToken);
    saveAuthUser(authUser);

    setToken(accessToken);
    setUser(authUser);

    return getDefaultRouteByRole(authUser.roles);
  }

  async function logout(): Promise<void> {
    try {
      await authApi.logout();
    } catch {
      // Aunque el backend falle, se limpia la sesión local.
    } finally {
      clearAuthStorage();
      setToken(null);
      setUser(null);
    }
  }

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: Boolean(user && token),
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
    throw new Error("useAuth debe usarse dentro de AuthProvider");
  }

  return context;
}