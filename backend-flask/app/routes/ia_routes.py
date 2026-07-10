from flask import Blueprint, request, g

from app.db.postgres import fetch_one_value
from app.utils.auth_guard import auth_required
from app.utils.responses import success_response, error_response

ia_bp = Blueprint("ia_bp", __name__)


def is_admin_like() -> bool:
    roles = g.current_user.get("roles", [])
    return any(role in roles for role in ["ADMIN", "COORDINADOR"])


@ia_bp.post("/ia/chat")
@auth_required()
def chat_ia():
    body = request.get_json(silent=True) or {}

    mensaje = body.get("mensaje")
    id_conversacion = body.get("id_conversacion")
    contexto = body.get("contexto", "general")

    if not mensaje:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        respuesta = fetch_one_value(
            "SELECT dawa.sp_front_ia_chat(%s, %s, %s, %s);",
            (
                g.current_user["id_usuario"],
                mensaje,
                int(id_conversacion) if id_conversacion else None,
                contexto,
            ),
        )

        return success_response(
            message="Respuesta del agente IA generada correctamente",
            data=respuesta,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@ia_bp.get("/ia/usuarios/<int:id_usuario>/historial")
@auth_required()
def historial_ia_usuario(id_usuario):
    if not is_admin_like() and g.current_user["id_usuario"] != id_usuario:
        return error_response("AUTH_FORBIDDEN", status_code=403)

    try:
        historial = fetch_one_value(
            "SELECT dawa.sp_front_ia_historial_usuario(%s);",
            (id_usuario,),
        )

        return success_response(
            message="Historial IA obtenido correctamente",
            data=historial,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@ia_bp.post("/ia/mensajes/<int:id_mensaje>/feedback")
@auth_required()
def registrar_feedback_ia(id_mensaje):
    body = request.get_json(silent=True) or {}

    util = body.get("util")
    comentario = body.get("comentario")

    if util is None:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        feedback = fetch_one_value(
            "SELECT dawa.sp_front_ia_feedback(%s, %s, %s, %s);",
            (
                id_mensaje,
                g.current_user["id_usuario"],
                bool(util),
                comentario,
            ),
        )

        return success_response(
            message="Feedback IA registrado correctamente",
            data=feedback,
            status_code=201,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@ia_bp.post("/ia/clasificar-solicitud")
@auth_required(["ADMIN", "COORDINADOR", "DOCENTE"])
def clasificar_solicitud_ia():
    body = request.get_json(silent=True) or {}
    id_solicitud = body.get("id_solicitud")

    if not id_solicitud:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        clasificacion = fetch_one_value(
            "SELECT dawa.sp_front_ia_clasificar_solicitud(%s);",
            (int(id_solicitud),),
        )

        return success_response(
            message="Solicitud clasificada correctamente por IA",
            data=clasificacion,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@ia_bp.post("/ia/sugerir-docente")
@auth_required(["ADMIN", "COORDINADOR", "DOCENTE", "ESTUDIANTE"])
def sugerir_docente_ia():
    body = request.get_json(silent=True) or {}
    id_asignatura = body.get("id_asignatura")

    if not id_asignatura:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        docentes = fetch_one_value(
            "SELECT dawa.sp_front_ia_sugerir_docente(%s);",
            (int(id_asignatura),),
        )

        return success_response(
            message="Docentes sugeridos correctamente por IA",
            data=docentes,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)