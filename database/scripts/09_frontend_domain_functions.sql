/*
 Proyecto DAWA - Funciones de dominio para integración Frontend/API Gateway
 Archivo: 09_frontend_domain_functions.sql
 Propósito: exponer consultas ya adaptadas para el frontend, sin que Flask haga SQL directo.
*/

SET search_path TO dawa, public;

/* ============================================================
   DOCENTES CON DATOS DE USUARIO
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_list_docentes()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.id_docente), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            d.id_docente,
            d.id_usuario,
            u.nombres,
            u.apellidos,
            u.correo,
            d.titulo,
            d.especialidad,
            d.telefono,
            d.estado,
            d.creado_en,
            d.actualizado_en
        FROM dawa.docentes d
        JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
        WHERE d.estado = TRUE
          AND u.estado_usuario = 'activo'
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   HORARIOS DE DOCENTE CON INFORMACIÓN DEL PERIODO
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_get_horarios_docente(p_id_docente BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.dia_semana, q.hora_inicio), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            h.id_horario,
            h.id_docente,
            h.id_periodo,
            p.nombre AS periodo,
            h.dia_semana,
            h.hora_inicio,
            h.hora_fin,
            h.modalidad,
            h.estado,
            h.creado_en
        FROM dawa.horarios_docente h
        JOIN dawa.periodos_academicos p ON p.id_periodo = h.id_periodo
        WHERE h.id_docente = p_id_docente
          AND h.estado = TRUE
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   PERIODO ACTIVO O MÁS RECIENTE
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_get_periodo_actual()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT to_jsonb(p)
    INTO v_result
    FROM dawa.periodos_academicos p
    WHERE p.estado_periodo = 'activo'
    ORDER BY p.fecha_inicio DESC, p.id_periodo DESC
    LIMIT 1;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;