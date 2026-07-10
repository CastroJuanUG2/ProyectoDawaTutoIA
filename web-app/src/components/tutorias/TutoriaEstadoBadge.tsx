import { Badge } from "@/components/ui/Badge";
import { EstadoTutoria } from "@/types/tutoria.types";

interface TutoriaEstadoBadgeProps {
  estado: EstadoTutoria;
}

export function TutoriaEstadoBadge({ estado }: TutoriaEstadoBadgeProps) {
  const variantByEstado: Record<
    EstadoTutoria,
    "success" | "danger" | "warning" | "info" | "neutral"
  > = {
    SOLICITADA: "info",
    PENDIENTE: "warning",
    CONFIRMADA: "success",
    ATENDIDA: "success",
    CANCELADA: "danger",
    NO_ASISTIDA: "danger",
  };

  return <Badge variant={variantByEstado[estado]}>{estado}</Badge>;
}