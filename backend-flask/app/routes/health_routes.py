from flask import Blueprint

from app.db.postgres import fetch_one_value
from app.utils.responses import success_response, error_response

health_bp = Blueprint("health_bp", __name__)


@health_bp.get("/health")
def health_check():
    return success_response(
        message="API Gateway funcionando correctamente",
        data={
            "status": "ok",
            "module": "backend-flask",
            "role": "api-gateway",
        },
    )


@health_bp.get("/health/db")
def health_database():
    try:
        database_name = fetch_one_value("SELECT current_database();")
        postgres_version = fetch_one_value("SELECT version();")

        return success_response(
            message="Conexión a PostgreSQL funcionando correctamente",
            data={
                "status": "ok",
                "database": database_name,
                "version": postgres_version,
            },
        )
    except Exception:
        return error_response("DATABASE_CONNECTION_ERROR", status_code=500)