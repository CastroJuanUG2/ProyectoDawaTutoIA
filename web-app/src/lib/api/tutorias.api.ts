import { apiClient } from "@/lib/api/apiClient";
import {
  BitacoraTutoria,
  CrearBitacoraRequest,
  CrearSolicitudTutoriaRequest,
  CrearTutoriaRequest,
  SolicitudTutoria,
  Tutoria,
  ValidarDisponibilidadRequest,
  ValidarDisponibilidadResponse,
} from "@/types/tutoria.types";

export const tutoriasApi = {
  crearSolicitud(payload: CrearSolicitudTutoriaRequest) {
    return apiClient.post<SolicitudTutoria, CrearSolicitudTutoriaRequest>(
      "/tutorias/solicitudes",
      payload
    );
  },

  listarSolicitudesEstudiante(idEstudiante: number) {
    return apiClient.get<SolicitudTutoria[]>(
      `/tutorias/estudiantes/${idEstudiante}/solicitudes`
    );
  },

  listarSolicitudesDocente(idDocente: number) {
    return apiClient.get<Tutoria[]>(
      `/tutorias/docentes/${idDocente}/solicitudes`
    );
  },

  validarDisponibilidad(payload: ValidarDisponibilidadRequest) {
    return apiClient.post<
      ValidarDisponibilidadResponse,
      ValidarDisponibilidadRequest
    >("/tutorias/disponibilidad/validar", payload);
  },

  crearTutoria(payload: CrearTutoriaRequest) {
    return apiClient.post<Tutoria, CrearTutoriaRequest>("/tutorias", payload);
  },

  confirmarTutoria(idTutoria: number) {
    return apiClient.patch<Tutoria>(`/tutorias/${idTutoria}/confirmar`);
  },

  cancelarTutoria(idTutoria: number) {
    return apiClient.patch<Tutoria>(`/tutorias/${idTutoria}/cancelar`);
  },

  registrarBitacora(idTutoria: number, payload: CrearBitacoraRequest) {
      return apiClient.post<BitacoraTutoria, CrearBitacoraRequest>(
        `/tutorias/${idTutoria}/bitacora`,
        payload
      );
  },
};