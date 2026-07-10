import { ApiResponse } from "@/types/api.types";
import { AuthUser, UserRole } from "@/types/auth.types";

const VALID_ROLES: UserRole[] = [
  "ADMIN",
  "COORDINADOR",
  "DOCENTE",
  "ESTUDIANTE",
];

function buildAuthError(code: string, details?: unknown): ApiResponse<never> {
  return {
    success: false,
    message: `Error ${code}`,
    service: "front-end-web",
    trace_id: "frontend-auth-normalizer",
    timestamp: new Date().toISOString(),
    data: null as never,
    error: {
      code,
      details,
    },
  };
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function unwrapUserPayload(payload: unknown): Record<string, unknown> {
  if (!isObject(payload)) {
    throw buildAuthError("AUTH_USER_INVALID_RESPONSE", payload);
  }

  if (isObject(payload.usuario)) {
    return payload.usuario;
  }

  if (isObject(payload.user)) {
    return payload.user;
  }

  return payload;
}

function normalizeNumber(value: unknown): number | null {
  if (value === null || value === undefined || value === "") {
    return null;
  }

  const numberValue = Number(value);

  return Number.isFinite(numberValue) ? numberValue : null;
}

function normalizeString(value: unknown): string {
  if (typeof value === "string") {
    return value;
  }

  if (value === null || value === undefined) {
    return "";
  }

  return String(value);
}

function normalizeRoles(value: unknown): UserRole[] {
  if (Array.isArray(value)) {
    return value
      .map((role) => String(role).trim().toUpperCase())
      .filter((role): role is UserRole =>
        VALID_ROLES.includes(role as UserRole)
      );
  }

  if (typeof value === "string") {
    return value
      .split(/[,\s;|]+/)
      .map((role) => role.trim().toUpperCase())
      .filter((role): role is UserRole =>
        VALID_ROLES.includes(role as UserRole)
      );
  }

  return [];
}

export function normalizeAuthUser(payload: unknown): AuthUser {
  const userPayload = unwrapUserPayload(payload);

  const idUsuario =
    normalizeNumber(userPayload.id_usuario) ??
    normalizeNumber(userPayload.id) ??
    normalizeNumber(userPayload.user_id);

  if (!idUsuario) {
    throw buildAuthError("AUTH_USER_ID_MISSING", payload);
  }

  const rawRoles =
    userPayload.roles ??
    userPayload.rol ??
    userPayload.role ??
    userPayload.perfiles;

  const roles = normalizeRoles(rawRoles);

  if (roles.length === 0) {
    throw buildAuthError("AUTH_USER_ROLES_MISSING", payload);
  }

  const nombres =
    normalizeString(userPayload.nombres) ||
    normalizeString(userPayload.nombre) ||
    normalizeString(userPayload.name);

  const apellidos =
    normalizeString(userPayload.apellidos) ||
    normalizeString(userPayload.apellido);

  const correo =
    normalizeString(userPayload.correo) ||
    normalizeString(userPayload.email);

  return {
    id_usuario: idUsuario,
    id_estudiante: normalizeNumber(userPayload.id_estudiante),
    id_docente: normalizeNumber(userPayload.id_docente),
    nombres,
    apellidos,
    correo,
    roles,
  };
}