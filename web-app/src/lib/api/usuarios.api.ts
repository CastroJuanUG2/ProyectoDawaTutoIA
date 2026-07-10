import { apiClient } from "@/lib/api/apiClient";
import {
  ActualizarUsuarioRequest,
  CrearUsuarioRequest,
  Usuario,
} from "@/types/usuario.types";

export const usuariosApi = {
  listar() {
    return apiClient.get<Usuario[]>("/usuarios");
  },

  obtenerPorId(idUsuario: number) {
    return apiClient.get<Usuario>(`/usuarios/${idUsuario}`);
  },

  crear(payload: CrearUsuarioRequest) {
    return apiClient.post<Usuario, CrearUsuarioRequest>("/usuarios", payload);
  },

  actualizar(idUsuario: number, payload: ActualizarUsuarioRequest) {
    return apiClient.put<Usuario, ActualizarUsuarioRequest>(
      `/usuarios/${idUsuario}`,
      payload
    );
  },

  eliminar(idUsuario: number) {
    return apiClient.delete<null>(`/usuarios/${idUsuario}`);
  },
};