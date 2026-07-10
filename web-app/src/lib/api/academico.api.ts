import { apiClient } from "@/lib/api/apiClient";
import {
  Asignatura,
  Carrera,
  CrearHorarioRequest,
  Docente,
  HorarioDocente,
} from "@/types/academico.types";

export const academicoApi = {
  listarCarreras() {
    return apiClient.get<Carrera[]>("/academico/carreras");
  },

  listarAsignaturas() {
    return apiClient.get<Asignatura[]>("/academico/asignaturas");
  },

  listarDocentes() {
    return apiClient.get<Docente[]>("/academico/docentes");
  },

  listarHorariosDocente(idDocente: number) {
    return apiClient.get<HorarioDocente[]>(
      `/academico/docentes/${idDocente}/horarios`
    );
  },

  crearHorario(payload: CrearHorarioRequest) {
    return apiClient.post<HorarioDocente, CrearHorarioRequest>(
      "/academico/horarios",
      payload
    );
  },
};