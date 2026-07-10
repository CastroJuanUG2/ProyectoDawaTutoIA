export type UserRole = "ADMIN" | "COORDINADOR" | "DOCENTE" | "ESTUDIANTE";

export interface AuthUser {
  id_usuario: number;
  id_estudiante?: number;
  id_docente?: number;
  nombres: string;
  apellidos: string;
  correo: string;
  roles: UserRole[];
}

export interface LoginRequest {
  correo: string;
  password: string;
}

export interface LoginResponse {
  access_token: string;
  token_type: "Bearer";
  usuario: AuthUser;
}