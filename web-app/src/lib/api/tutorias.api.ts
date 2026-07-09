import { apiClient } from "@/lib/api/apiClient";
import {
  BitacoraTutoria,
  CrearBitacoraRequest,
  CrearSolicitudTutoriaRequest,
  EstadoTutoria,
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

  listarTutoriasDocente() {
    return apiClient.get<Tutoria[]>("/tutorias/docente");
  },

  cambiarEstado(idTutoria: number, estado: EstadoTutoria) {
    return apiClient.patch<Tutoria, { estado: EstadoTutoria }>(
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

  listarBitacorasDocente() {
    return apiClient.get<BitacoraTutoria[]>("/tutorias/bitacoras/docente");
  },
};