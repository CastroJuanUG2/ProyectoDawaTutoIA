from functools import wraps
import jwt
from flask import request, g

from app.utils.jwt_utils import decode_access_token, get_bearer_token
from app.utils.responses import error_response


def auth_required(allowed_roles=None):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
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

            user_roles = payload.get("roles", [])

            if allowed_roles:
                has_allowed_role = any(role in allowed_roles for role in user_roles)

                if not has_allowed_role:
                    return error_response("AUTH_FORBIDDEN", status_code=403)

            g.current_user = {
                "id_usuario": int(payload["sub"]),
                "correo": payload.get("correo"),
                "roles": user_roles,
            }

            return func(*args, **kwargs)

        return wrapper

    return decorator