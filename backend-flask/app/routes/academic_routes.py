from flask import Blueprint, request

from app.db.postgres import fetch_one_value, jsonb_payload
from app.utils.auth_guard import auth_required
from app.utils.responses import success_response, error_response

academic_bp = Blueprint("academic_bp", __name__)


@academic_bp.get("/academico/carreras")
@auth_required()
def listar_carreras():
    try:
        carreras = fetch_one_value(
            "SELECT dawa.sp_list_carreras(%s, %s);",
            (100, 0),
        )

        return success_response(
            message="Carreras obtenidas correctamente",
            data=carreras,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@academic_bp.get("/academico/asignaturas")
@auth_required()
def listar_asignaturas():
    try:
        asignaturas = fetch_one_value(
            "SELECT dawa.sp_list_asignaturas(%s, %s);",
            (100, 0),
        )

        return success_response(
            message="Asignaturas obtenidas correctamente",
            data=asignaturas,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@academic_bp.get("/academico/docentes")
@auth_required()
def listar_docentes():
    try:
        docentes = fetch_one_value(
            "SELECT dawa.sp_front_list_docentes();",
        )

        return success_response(
            message="Docentes obtenidos correctamente",
            data=docentes,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@academic_bp.get("/academico/docentes/<int:id_docente>/horarios")
@auth_required()
def listar_horarios_docente(id_docente):
    try:
        horarios = fetch_one_value(
            "SELECT dawa.sp_front_get_horarios_docente(%s);",
            (id_docente,),
        )

        return success_response(
            message="Horarios del docente obtenidos correctamente",
            data=horarios,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@academic_bp.post("/academico/horarios")
@auth_required(["ADMIN", "COORDINADOR", "DOCENTE"])
def crear_horario_docente():
    body = request.get_json(silent=True) or {}

    id_docente = body.get("id_docente")
    id_periodo = body.get("id_periodo")
    dia_semana = body.get("dia_semana")
    hora_inicio = body.get("hora_inicio")
    hora_fin = body.get("hora_fin")
    modalidad = body.get("modalidad", "virtual")

    if not id_docente or not dia_semana or not hora_inicio or not hora_fin:
        return error_response("VALIDATION_REQUIRED_FIELDS", status_code=400)

    try:
        if not id_periodo:
            periodo_actual = fetch_one_value(
                "SELECT dawa.sp_front_get_periodo_actual();",
            )

            if not periodo_actual or not periodo_actual.get("id_periodo"):
                return error_response("ACADEMIC_PERIODO_NOT_FOUND", status_code=404)

            id_periodo = periodo_actual["id_periodo"]

        payload = {
            "id_docente": int(id_docente),
            "id_periodo": int(id_periodo),
            "dia_semana": str(dia_semana).lower(),
            "hora_inicio": hora_inicio,
            "hora_fin": hora_fin,
            "modalidad": str(modalidad).lower(),
            "estado": True,
        }

        horario = fetch_one_value(
            "SELECT dawa.sp_create_horarios_docente(%s::jsonb);",
            (jsonb_payload(payload),),
        )

        return success_response(
            message="Horario docente registrado correctamente",
            data=horario,
            status_code=201,
        )
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)