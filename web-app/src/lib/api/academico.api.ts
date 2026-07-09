import { apiClient } from "@/lib/api/apiClient";
import {
  Asignatura,
  Carrera,
  CrearAsignaturaRequest,
  CrearCarreraRequest,
  CrearDocenteRequest,
  CrearEstudianteRequest,
  CrearFacultadRequest,
  CrearHorarioDocenteRequest,
  Docente,
  Estudiante,
  Facultad,
  HorarioDocente,
} from "@/types/academico.types";

export const academicoApi = {
  listarFacultades() {
    return apiClient.get<Facultad[]>("/facultades");
  },

  crearFacultad(payload: CrearFacultadRequest) {
    return apiClient.post<Facultad, CrearFacultadRequest>(
      "/facultades",
      payload
    );
  },

  listarCarreras() {
    return apiClient.get<Carrera[]>("/carreras");
  },

  crearCarrera(payload: CrearCarreraRequest) {
    return apiClient.post<Carrera, CrearCarreraRequest>("/carreras", payload);
  },

  listarAsignaturas() {
    return apiClient.get<Asignatura[]>("/asignaturas");
  },

  crearAsignatura(payload: CrearAsignaturaRequest) {
    return apiClient.post<Asignatura, CrearAsignaturaRequest>(
      "/asignaturas",
      payload
    );
  },

  listarDocentes() {
    return apiClient.get<Docente[]>("/docentes");
  },

  crearDocente(payload: CrearDocenteRequest) {
    return apiClient.post<Docente, CrearDocenteRequest>("/docentes", payload);
  },

  listarEstudiantes() {
    return apiClient.get<Estudiante[]>("/estudiantes");
  },

  crearEstudiante(payload: CrearEstudianteRequest) {
    return apiClient.post<Estudiante, CrearEstudianteRequest>(
      "/estudiantes",
      payload
    );
  },

  listarHorarios() {
    return apiClient.get<HorarioDocente[]>("/horarios-docente");
  },

  crearHorarioDocente(payload: CrearHorarioDocenteRequest) {
    return apiClient.post<HorarioDocente, CrearHorarioDocenteRequest>(
      "/horarios-docente",
      payload
    );
  },

  listarHorariosDocente(idDocente: number) {
    return apiClient.get<HorarioDocente[]>(`/docentes/${idDocente}/horarios`);
  },
};