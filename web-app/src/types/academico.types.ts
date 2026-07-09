export interface Facultad {
  id_facultad: number;
  nombre: string;
  codigo: string;
  activo: boolean;
}

export interface Carrera {
  id_carrera: number;
  id_facultad: number;
  nombre: string;
  codigo: string;
  activo: boolean;
}

export interface Asignatura {
  id_asignatura: number;
  id_carrera: number;
  nombre: string;
  codigo: string;
  nivel: string;
  activo: boolean;
}

export interface Docente {
  id_docente: number;
  id_usuario: number;
  nombres: string;
  apellidos: string;
  correo: string;
  especialidad?: string;
  activo: boolean;
}

export interface Estudiante {
  id_estudiante: number;
  id_usuario: number;
  id_carrera: number;
  nombres: string;
  apellidos: string;
  correo: string;
  matricula: string;
  activo: boolean;
}

export type DiaSemana =
  | "LUNES"
  | "MARTES"
  | "MIERCOLES"
  | "JUEVES"
  | "VIERNES"
  | "SABADO"
  | "DOMINGO";

export interface HorarioDocente {
  id_horario: number;
  id_docente: number;
  dia_semana: DiaSemana;
  hora_inicio: string;
  hora_fin: string;
  activo: boolean;
}

export interface CrearFacultadRequest {
  nombre: string;
  codigo: string;
}

export interface CrearCarreraRequest {
  id_facultad: number;
  nombre: string;
  codigo: string;
}

export interface CrearAsignaturaRequest {
  id_carrera: number;
  nombre: string;
  codigo: string;
  nivel: string;
}

export interface CrearDocenteRequest {
  id_usuario: number;
  especialidad?: string;
}

export interface CrearEstudianteRequest {
  id_usuario: number;
  id_carrera: number;
  matricula: string;
}

export interface CrearHorarioDocenteRequest {
  id_docente: number;
  dia_semana: DiaSemana;
  hora_inicio: string;
  hora_fin: string;
}