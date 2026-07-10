from datetime import datetime, timezone
from flask import jsonify, g
from app.config import Config


def current_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat()


def api_response(
    success: bool,
    message: str,
    data=None,
    status_code: int = 200,
    error=None,
    service: str | None = None,
):
    response_body = {
        "success": success,
        "message": message,
        "service": service or Config.SERVICE_NAME,
        "trace_id": getattr(g, "trace_id", None),
        "timestamp": current_timestamp(),
        "data": data,
    }

    if error is not None:
        response_body["error"] = error

    return jsonify(response_body), status_code


def success_response(message: str, data=None, status_code: int = 200):
    return api_response(
        success=True,
        message=message,
        data=data,
        status_code=status_code,
    )


def error_response(code: str, status_code: int = 400, data=None):
    return api_response(
        success=False,
        message=f"Error {code}",
        data=data,
        status_code=status_code,
        error={
            "code": code,
        },
    )