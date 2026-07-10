/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 PostgreSQL 17 / pgAdmin 9.11
 Archivo: 00_create_database.sql
 Propósito: creación de la base de datos. Ejecutar desde una conexión al servidor PostgreSQL, no dentro de la misma BD objetivo.
*/

-- Opcional: ejecutar manualmente si se requiere reiniciar completamente la base.
-- DROP DATABASE IF EXISTS dawa_tutorias_ia_db;

CREATE DATABASE dawa_tutorias_ia_db
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C.UTF-8'
    LC_CTYPE = 'C.UTF-8'
    TEMPLATE = template0
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE dawa_tutorias_ia_db IS
'Base de datos del proyecto DAWA: Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA.';
