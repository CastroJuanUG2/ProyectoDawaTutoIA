import { apiClient } from "@/lib/api/apiClient";
import {
  BitacoraTutoria,
  CrearBitacoraRequest,
  CrearSolicitudTutoriaRequest,
  SolicitudTutoria,
  Tutoria,
} from "@/types/tutoria.types";

export const tutoriasApi = {
  crearSolicitud(payload: CrearSolicitudTutoriaRequest) {
    return apiClient.post<SolicitudTutoria, CrearSolicitudTutoriaRequest>(
      "/tutorias/solicitudes",
      payload
    );
  },

  listarMisSolicitudes() {
    return apiClient.get<SolicitudTutoria[]>("/tutorias/solicitudes/mis");
  },

  listarHistorialEstudiante() {
    return apiClient.get<Tutoria[]>("/tutorias/historial/estudiante");
  },

  listarSolicitudesDocente() {
    return apiClient.get<SolicitudTutoria[]>("/tutorias/solicitudes/docente");
  },

  cambiarEstado(idTutoria: number, estado: string) {
    return apiClient.patch<Tutoria, { estado: string }>(
      `/tutorias/${idTutoria}/estado`,
      { estado }
    );
  },

  crearBitacora(payload: CrearBitacoraRequest) {
    return apiClient.post<BitacoraTutoria, CrearBitacoraRequest>(
      "/tutorias/bitacoras",
      payload
    );
  },
};