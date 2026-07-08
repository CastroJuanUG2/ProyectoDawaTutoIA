const TOKEN_KEY = "dawa_access_token";
const USER_KEY = "dawa_auth_user";

export function saveToken(token: string): void {
  if (typeof window !== "undefined") {
    localStorage.setItem(TOKEN_KEY, token);
  }
}

export function getToken(): string | null {
  if (typeof window === "undefined") return null;
  return localStorage.getItem(TOKEN_KEY);
}

export function removeToken(): void {
  if (typeof window !== "undefined") {
    localStorage.removeItem(TOKEN_KEY);
  }
}

export function saveAuthUser<T>(user: T): void {
  if (typeof window !== "undefined") {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
  }
}

export function getAuthUser<T>(): T | null {
  if (typeof window === "undefined") return null;

  const storedUser = localStorage.getItem(USER_KEY);

  if (!storedUser) return null;

  try {
    return JSON.parse(storedUser) as T;
  } catch {
    localStorage.removeItem(USER_KEY);
    return null;
  }
}

export function removeAuthUser(): void {
  if (typeof window !== "undefined") {
    localStorage.removeItem(USER_KEY);
  }
}

export function clearAuthStorage(): void {
  removeToken();
  removeAuthUser();
}