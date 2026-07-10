from flask import Blueprint, request, g

from app.db.postgres import fetch_one_value
from app.utils.auth_guard import auth_required
from app.utils.responses import success_response, error_response

tutoring_bp = Blueprint("tutoring_bp", __name__)


@tutoring_bp.post("/tutorias/solicitudes")
@auth_required(["ESTUDIANTE", "ADMIN", "COORDINADOR"])
def crear_solicitud_tutoria():
    body = request.get_json(silent=True) or {}

    id_estudiante = body.get("id_estudiante")
    id_asignatura = body.get("id_asignatura")
    tema = body.get("tema")
    descripcion = body.get("descripcion", "")
    prioridad = body.get("prioridad", "media")
    origen = body.get("origen", "web")

    if not id_estudiante or not id_asignatura or not tema:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        solicitud = fetch_one_value(
            "SELECT dawa.sp_front_create_solicitud_tutoria(%s, %s, %s, %s, %s, %s);",
            (
                int(id_estudiante),
                int(id_asignatura),
                tema,
                descripcion,
                prioridad,
                origen,
            ),
        )

        return success_response(
            message="Solicitud de tutoría registrada correctamente",
            data=solicitud,
            status_code=201,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.get("/tutorias/estudiantes/<int:id_estudiante>/solicitudes")
@auth_required(["ESTUDIANTE", "ADMIN", "COORDINADOR"])
def listar_solicitudes_estudiante(id_estudiante):
    try:
        solicitudes = fetch_one_value(
            "SELECT dawa.sp_front_get_solicitudes_estudiante(%s);",
            (id_estudiante,),
        )

        return success_response(
            message="Solicitudes del estudiante obtenidas correctamente",
            data=solicitudes,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.get("/tutorias/docentes/<int:id_docente>/solicitudes")
@auth_required(["DOCENTE", "ADMIN", "COORDINADOR"])
def listar_solicitudes_docente(id_docente):
    try:
        solicitudes = fetch_one_value(
            "SELECT dawa.sp_front_get_solicitudes_docente(%s);",
            (id_docente,),
        )

        return success_response(
            message="Solicitudes del docente obtenidas correctamente",
            data=solicitudes,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.post("/tutorias/disponibilidad/validar")
@auth_required()
def validar_disponibilidad():
    body = request.get_json(silent=True) or {}

    id_horario = body.get("id_horario")
    fecha_tutoria = body.get("fecha_tutoria")

    if not id_horario or not fecha_tutoria:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        disponibilidad = fetch_one_value(
            "SELECT dawa.sp_front_validar_disponibilidad(%s, %s);",
            (int(id_horario), fecha_tutoria),
        )

        return success_response(
            message="Disponibilidad validada correctamente",
            data=disponibilidad,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.post("/tutorias")
@auth_required(["ADMIN", "COORDINADOR", "DOCENTE"])
def crear_tutoria():
    body = request.get_json(silent=True) or {}

    id_solicitud = body.get("id_solicitud")
    id_horario = body.get("id_horario")
    fecha_tutoria = body.get("fecha_tutoria")

    if not id_solicitud or not id_horario or not fecha_tutoria:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        tutoria = fetch_one_value(
            "SELECT dawa.sp_front_create_tutoria(%s, %s, %s);",
            (int(id_solicitud), int(id_horario), fecha_tutoria),
        )

        return success_response(
            message="Tutoría creada correctamente",
            data=tutoria,
            status_code=201,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.patch("/tutorias/<int:id_tutoria>/confirmar")
@auth_required(["DOCENTE", "ADMIN", "COORDINADOR"])
def confirmar_tutoria(id_tutoria):
    try:
        tutoria = fetch_one_value(
            "SELECT dawa.sp_front_confirmar_tutoria(%s);",
            (id_tutoria,),
        )

        return success_response(
            message="Tutoría confirmada correctamente",
            data=tutoria,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.patch("/tutorias/<int:id_tutoria>/cancelar")
@auth_required(["DOCENTE", "ADMIN", "COORDINADOR", "ESTUDIANTE"])
def cancelar_tutoria(id_tutoria):
    body = request.get_json(silent=True) or {}
    motivo = body.get("motivo_cancelacion", "Cancelada desde el sistema")

    try:
        tutoria = fetch_one_value(
            "SELECT dawa.sp_front_cancelar_tutoria(%s, %s);",
            (id_tutoria, motivo),
        )

        return success_response(
            message="Tutoría cancelada correctamente",
            data=tutoria,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@tutoring_bp.post("/tutorias/<int:id_tutoria>/bitacora")
@auth_required(["DOCENTE", "ADMIN", "COORDINADOR"])
def registrar_bitacora(id_tutoria):
    body = request.get_json(silent=True) or {}

    observaciones = body.get("observaciones")
    recomendaciones = body.get("recomendaciones", "")
    acuerdos = body.get("acuerdos")
    requiere_seguimiento = body.get("requiere_seguimiento", False)

    if not observaciones:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        bitacora = fetch_one_value(
            "SELECT dawa.sp_front_create_bitacora_tutoria(%s, %s, %s, %s, %s, %s);",
            (
                id_tutoria,
                g.current_user["id_usuario"],
                observaciones,
                recomendaciones,
                acuerdos,
                bool(requiere_seguimiento),
            ),
        )

        return success_response(
            message="Bitácora registrada correctamente",
            data=bitacora,
            status_code=201,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)