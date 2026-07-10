import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    SERVICE_NAME = os.getenv("SERVICE_NAME", "backend-flask")
    API_PREFIX = os.getenv("API_PREFIX", "/api/v1")

    APP_HOST = os.getenv("APP_HOST", "0.0.0.0")
    APP_PORT = int(os.getenv("APP_PORT", "3013"))

    FLASK_DEBUG = os.getenv("FLASK_DEBUG", "False").lower() == "true"

    SECURITY_SERVICE_URL = os.getenv("SECURITY_SERVICE_URL")
    ACADEMIC_SERVICE_URL = os.getenv("ACADEMIC_SERVICE_URL")
    TUTORING_SERVICE_URL = os.getenv("TUTORING_SERVICE_URL")
    IA_SERVICE_URL = os.getenv("IA_SERVICE_URL")

    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev_secret_key")
    JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_EXPIRES_MINUTES = int(os.getenv("JWT_EXPIRES_MINUTES", "120"))

    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = int(os.getenv("DB_PORT", "5435"))
    DB_NAME = os.getenv("DB_NAME", "dawa_tutorias_ia_db")
    DB_USER = os.getenv("DB_USER", "postgres")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
    DB_SCHEMA = os.getenv("DB_SCHEMA", "dawa")