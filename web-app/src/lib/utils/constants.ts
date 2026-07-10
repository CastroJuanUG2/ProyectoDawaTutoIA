export const APP_ROUTES = {
  LOGIN: "/login",
  DASHBOARD: "/dashboard",
  UNAUTHORIZED: "/unauthorized",

  ADMIN: "/admin",
  ADMIN_ACADEMICO: "/admin/academico",
  ADMIN_CARRERAS: "/admin/academico/carreras",
  ADMIN_ASIGNATURAS: "/admin/academico/asignaturas",
  ADMIN_DOCENTES: "/admin/academico/docentes",
  ADMIN_HORARIOS: "/admin/academico/horarios",

  ESTUDIANTE: "/estudiante",
  ESTUDIANTE_SOLICITAR_TUTORIA: "/estudiante/tutorias/solicitar",
  ESTUDIANTE_HISTORIAL: "/estudiante/tutorias/historial",

  DOCENTE: "/docente",
  DOCENTE_SOLICITUDES: "/docente/solicitudes",
  DOCENTE_BITACORAS: "/docente/bitacoras",

  IA_CHAT: "/ia/chat",
};

export const API_ERROR_CODES = {
  AUTH_TOKEN_EXPIRED: "AUTH_TOKEN_EXPIRED",
  AUTH_INVALID_CREDENTIALS: "AUTH_INVALID_CREDENTIALS",
  AUTH_FORBIDDEN: "AUTH_FORBIDDEN",
  VALIDATION_ERROR: "VALIDATION_ERROR",
  INTERNAL_ERROR: "INTERNAL_ERROR",
};