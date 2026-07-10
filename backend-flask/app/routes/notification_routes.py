from flask import Blueprint, request, g

from app.db.postgres import fetch_one_value
from app.utils.auth_guard import auth_required
from app.utils.responses import success_response, error_response

notification_bp = Blueprint("notification_bp", __name__)


def parse_bool(value: str | None) -> bool:
    if value is None:
        return False

    return value.lower() in ["true", "1", "yes", "si", "sí"]


@notification_bp.get("/notificaciones")
@auth_required()
def listar_notificaciones():
    solo_no_leidas = parse_bool(request.args.get("solo_no_leidas"))

    try:
        notificaciones = fetch_one_value(
            "SELECT dawa.sp_get_notificaciones_usuario(%s, %s);",
            (
                g.current_user["id_usuario"],
                solo_no_leidas,
            ),
        )

        return success_response(
            message="Notificaciones obtenidas correctamente",
            data=notificaciones,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@notification_bp.patch("/notificaciones/<int:id_notificacion>/leer")
@auth_required()
def marcar_notificacion_leida(id_notificacion):
    try:
        notificacion = fetch_one_value(
            "SELECT dawa.sp_front_marcar_notificacion_leida(%s, %s);",
            (
                id_notificacion,
                g.current_user["id_usuario"],
            ),
        )

        if not notificacion or not notificacion.get("id_notificacion"):
            return error_response("NOTIFICATION_NOT_FOUND", status_code=404)

        return success_response(
            message="Notificación marcada como leída correctamente",
            data=notificacion,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)