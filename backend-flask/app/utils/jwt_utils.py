from datetime import datetime, timedelta, timezone
import jwt

from app.config import Config


def create_access_token(user: dict) -> str:
    now = datetime.now(timezone.utc)

    payload = {
        "sub": str(user["id_usuario"]),
        "correo": user["correo"],
        "roles": user["roles"],
        "iat": now,
        "exp": now + timedelta(minutes=Config.JWT_EXPIRES_MINUTES),
    }

    return jwt.encode(
        payload,
        Config.JWT_SECRET_KEY,
        algorithm=Config.JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict:
    return jwt.decode(
        token,
        Config.JWT_SECRET_KEY,
        algorithms=[Config.JWT_ALGORITHM],
    )


def get_bearer_token(authorization_header: str | None) -> str | None:
    if not authorization_header:
        return None

    parts = authorization_header.split()

    if len(parts) != 2:
        return None

    token_type, token = parts

    if token_type.lower() != "bearer":
        return None

    return token