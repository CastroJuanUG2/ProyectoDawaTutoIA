import json
import psycopg
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb

from app.config import Config


def get_connection():
    return psycopg.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        dbname=Config.DB_NAME,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        row_factory=dict_row,
    )


def normalize_jsonb(value):
    if value is None:
        return None

    if isinstance(value, str):
        try:
            return json.loads(value)
        except json.JSONDecodeError:
            return value

    return value


def fetch_one_value(query: str, params: tuple = ()):
    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(query, params)
            row = cursor.fetchone()

            if not row:
                return None

            value = next(iter(row.values()))
            return normalize_jsonb(value)


def jsonb_payload(data: dict):
    return Jsonb(data)