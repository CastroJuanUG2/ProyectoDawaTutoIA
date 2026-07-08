import { apiClient } from "@/lib/api/apiClient";
import {
  Asignatura,
  Carrera,
  Docente,
  Estudiante,
  Facultad,
  HorarioDocente,
} from "@/types/academico.types";

export const academicoApi = {
  listarFacultades() {
    return apiClient.get<Facultad[]>("/facultades");
  },

  listarCarreras() {
    return apiClient.get<Carrera[]>("/carreras");
  },

  listarAsignaturas() {
    return apiClient.get<Asignatura[]>("/asignaturas");
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