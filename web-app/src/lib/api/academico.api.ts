import { apiClient } from "@/lib/api/apiClient";
import {
  Asignatura,
  Carrera,
  CrearAsignaturaRequest,
  CrearCarreraRequest,
  CrearFacultadRequest,
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
    return apiClient.post<Carrera, CrearCarreraRequest>(
      "/carreras",
      payload
    );
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

  listarEstudiantes() {
    return apiClient.get<Estudiante[]>("/estudiantes");
  },

  listarHorariosDocente(idDocente: number) {
    return apiClient.get<HorarioDocente[]>(`/docentes/${idDocente}/horarios`);
  },
};