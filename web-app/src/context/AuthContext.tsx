"use client";

import {
  createContext,
  ReactNode,
  useContext,
  useEffect,
  useState,
} from "react";
import { authApi } from "@/lib/api/auth.api";
import { AuthUser, LoginRequest } from "@/types/auth.types";
import {
  clearAuthStorage,
  getAuthSession,
  getToken,
  isTokenExpired,
  saveAuthSession,
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
  refreshUser: () => Promise<void>;
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
    async function loadSession() {
      const storedSession = getAuthSession();

      if (!storedSession) {
        clearAuthStorage();
        setUser(null);
        setToken(null);
        setIsLoading(false);
        return;
      }

      if (isTokenExpired(storedSession.token)) {
        clearAuthStorage();
        setUser(null);
        setToken(null);
        setIsLoading(false);
        return;
      }

      setToken(storedSession.token);
      setUser(storedSession.user);

      try {
        const response = await authApi.me();

        saveAuthSession(storedSession.token, response.data);
        setUser(response.data);
      } catch {
        clearAuthStorage();
        setUser(null);
        setToken(null);
      } finally {
        setIsLoading(false);
      }
    }

    loadSession();
  }, []);

  async function login(payload: LoginRequest): Promise<string> {
    const loginResponse = await authApi.login(payload);

    const accessToken = loginResponse.data.access_token;

    saveToken(accessToken);
    setToken(accessToken);

    try {
      const meResponse = await authApi.me();
      const authUser = meResponse.data;

      saveAuthSession(accessToken, authUser);
      setUser(authUser);

      return getDefaultRouteByRole(authUser.roles);
    } catch (error) {
      clearAuthStorage();
      setUser(null);
      setToken(null);
      throw error;
    }
  }

  async function refreshUser(): Promise<void> {
    const currentToken = getToken();

    if (!currentToken || isTokenExpired(currentToken)) {
      clearAuthStorage();
      setUser(null);
      setToken(null);
      return;
    }

    const response = await authApi.me();

    saveAuthSession(currentToken, response.data);
    setUser(response.data);
    setToken(currentToken);
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
        refreshUser,
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