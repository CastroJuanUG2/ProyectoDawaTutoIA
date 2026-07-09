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

export interface HorarioDocente {
  id_horario: number;
  id_docente: number;
  dia_semana: string;
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