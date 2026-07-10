export interface Carrera {
  id_carrera: number;
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

export interface HorarioDocente {
  id_horario: number;
  id_docente: number;
  dia_semana: string;
  hora_inicio: string;
  hora_fin: string;
  activo: boolean;
}

export interface CrearHorarioRequest {
  id_docente: number;
  dia_semana: string;
  hora_inicio: string;
  hora_fin: string;
}