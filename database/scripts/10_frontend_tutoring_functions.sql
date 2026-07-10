/*
 Proyecto DAWA - Funciones de dominio para Tutorías
 Archivo: 10_frontend_tutoring_functions.sql
*/

SET search_path TO dawa, public;

/* ============================================================
   SOLICITUDES POR ESTUDIANTE
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_get_solicitudes_estudiante(
    p_id_estudiante BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.fecha_solicitud DESC), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            st.id_solicitud,
            ep.id_estudiante,
            st.id_estudiante_paralelo,
            p.id_paralelo,
            p.nombre AS paralelo,
            a.id_asignatura,
            a.nombre AS asignatura,
            a.codigo AS codigo_asignatura,
            st.tema,
            st.descripcion,
            st.prioridad,
            st.estado_solicitud,
            st.origen,
            st.fecha_solicitud,
            t.id_tutoria,
            t.fecha_tutoria,
            t.estado_tutoria,
            h.id_horario,
            h.dia_semana,
            h.hora_inicio,
            h.hora_fin,
            h.modalidad
        FROM dawa.solicitudes_tutoria st
        JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN dawa.asignaturas a ON a.id_asignatura = p.id_asignatura
        LEFT JOIN dawa.tutorias t ON t.id_solicitud = st.id_solicitud
        LEFT JOIN dawa.horarios_docente h ON h.id_horario = t.id_horario
        WHERE ep.id_estudiante = p_id_estudiante
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   SOLICITUDES / TUTORÍAS ASIGNADAS A DOCENTE
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_get_solicitudes_docente(
    p_id_docente BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.fecha_tutoria DESC), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            t.id_tutoria,
            t.id_solicitud,
            t.fecha_tutoria,
            t.estado_tutoria,
            st.tema,
            st.descripcion,
            st.prioridad,
            st.estado_solicitud,
            st.fecha_solicitud,
            h.id_horario,
            h.id_docente,
            h.dia_semana,
            h.hora_inicio,
            h.hora_fin,
            h.modalidad,
            a.id_asignatura,
            a.nombre AS asignatura,
            a.codigo AS codigo_asignatura,
            e.id_estudiante,
            u.nombres AS estudiante_nombres,
            u.apellidos AS estudiante_apellidos,
            u.correo AS estudiante_correo
        FROM dawa.tutorias t
        JOIN dawa.solicitudes_tutoria st ON st.id_solicitud = t.id_solicitud
        JOIN dawa.horarios_docente h ON h.id_horario = t.id_horario
        JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN dawa.estudiantes e ON e.id_estudiante = ep.id_estudiante
        JOIN dawa.usuarios u ON u.id_usuario = e.id_usuario
        JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN dawa.asignaturas a ON a.id_asignatura = p.id_asignatura
        WHERE h.id_docente = p_id_docente
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   CREAR SOLICITUD DE TUTORÍA
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_create_solicitud_tutoria(
    p_id_estudiante BIGINT,
    p_id_asignatura BIGINT,
    p_tema TEXT,
    p_descripcion TEXT,
    p_prioridad TEXT DEFAULT 'media',
    p_origen TEXT DEFAULT 'web'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_estudiante_paralelo BIGINT;
    v_id_solicitud BIGINT;
    v_result JSONB;
BEGIN
    SELECT ep.id_estudiante_paralelo
    INTO v_id_estudiante_paralelo
    FROM dawa.estudiante_paralelos ep
    JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
    JOIN dawa.periodos_academicos pe ON pe.id_periodo = p.id_periodo
    WHERE ep.id_estudiante = p_id_estudiante
      AND p.id_asignatura = p_id_asignatura
      AND ep.estado_inscripcion = 'activo'
      AND p.estado = TRUE
      AND pe.estado_periodo = 'activo'
    LIMIT 1;

    IF v_id_estudiante_paralelo IS NULL THEN
        RAISE EXCEPTION 'No existe estudiante_paralelo activo para el estudiante y asignatura indicados.';
    END IF;

    INSERT INTO dawa.solicitudes_tutoria(
        id_estudiante_paralelo,
        tema,
        descripcion,
        prioridad,
        estado_solicitud,
        origen
    )
    VALUES (
        v_id_estudiante_paralelo,
        p_tema,
        p_descripcion,
        p_prioridad,
        'solicitada',
        p_origen
    )
    RETURNING id_solicitud INTO v_id_solicitud;

    SELECT to_jsonb(q)
    INTO v_result
    FROM (
        SELECT
            st.id_solicitud,
            ep.id_estudiante,
            st.id_estudiante_paralelo,
            p.id_paralelo,
            p.nombre AS paralelo,
            a.id_asignatura,
            a.nombre AS asignatura,
            a.codigo AS codigo_asignatura,
            st.tema,
            st.descripcion,
            st.prioridad,
            st.estado_solicitud,
            st.origen,
            st.fecha_solicitud
        FROM dawa.solicitudes_tutoria st
        JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN dawa.asignaturas a ON a.id_asignatura = p.id_asignatura
        WHERE st.id_solicitud = v_id_solicitud
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   VALIDAR DISPONIBILIDAD
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_validar_disponibilidad(
    p_id_horario BIGINT,
    p_fecha_tutoria DATE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe_horario BOOLEAN;
    v_ocupado BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM dawa.horarios_docente h
        WHERE h.id_horario = p_id_horario
          AND h.estado = TRUE
    )
    INTO v_existe_horario;

    IF NOT v_existe_horario THEN
        RETURN jsonb_build_object(
            'disponible', FALSE,
            'motivo', 'HORARIO_NO_EXISTE_O_INACTIVO'
        );
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM dawa.tutorias t
        WHERE t.id_horario = p_id_horario
          AND t.fecha_tutoria = p_fecha_tutoria
          AND t.estado_tutoria IN ('pendiente', 'confirmada')
    )
    INTO v_ocupado;

    RETURN jsonb_build_object(
        'disponible', NOT v_ocupado,
        'motivo', CASE WHEN v_ocupado THEN 'HORARIO_OCUPADO' ELSE 'HORARIO_DISPONIBLE' END
    );
END;
$$;


/* ============================================================
   CREAR TUTORÍA DESDE SOLICITUD
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_create_tutoria(
    p_id_solicitud BIGINT,
    p_id_horario BIGINT,
    p_fecha_tutoria DATE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_tutoria BIGINT;
    v_disponibilidad JSONB;
    v_result JSONB;
BEGIN
    SELECT dawa.sp_front_validar_disponibilidad(p_id_horario, p_fecha_tutoria)
    INTO v_disponibilidad;

    IF (v_disponibilidad->>'disponible')::BOOLEAN IS FALSE THEN
        RAISE EXCEPTION 'El horario no está disponible para la fecha indicada.';
    END IF;

    INSERT INTO dawa.tutorias(
        id_solicitud,
        id_horario,
        fecha_tutoria,
        estado_tutoria
    )
    VALUES (
        p_id_solicitud,
        p_id_horario,
        p_fecha_tutoria,
        'pendiente'
    )
    RETURNING id_tutoria INTO v_id_tutoria;

    UPDATE dawa.solicitudes_tutoria
    SET estado_solicitud = 'pendiente'
    WHERE id_solicitud = p_id_solicitud;

    SELECT to_jsonb(q)
    INTO v_result
    FROM (
        SELECT
            t.id_tutoria,
            t.id_solicitud,
            t.id_horario,
            t.fecha_tutoria,
            t.estado_tutoria,
            st.tema,
            st.descripcion,
            st.prioridad,
            st.estado_solicitud
        FROM dawa.tutorias t
        JOIN dawa.solicitudes_tutoria st ON st.id_solicitud = t.id_solicitud
        WHERE t.id_tutoria = v_id_tutoria
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   CONFIRMAR / CANCELAR TUTORÍA
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_confirmar_tutoria(
    p_id_tutoria BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE dawa.tutorias
    SET estado_tutoria = 'confirmada',
        actualizado_en = CURRENT_TIMESTAMP
    WHERE id_tutoria = p_id_tutoria;

    UPDATE dawa.solicitudes_tutoria st
    SET estado_solicitud = 'aceptada'
    FROM dawa.tutorias t
    WHERE t.id_solicitud = st.id_solicitud
      AND t.id_tutoria = p_id_tutoria;

    SELECT to_jsonb(t)
    INTO v_result
    FROM dawa.tutorias t
    WHERE t.id_tutoria = p_id_tutoria;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;


CREATE OR REPLACE FUNCTION dawa.sp_front_cancelar_tutoria(
    p_id_tutoria BIGINT,
    p_motivo TEXT DEFAULT 'Cancelada desde el sistema'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE dawa.tutorias
    SET estado_tutoria = 'cancelada',
        motivo_cancelacion = COALESCE(NULLIF(trim(p_motivo), ''), 'Cancelada desde el sistema'),
        actualizado_en = CURRENT_TIMESTAMP
    WHERE id_tutoria = p_id_tutoria;

    UPDATE dawa.solicitudes_tutoria st
    SET estado_solicitud = 'cancelada'
    FROM dawa.tutorias t
    WHERE t.id_solicitud = st.id_solicitud
      AND t.id_tutoria = p_id_tutoria;

    SELECT to_jsonb(t)
    INTO v_result
    FROM dawa.tutorias t
    WHERE t.id_tutoria = p_id_tutoria;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;


/* ============================================================
   REGISTRAR BITÁCORA
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_create_bitacora_tutoria(
    p_id_tutoria BIGINT,
    p_registrado_por BIGINT,
    p_observaciones TEXT,
    p_recomendaciones TEXT,
    p_acuerdos TEXT DEFAULT NULL,
    p_requiere_seguimiento BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_bitacora BIGINT;
    v_result JSONB;
BEGIN
    INSERT INTO dawa.bitacoras_tutoria(
        id_tutoria,
        registrado_por,
        observaciones,
        recomendaciones,
        acuerdos,
        requiere_seguimiento
    )
    VALUES (
        p_id_tutoria,
        p_registrado_por,
        p_observaciones,
        p_recomendaciones,
        p_acuerdos,
        p_requiere_seguimiento
    )
    RETURNING id_bitacora INTO v_id_bitacora;

    UPDATE dawa.tutorias
    SET estado_tutoria = 'atendida',
        actualizado_en = CURRENT_TIMESTAMP
    WHERE id_tutoria = p_id_tutoria;

    SELECT to_jsonb(b)
    INTO v_result
    FROM dawa.bitacoras_tutoria b
    WHERE b.id_bitacora = v_id_bitacora;

    RETURN v_result;
END;
$$;