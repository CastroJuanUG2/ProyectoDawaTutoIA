export const APP_ROUTES = {
  LOGIN: "/login",
  DASHBOARD: "/dashboard",
  UNAUTHORIZED: "/unauthorized",

  ADMIN: "/admin",
  ADMIN_USUARIOS: "/admin/usuarios",
  ADMIN_ROLES: "/admin/roles",
  ADMIN_ACADEMICO: "/admin/academico",

  ESTUDIANTE: "/estudiante",
  ESTUDIANTE_SOLICITAR_TUTORIA: "/estudiante/tutorias/solicitar",
  ESTUDIANTE_HISTORIAL: "/estudiante/tutorias/historial",

  DOCENTE: "/docente",
  DOCENTE_SOLICITUDES: "/docente/solicitudes",
  DOCENTE_BITACORAS: "/docente/bitacoras",

  IA_CHAT: "/ia/chat",
  REPORTES: "/reportes",
};

export const API_ERROR_CODES = {
  AUTH_TOKEN_EXPIRED: "AUTH_TOKEN_EXPIRED",
  AUTH_INVALID_CREDENTIALS: "AUTH_INVALID_CREDENTIALS",
  AUTH_FORBIDDEN: "AUTH_FORBIDDEN",
  VALIDATION_ERROR: "VALIDATION_ERROR",
  INTERNAL_ERROR: "INTERNAL_ERROR",
};