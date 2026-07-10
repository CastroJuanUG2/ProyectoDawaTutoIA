/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 04_crud_engine.sql
 Propósito: motor genérico de funciones almacenadas para CRUD mediante JSONB.
 El backend Flask podrá llamar wrappers específicos por tabla, sin SQL directo embebido.
*/

SET search_path TO dawa, public;

CREATE TABLE IF NOT EXISTS dawa.crud_metadata (
    table_name          VARCHAR(100) PRIMARY KEY,
    pk_column           VARCHAR(100) NOT NULL,
    soft_delete_column  VARCHAR(100),
    soft_delete_value   JSONB,
    enabled             BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE dawa.crud_metadata IS 'Lista permitida de tablas operables mediante funciones almacenadas CRUD.';

TRUNCATE TABLE dawa.crud_metadata;

INSERT INTO dawa.crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES
('usuarios', 'id_usuario', 'estado_usuario', '"inactivo"'::jsonb, TRUE),
('roles', 'id_rol', 'estado', 'false'::jsonb, TRUE),
('permisos', 'id_permiso', 'estado', 'false'::jsonb, TRUE),
('usuario_roles', 'id_usuario_rol', 'estado', 'false'::jsonb, TRUE),
('rol_permisos', 'id_rol_permiso', 'estado', 'false'::jsonb, TRUE),
('facultades', 'id_facultad', 'estado', 'false'::jsonb, TRUE),
('carreras', 'id_carrera', 'estado', 'false'::jsonb, TRUE),
('periodos_academicos', 'id_periodo', 'estado_periodo', '"cerrado"'::jsonb, TRUE),
('asignaturas', 'id_asignatura', 'estado', 'false'::jsonb, TRUE),
('docentes', 'id_docente', 'estado', 'false'::jsonb, TRUE),
('estudiantes', 'id_estudiante', 'estado', 'false'::jsonb, TRUE),
('paralelos', 'id_paralelo', 'estado', 'false'::jsonb, TRUE),
('estudiante_paralelos', 'id_estudiante_paralelo', 'estado_inscripcion', '"inactivo"'::jsonb, TRUE),
('docente_asignaturas', 'id_docente_asignatura', 'estado', 'false'::jsonb, TRUE),
('horarios_docente', 'id_horario', 'estado', 'false'::jsonb, TRUE),
('solicitudes_tutoria', 'id_solicitud', 'estado_solicitud', '"cancelada"'::jsonb, TRUE),
('tutorias', 'id_tutoria', NULL, NULL, TRUE),
('asistencias_tutoria', 'id_asistencia', NULL, NULL, TRUE),
('bitacoras_tutoria', 'id_bitacora', NULL, NULL, TRUE),
('temas_recurrentes', 'id_tema_recurrente', 'estado', 'false'::jsonb, TRUE),
('solicitud_temas', 'id_solicitud_tema', NULL, NULL, TRUE),
('casos_academicos', 'id_caso', 'estado_caso', '"cerrado"'::jsonb, TRUE),
('seguimientos_academicos', 'id_seguimiento', 'estado_seguimiento', '"cerrado"'::jsonb, TRUE),
('documentos_base_ia', 'id_documento', 'estado', 'false'::jsonb, TRUE),
('base_conocimiento_ia', 'id_conocimiento', 'estado', 'false'::jsonb, TRUE),
('conocimiento_palabras_clave_ia', 'id_palabra_clave', NULL, NULL, TRUE),
('conversaciones_ia', 'id_conversacion', 'estado_conversacion', '"cerrada"'::jsonb, TRUE),
('mensajes_ia', 'id_mensaje', NULL, NULL, TRUE),
('mensaje_fuentes_ia', 'id_mensaje_fuente', NULL, NULL, TRUE),
('clasificaciones_ia', 'id_clasificacion', NULL, NULL, TRUE),
('feedback_ia', 'id_feedback', NULL, NULL, TRUE),
('escalamientos_ia', 'id_escalamiento', 'estado_escalamiento', '"cancelado"'::jsonb, TRUE),
('auditoria_accesos', 'id_auditoria', NULL, NULL, TRUE),
('notificaciones', 'id_notificacion', NULL, NULL, TRUE),
('parametros_sistema', 'id_parametro', NULL, NULL, TRUE),
('logs_sistema', 'id_log', NULL, NULL, TRUE),
('archivos', 'id_archivo', NULL, NULL, TRUE),
('archivo_solicitud', 'id_archivo_solicitud', NULL, NULL, TRUE),
('archivo_bitacora', 'id_archivo_bitacora', NULL, NULL, TRUE),
('archivo_documento_ia', 'id_archivo_documento_ia', NULL, NULL, TRUE);

CREATE OR REPLACE FUNCTION dawa.fn_assert_crud_table(p_table_name TEXT)
RETURNS TABLE(table_name VARCHAR, pk_column VARCHAR, soft_delete_column VARCHAR, soft_delete_value JSONB)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT cm.table_name, cm.pk_column, cm.soft_delete_column, cm.soft_delete_value
    FROM dawa.crud_metadata cm
    WHERE cm.table_name = p_table_name
      AND cm.enabled = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La tabla % no está habilitada para operaciones CRUD almacenadas.', p_table_name;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.fn_crud_create(p_table_name TEXT, p_payload JSONB)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_meta RECORD;
    v_cols TEXT;
    v_select_cols TEXT;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    SELECT * INTO v_meta FROM dawa.fn_assert_crud_table(p_table_name);

    SELECT
        string_agg(format('%I', c.column_name), ', ' ORDER BY c.ordinal_position),
        string_agg(format('r.%I', c.column_name), ', ' ORDER BY c.ordinal_position)
    INTO v_cols, v_select_cols
    FROM information_schema.columns c
    WHERE c.table_schema = 'dawa'
      AND c.table_name = p_table_name
      AND c.column_name <> v_meta.pk_column
      AND c.is_identity = 'NO'
      AND c.is_generated = 'NEVER'
      AND p_payload ? c.column_name;

    IF v_cols IS NULL THEN
        RAISE EXCEPTION 'No se enviaron campos válidos para insertar en la tabla %.', p_table_name;
    END IF;

    v_sql := format(
        'INSERT INTO dawa.%I AS t (%s) SELECT %s FROM jsonb_populate_record(NULL::dawa.%I, $1) AS r RETURNING to_jsonb(t)',
        p_table_name, v_cols, v_select_cols, p_table_name
    );

    EXECUTE v_sql USING p_payload INTO v_result;
    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.fn_crud_get(p_table_name TEXT, p_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_meta RECORD;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    SELECT * INTO v_meta FROM dawa.fn_assert_crud_table(p_table_name);

    v_sql := format('SELECT to_jsonb(t) FROM dawa.%I AS t WHERE t.%I = $1', p_table_name, v_meta.pk_column);
    EXECUTE v_sql USING p_id INTO v_result;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION dawa.fn_crud_list(p_table_name TEXT, p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_meta RECORD;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    SELECT * INTO v_meta FROM dawa.fn_assert_crud_table(p_table_name);

    IF p_limit IS NULL OR p_limit <= 0 OR p_limit > 500 THEN
        p_limit := 100;
    END IF;

    IF p_offset IS NULL OR p_offset < 0 THEN
        p_offset := 0;
    END IF;

    v_sql := format(
        'SELECT COALESCE(jsonb_agg(to_jsonb(q)), ''[]''::jsonb)
         FROM (SELECT * FROM dawa.%I ORDER BY %I LIMIT $1 OFFSET $2) AS q',
        p_table_name, v_meta.pk_column
    );

    EXECUTE v_sql USING p_limit, p_offset INTO v_result;
    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.fn_crud_update(p_table_name TEXT, p_id BIGINT, p_payload JSONB)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_meta RECORD;
    v_set_cols TEXT;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    SELECT * INTO v_meta FROM dawa.fn_assert_crud_table(p_table_name);

    SELECT string_agg(format('%I = r.%I', c.column_name, c.column_name), ', ' ORDER BY c.ordinal_position)
    INTO v_set_cols
    FROM information_schema.columns c
    WHERE c.table_schema = 'dawa'
      AND c.table_name = p_table_name
      AND c.column_name <> v_meta.pk_column
      AND c.is_identity = 'NO'
      AND c.is_generated = 'NEVER'
      AND p_payload ? c.column_name;

    IF v_set_cols IS NULL THEN
        RAISE EXCEPTION 'No se enviaron campos válidos para actualizar en la tabla %.', p_table_name;
    END IF;

    v_sql := format(
        'UPDATE dawa.%I AS t SET %s FROM jsonb_populate_record(NULL::dawa.%I, $1) AS r WHERE t.%I = $2 RETURNING to_jsonb(t)',
        p_table_name, v_set_cols, p_table_name, v_meta.pk_column
    );

    EXECUTE v_sql USING p_payload, p_id INTO v_result;
    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION dawa.fn_crud_delete(p_table_name TEXT, p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_meta RECORD;
    v_sql TEXT;
    v_result JSONB;
    v_type_cast TEXT;
BEGIN
    SELECT * INTO v_meta FROM dawa.fn_assert_crud_table(p_table_name);

    IF v_meta.soft_delete_column IS NOT NULL AND COALESCE(p_hard_delete, FALSE) = FALSE THEN
        SELECT format_type(a.atttypid, a.atttypmod)
        INTO v_type_cast
        FROM pg_attribute a
        JOIN pg_class c ON c.oid = a.attrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'dawa'
          AND c.relname = p_table_name
          AND a.attname = v_meta.soft_delete_column
          AND a.attnum > 0
          AND NOT a.attisdropped;

        v_sql := format(
            'UPDATE dawa.%I AS t SET %I = ($1 #>> ''{}'')::%s WHERE t.%I = $2 RETURNING to_jsonb(t)',
            p_table_name, v_meta.soft_delete_column, v_type_cast, v_meta.pk_column
        );
        EXECUTE v_sql USING v_meta.soft_delete_value, p_id INTO v_result;
    ELSE
        v_sql := format('DELETE FROM dawa.%I AS t WHERE t.%I = $1 RETURNING to_jsonb(t)', p_table_name, v_meta.pk_column);
        EXECUTE v_sql USING p_id INTO v_result;
    END IF;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;
