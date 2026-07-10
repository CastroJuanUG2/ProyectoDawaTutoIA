import { UserRole } from "@/types/auth.types";

export interface Usuario {
  id_usuario: number;
  nombres: string;
  apellidos: string;
  correo: string;
  activo: boolean;
  roles: UserRole[];
  creado_en: string;
}

export interface CrearUsuarioRequest {
  nombres: string;
  apellidos: string;
  correo: string;
  password: string;
  roles: UserRole[];
}

export interface ActualizarUsuarioRequest {
  nombres?: string;
  apellidos?: string;
  correo?: string;
  activo?: boolean;
  roles?: UserRole[];
}