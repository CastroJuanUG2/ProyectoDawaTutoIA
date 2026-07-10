import { AuthUser } from "@/types/auth.types";

const TOKEN_KEY = "dawa_access_token";
const USER_KEY = "dawa_auth_user";
const SESSION_KEY = "dawa_auth_session";

interface StoredAuthSession {
  token: string;
  user: AuthUser;
  saved_at: string;
}

function isBrowser(): boolean {
  return typeof window !== "undefined";
}

function safeSetItem(key: string, value: string): void {
  if (!isBrowser()) return;

  try {
    localStorage.setItem(key, value);
  } catch {
    // Si localStorage falla, evitamos romper la app.
  }
}

function safeGetItem(key: string): string | null {
  if (!isBrowser()) return null;

  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}

function safeRemoveItem(key: string): void {
  if (!isBrowser()) return;

  try {
    localStorage.removeItem(key);
  } catch {
    // Si localStorage falla, no detenemos el flujo.
  }
}

function parseJson<T>(value: string | null): T | null {
  if (!value) return null;

  try {
    return JSON.parse(value) as T;
  } catch {
    return null;
  }
}

function normalizeToken(token: string): string {
  return token.replace(/^Bearer\s+/i, "").trim();
}

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  if (!isBrowser()) return null;

  const cleanToken = normalizeToken(token);
  const parts = cleanToken.split(".");

  if (parts.length !== 3) return null;

  try {
    const base64Url = parts[1];
    const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split("")
        .map((char) => `%${`00${char.charCodeAt(0).toString(16)}`.slice(-2)}`)
        .join("")
    );

    return JSON.parse(jsonPayload) as Record<string, unknown>;
  } catch {
    return null;
  }
}

export function isTokenExpired(token: string | null): boolean {
  if (!token) return true;

  const payload = decodeJwtPayload(token);
  const exp = payload?.exp;

  if (typeof exp !== "number") {
    return false;
  }

  const currentTimeInSeconds = Math.floor(Date.now() / 1000);

  return exp <= currentTimeInSeconds;
}

export function saveToken(token: string): void {
  const cleanToken = normalizeToken(token);
  safeSetItem(TOKEN_KEY, cleanToken);
}

export function getToken(): string | null {
  const token = safeGetItem(TOKEN_KEY);

  if (!token) return null;

  return normalizeToken(token);
}

export function getBearerToken(): string | null {
  const token = getToken();

  if (!token) return null;

  return `Bearer ${token}`;
}

export function removeToken(): void {
  safeRemoveItem(TOKEN_KEY);
}

export function saveAuthUser(user: AuthUser): void {
  const safeUser: AuthUser = {
    id_usuario: user.id_usuario,
    id_estudiante: user.id_estudiante ?? null,
    id_docente: user.id_docente ?? null,
    nombres: user.nombres,
    apellidos: user.apellidos,
    correo: user.correo,
    roles: user.roles,
  };

  safeSetItem(USER_KEY, JSON.stringify(safeUser));
}

export function getAuthUser(): AuthUser | null {
  const user = parseJson<AuthUser>(safeGetItem(USER_KEY));

  if (!user?.id_usuario || !user?.correo || !Array.isArray(user.roles)) {
    removeAuthUser();
    return null;
  }

  return user;
}

export function removeAuthUser(): void {
  safeRemoveItem(USER_KEY);
}

export function saveAuthSession(token: string, user: AuthUser): void {
  const cleanToken = normalizeToken(token);

  const session: StoredAuthSession = {
    token: cleanToken,
    user: {
      id_usuario: user.id_usuario,
      id_estudiante: user.id_estudiante ?? null,
      id_docente: user.id_docente ?? null,
      nombres: user.nombres,
      apellidos: user.apellidos,
      correo: user.correo,
      roles: user.roles,
    },
    saved_at: new Date().toISOString(),
  };

  saveToken(cleanToken);
  saveAuthUser(session.user);
  safeSetItem(SESSION_KEY, JSON.stringify(session));
}

export function getAuthSession(): StoredAuthSession | null {
  const session = parseJson<StoredAuthSession>(safeGetItem(SESSION_KEY));

  if (!session?.token || !session?.user) {
    return null;
  }

  if (isTokenExpired(session.token)) {
    clearAuthStorage();
    return null;
  }

  return session;
}

export function removeAuthSession(): void {
  safeRemoveItem(SESSION_KEY);
}

export function clearAuthStorage(): void {
  removeToken();
  removeAuthUser();
  removeAuthSession();
}