/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 05_crud_wrappers.sql
 Propósito: funciones almacenadas específicas por tabla para ser llamadas desde Flask.
 Cada función recibe/devuelve JSONB para facilitar integración con APIs REST.
*/

SET search_path TO dawa, public;


-- ============================================================
-- CRUD almacenado para tabla: usuarios
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_usuarios(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('usuarios', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_usuarios(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('usuarios', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_usuarios(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('usuarios', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_usuarios(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('usuarios', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_usuarios(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('usuarios', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: roles
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_roles(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('roles', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_roles(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('roles', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_roles(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('roles', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_roles(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('roles', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_roles(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('roles', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: permisos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_permisos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('permisos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_permisos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('permisos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_permisos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('permisos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_permisos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('permisos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_permisos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('permisos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: usuario_roles
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_usuario_roles(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('usuario_roles', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_usuario_roles(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('usuario_roles', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_usuario_roles(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('usuario_roles', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_usuario_roles(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('usuario_roles', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_usuario_roles(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('usuario_roles', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: rol_permisos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_rol_permisos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('rol_permisos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_rol_permisos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('rol_permisos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_rol_permisos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('rol_permisos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_rol_permisos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('rol_permisos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_rol_permisos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('rol_permisos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: facultades
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_facultades(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('facultades', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_facultades(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('facultades', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_facultades(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('facultades', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_facultades(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('facultades', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_facultades(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('facultades', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: carreras
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_carreras(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('carreras', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_carreras(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('carreras', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_carreras(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('carreras', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_carreras(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('carreras', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_carreras(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('carreras', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: periodos_academicos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_periodos_academicos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('periodos_academicos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_periodos_academicos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('periodos_academicos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_periodos_academicos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('periodos_academicos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_periodos_academicos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('periodos_academicos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_periodos_academicos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('periodos_academicos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: asignaturas
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_asignaturas(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('asignaturas', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_asignaturas(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('asignaturas', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_asignaturas(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('asignaturas', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_asignaturas(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('asignaturas', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_asignaturas(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('asignaturas', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: docentes
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_docentes(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('docentes', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_docentes(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('docentes', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_docentes(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('docentes', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_docentes(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('docentes', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_docentes(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('docentes', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: estudiantes
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_estudiantes(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('estudiantes', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_estudiantes(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('estudiantes', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_estudiantes(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('estudiantes', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_estudiantes(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('estudiantes', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_estudiantes(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('estudiantes', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: paralelos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_paralelos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('paralelos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_paralelos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('paralelos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_paralelos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('paralelos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_paralelos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('paralelos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_paralelos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('paralelos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: estudiante_paralelos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_estudiante_paralelos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('estudiante_paralelos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_estudiante_paralelos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('estudiante_paralelos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_estudiante_paralelos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('estudiante_paralelos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_estudiante_paralelos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('estudiante_paralelos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_estudiante_paralelos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('estudiante_paralelos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: docente_asignaturas
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_docente_asignaturas(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('docente_asignaturas', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_docente_asignaturas(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('docente_asignaturas', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_docente_asignaturas(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('docente_asignaturas', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_docente_asignaturas(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('docente_asignaturas', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_docente_asignaturas(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('docente_asignaturas', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: horarios_docente
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_horarios_docente(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('horarios_docente', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_horarios_docente(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('horarios_docente', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_horarios_docente(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('horarios_docente', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_horarios_docente(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('horarios_docente', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_horarios_docente(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('horarios_docente', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: solicitudes_tutoria
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_solicitudes_tutoria(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('solicitudes_tutoria', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_solicitudes_tutoria(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('solicitudes_tutoria', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_solicitudes_tutoria(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('solicitudes_tutoria', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_solicitudes_tutoria(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('solicitudes_tutoria', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_solicitudes_tutoria(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('solicitudes_tutoria', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: tutorias
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_tutorias(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('tutorias', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_tutorias(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('tutorias', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_tutorias(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('tutorias', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_tutorias(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('tutorias', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_tutorias(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('tutorias', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: asistencias_tutoria
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_asistencias_tutoria(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('asistencias_tutoria', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_asistencias_tutoria(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('asistencias_tutoria', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_asistencias_tutoria(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('asistencias_tutoria', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_asistencias_tutoria(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('asistencias_tutoria', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_asistencias_tutoria(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('asistencias_tutoria', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: bitacoras_tutoria
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_bitacoras_tutoria(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('bitacoras_tutoria', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_bitacoras_tutoria(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('bitacoras_tutoria', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_bitacoras_tutoria(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('bitacoras_tutoria', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_bitacoras_tutoria(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('bitacoras_tutoria', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_bitacoras_tutoria(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('bitacoras_tutoria', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: temas_recurrentes
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_temas_recurrentes(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('temas_recurrentes', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_temas_recurrentes(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('temas_recurrentes', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_temas_recurrentes(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('temas_recurrentes', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_temas_recurrentes(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('temas_recurrentes', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_temas_recurrentes(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('temas_recurrentes', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: solicitud_temas
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_solicitud_temas(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('solicitud_temas', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_solicitud_temas(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('solicitud_temas', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_solicitud_temas(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('solicitud_temas', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_solicitud_temas(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('solicitud_temas', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_solicitud_temas(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('solicitud_temas', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: casos_academicos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_casos_academicos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('casos_academicos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_casos_academicos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('casos_academicos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_casos_academicos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('casos_academicos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_casos_academicos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('casos_academicos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_casos_academicos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('casos_academicos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: seguimientos_academicos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_seguimientos_academicos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('seguimientos_academicos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_seguimientos_academicos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('seguimientos_academicos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_seguimientos_academicos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('seguimientos_academicos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_seguimientos_academicos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('seguimientos_academicos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_seguimientos_academicos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('seguimientos_academicos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: documentos_base_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_documentos_base_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('documentos_base_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_documentos_base_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('documentos_base_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_documentos_base_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('documentos_base_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_documentos_base_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('documentos_base_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_documentos_base_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('documentos_base_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: base_conocimiento_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_base_conocimiento_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('base_conocimiento_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_base_conocimiento_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('base_conocimiento_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_base_conocimiento_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('base_conocimiento_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_base_conocimiento_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('base_conocimiento_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_base_conocimiento_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('base_conocimiento_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: conocimiento_palabras_clave_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_conocimiento_palabras_clave_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('conocimiento_palabras_clave_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_conocimiento_palabras_clave_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('conocimiento_palabras_clave_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_conocimiento_palabras_clave_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('conocimiento_palabras_clave_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_conocimiento_palabras_clave_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('conocimiento_palabras_clave_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_conocimiento_palabras_clave_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('conocimiento_palabras_clave_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: conversaciones_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_conversaciones_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('conversaciones_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_conversaciones_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('conversaciones_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_conversaciones_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('conversaciones_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_conversaciones_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('conversaciones_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_conversaciones_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('conversaciones_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: mensajes_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_mensajes_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('mensajes_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_mensajes_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('mensajes_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_mensajes_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('mensajes_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_mensajes_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('mensajes_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_mensajes_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('mensajes_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: mensaje_fuentes_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_mensaje_fuentes_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('mensaje_fuentes_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_mensaje_fuentes_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('mensaje_fuentes_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_mensaje_fuentes_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('mensaje_fuentes_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_mensaje_fuentes_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('mensaje_fuentes_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_mensaje_fuentes_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('mensaje_fuentes_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: clasificaciones_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_clasificaciones_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('clasificaciones_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_clasificaciones_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('clasificaciones_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_clasificaciones_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('clasificaciones_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_clasificaciones_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('clasificaciones_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_clasificaciones_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('clasificaciones_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: feedback_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_feedback_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('feedback_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_feedback_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('feedback_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_feedback_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('feedback_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_feedback_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('feedback_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_feedback_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('feedback_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: escalamientos_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_escalamientos_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('escalamientos_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_escalamientos_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('escalamientos_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_escalamientos_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('escalamientos_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_escalamientos_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('escalamientos_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_escalamientos_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('escalamientos_ia', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: auditoria_accesos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_auditoria_accesos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('auditoria_accesos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_auditoria_accesos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('auditoria_accesos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_auditoria_accesos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('auditoria_accesos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_auditoria_accesos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('auditoria_accesos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_auditoria_accesos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('auditoria_accesos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: notificaciones
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_notificaciones(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('notificaciones', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_notificaciones(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('notificaciones', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_notificaciones(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('notificaciones', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_notificaciones(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('notificaciones', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_notificaciones(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('notificaciones', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: parametros_sistema
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_parametros_sistema(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('parametros_sistema', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_parametros_sistema(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('parametros_sistema', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_parametros_sistema(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('parametros_sistema', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_parametros_sistema(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('parametros_sistema', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_parametros_sistema(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('parametros_sistema', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: logs_sistema
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_logs_sistema(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('logs_sistema', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_logs_sistema(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('logs_sistema', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_logs_sistema(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('logs_sistema', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_logs_sistema(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('logs_sistema', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_logs_sistema(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('logs_sistema', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: archivos
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_archivos(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('archivos', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_archivos(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('archivos', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_archivos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('archivos', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_archivos(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('archivos', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_archivos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('archivos', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: archivo_solicitud
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_archivo_solicitud(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('archivo_solicitud', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_archivo_solicitud(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('archivo_solicitud', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_archivo_solicitud(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('archivo_solicitud', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_archivo_solicitud(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('archivo_solicitud', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_archivo_solicitud(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('archivo_solicitud', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: archivo_bitacora
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_archivo_bitacora(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('archivo_bitacora', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_archivo_bitacora(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('archivo_bitacora', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_archivo_bitacora(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('archivo_bitacora', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_archivo_bitacora(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('archivo_bitacora', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_archivo_bitacora(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('archivo_bitacora', p_id, p_hard_delete);
$$;


-- ============================================================
-- CRUD almacenado para tabla: archivo_documento_ia
-- ============================================================

CREATE OR REPLACE FUNCTION dawa.sp_create_archivo_documento_ia(p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_create('archivo_documento_ia', p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_archivo_documento_ia(p_id BIGINT)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_get('archivo_documento_ia', p_id);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_list_archivo_documento_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_list('archivo_documento_ia', p_limit, p_offset);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_update_archivo_documento_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_update('archivo_documento_ia', p_id, p_data);
$$;

CREATE OR REPLACE FUNCTION dawa.sp_delete_archivo_documento_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE sql
AS $$
    SELECT dawa.fn_crud_delete('archivo_documento_ia', p_id, p_hard_delete);
$$;
