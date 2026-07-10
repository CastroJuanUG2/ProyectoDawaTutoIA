/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 01_schema_extensions.sql
 Propósito: creación de esquema, extensiones y funciones utilitarias.
 Ejecutar conectado a la base: dawa_tutorias_ia_db.
*/

CREATE SCHEMA IF NOT EXISTS dawa;

COMMENT ON SCHEMA dawa IS
'Esquema principal del sistema DAWA Tutorías Académicas con Agente de IA.';

-- Extensiones útiles para generación de UUID y búsquedas flexibles si se requieren luego.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Función genérica para actualizar automáticamente campos actualizado_en.
CREATE OR REPLACE FUNCTION dawa.fn_set_actualizado_en()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION dawa.fn_set_actualizado_en() IS
'Actualiza automáticamente el campo actualizado_en antes de una modificación.';
