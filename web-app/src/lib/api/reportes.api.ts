import { apiClient } from "@/lib/api/apiClient";
import { DashboardReportesResponse } from "@/types/reporte.types";

export const reportesApi = {
  obtenerDashboard() {
    return apiClient.get<DashboardReportesResponse>("/reportes/dashboard");
  },
};