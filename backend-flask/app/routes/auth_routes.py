import jwt
from flask import Blueprint, request
from werkzeug.security import check_password_hash

from app.db.postgres import fetch_one_value
from app.utils.jwt_utils import (
    create_access_token,
    decode_access_token,
    get_bearer_token,
)
from app.utils.responses import success_response, error_response


auth_bp = Blueprint("auth_bp", __name__)


def normalize_auth_user(usuario: dict, roles: list, permisos: list | None = None) -> dict:
    return {
        "id_usuario": usuario["id_usuario"],
        "nombres": usuario["nombres"],
        "apellidos": usuario["apellidos"],
        "correo": usuario["correo"],
        "roles": roles,
        "permisos": permisos or [],
        "activo": usuario.get("estado_usuario") == "activo",
        "estado_usuario": usuario.get("estado_usuario"),
    }


@auth_bp.post("/auth/login")
def login():
    body = request.get_json(silent=True) or {}

    correo = body.get("correo")
    password = body.get("password")

    if not correo or not password:
        return error_response("AUTH_MISSING_CREDENTIALS", status_code=400)

    try:
        auth_data = fetch_one_value(
            "SELECT dawa.sp_auth_login_lookup(%s);",
            (correo,),
        )

        if not auth_data:
            return error_response("AUTH_INVALID_CREDENTIALS", status_code=401)

        usuario = auth_data.get("usuario")
        password_hash = auth_data.get("password_hash")
        roles = auth_data.get("roles", [])
        permisos = auth_data.get("permisos", [])

        if not usuario or not password_hash:
            return error_response("AUTH_INVALID_CREDENTIALS", status_code=401)

        if usuario.get("estado_usuario") == "bloqueado":
            return error_response("AUTH_USER_BLOCKED", status_code=403)

        if usuario.get("estado_usuario") != "activo":
            return error_response("AUTH_USER_INACTIVE", status_code=403)

        if not check_password_hash(password_hash, password):
            return error_response("AUTH_INVALID_CREDENTIALS", status_code=401)

        auth_user = normalize_auth_user(usuario, roles, permisos)

        access_token = create_access_token(auth_user)

        fetch_one_value(
            "SELECT dawa.sp_auth_actualizar_ultimo_acceso(%s);",
            (usuario["id_usuario"],),
        )

        return success_response(
            message="Inicio de sesión correcto",
            data={
                "access_token": access_token,
                "token_type": "Bearer",
                "usuario": auth_user,
            },
        )

    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@auth_bp.get("/auth/me")
def me():
    authorization_header = request.headers.get("Authorization")
    token = get_bearer_token(authorization_header)

    if not token:
        return error_response("AUTH_TOKEN_REQUIRED", status_code=401)

    try:
        payload = decode_access_token(token)
    except jwt.ExpiredSignatureError:
        return error_response("AUTH_TOKEN_EXPIRED", status_code=401)
    except jwt.InvalidTokenError:
        return error_response("AUTH_TOKEN_INVALID", status_code=401)

    try:
        contexto = fetch_one_value(
            "SELECT dawa.sp_get_usuario_contexto(%s);",
            (int(payload["sub"]),),
        )

        if not contexto or not contexto.get("usuario"):
            return error_response("AUTH_USER_NOT_FOUND", status_code=404)

        usuario = contexto.get("usuario")
        roles = contexto.get("roles", [])

        auth_user = normalize_auth_user(usuario, roles)

        return success_response(
            message="Usuario autenticado obtenido correctamente",
            data={
                "usuario": auth_user,
                "contexto": {
                    "docente": contexto.get("docente", {}),
                    "estudiante": contexto.get("estudiante", {}),
                },
            },
        )

    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)


@auth_bp.post("/auth/logout")
def logout():
    authorization_header = request.headers.get("Authorization")
    token = get_bearer_token(authorization_header)

    if not token:
        return error_response("AUTH_TOKEN_REQUIRED", status_code=401)

    try:
        payload = decode_access_token(token)

        fetch_one_value(
            "SELECT dawa.sp_auth_registrar_evento_acceso(%s, %s, %s, %s);",
            (
                int(payload["sub"]),
                "logout",
                request.remote_addr,
                request.headers.get("User-Agent"),
            ),
        )

        return success_response(
            message="Sesión cerrada correctamente",
            data=None,
        )

    except jwt.ExpiredSignatureError:
        return error_response("AUTH_TOKEN_EXPIRED", status_code=401)
    except jwt.InvalidTokenError:
        return error_response("AUTH_TOKEN_INVALID", status_code=401)
    except Exception:
        return error_response("DATABASE_QUERY_ERROR", status_code=500)