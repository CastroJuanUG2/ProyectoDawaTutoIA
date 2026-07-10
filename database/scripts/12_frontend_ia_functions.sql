/*
 Proyecto DAWA - Funciones de dominio para Agente IA
 Archivo: 12_frontend_ia_functions.sql
*/

SET search_path TO dawa, public;

/* ============================================================
   SEED COMPLEMENTARIO DE CONOCIMIENTO IA
   ============================================================ */

INSERT INTO dawa.base_conocimiento_ia(id_documento, pregunta_clave, respuesta, categoria, estado)
SELECT d.id_documento,
       x.pregunta_clave,
       x.respuesta,
       x.categoria,
       TRUE
FROM dawa.documentos_base_ia d
CROSS JOIN (
    VALUES
    (
        '¿Qué hago si no encuentro horario de tutoría disponible?',
        'Si no encuentras un horario disponible, revisa otro día de atención del docente o solicita apoyo al coordinador académico para validar nuevas opciones.',
        'horarios'
    ),
    (
        '¿Cómo sé qué docente puede atender mi tutoría?',
        'El sistema puede sugerir docentes según la asignatura relacionada con tu solicitud y la disponibilidad registrada en horarios docentes.',
        'docentes'
    ),
    (
        '¿Qué información debo colocar en una solicitud de tutoría?',
        'Debes indicar la asignatura, el tema específico de consulta, una descripción breve del problema académico y la prioridad de atención.',
        'solicitudes'
    ),
    (
        '¿Qué pasa después de confirmar una tutoría?',
        'Cuando una tutoría se confirma, el docente podrá atenderla en la fecha programada y luego registrar una bitácora con observaciones, recomendaciones y acuerdos.',
        'tutorias'
    )
) AS x(pregunta_clave, respuesta, categoria)
WHERE d.titulo = 'FAQ Tutorías Académicas'
  AND NOT EXISTS (
      SELECT 1
      FROM dawa.base_conocimiento_ia bc
      WHERE bc.pregunta_clave = x.pregunta_clave
  );


/* ============================================================
   CHAT IA
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_ia_chat(
    p_id_usuario BIGINT,
    p_mensaje TEXT,
    p_id_conversacion BIGINT DEFAULT NULL,
    p_contexto VARCHAR DEFAULT 'general'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_conversacion BIGINT;
    v_id_mensaje_usuario BIGINT;
    v_id_mensaje_agente BIGINT;
    v_fuentes JSONB;
    v_respuesta TEXT;
    v_requiere_escalamiento BOOLEAN := FALSE;
    v_fuente RECORD;
BEGIN
    IF p_id_conversacion IS NULL THEN
        INSERT INTO dawa.conversaciones_ia(id_usuario, contexto, estado_conversacion)
        VALUES (p_id_usuario, p_contexto, 'abierta')
        RETURNING id_conversacion INTO v_id_conversacion;
    ELSE
        v_id_conversacion := p_id_conversacion;
    END IF;

    INSERT INTO dawa.mensajes_ia(id_conversacion, remitente, mensaje)
    VALUES (v_id_conversacion, 'usuario', p_mensaje)
    RETURNING id_mensaje INTO v_id_mensaje_usuario;

    SELECT dawa.sp_ia_buscar_conocimiento(p_mensaje, 3)
    INTO v_fuentes;

    IF jsonb_array_length(v_fuentes) > 0 THEN
        SELECT string_agg(elem->>'respuesta', E'\n\n')
        INTO v_respuesta
        FROM jsonb_array_elements(v_fuentes) elem;

        v_respuesta := v_respuesta || E'\n\nRecuerda que esta respuesta es una orientación inicial y puede ser revisada por personal académico.';
    ELSE
        v_respuesta := 'No encontré una respuesta exacta en la base de conocimiento. Te recomiendo registrar una solicitud de tutoría o pedir revisión académica.';
        v_requiere_escalamiento := TRUE;
    END IF;

    INSERT INTO dawa.mensajes_ia(
        id_conversacion,
        remitente,
        mensaje,
        requiere_escalamiento
    )
    VALUES (
        v_id_conversacion,
        'agente',
        v_respuesta,
        v_requiere_escalamiento
    )
    RETURNING id_mensaje INTO v_id_mensaje_agente;

    FOR v_fuente IN
        SELECT (elem->>'id_conocimiento')::BIGINT AS id_conocimiento
        FROM jsonb_array_elements(v_fuentes) elem
        WHERE elem ? 'id_conocimiento'
    LOOP
        INSERT INTO dawa.mensaje_fuentes_ia(id_mensaje, id_conocimiento)
        VALUES (v_id_mensaje_agente, v_fuente.id_conocimiento)
        ON CONFLICT (id_mensaje, id_conocimiento) DO NOTHING;
    END LOOP;

    RETURN jsonb_build_object(
        'id_conversacion', v_id_conversacion,
        'id_mensaje_usuario', v_id_mensaje_usuario,
        'id_mensaje_agente', v_id_mensaje_agente,
        'respuesta', v_respuesta,
        'requiere_escalamiento', v_requiere_escalamiento,
        'fuentes', v_fuentes
    );
END;
$$;


/* ============================================================
   HISTORIAL IA POR USUARIO
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_ia_historial_usuario(
    p_id_usuario BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.fecha_inicio DESC), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            c.id_conversacion,
            c.id_usuario,
            c.contexto,
            c.estado_conversacion,
            c.fecha_inicio,
            c.fecha_cierre,
            COALESCE((
                SELECT jsonb_agg(to_jsonb(m) ORDER BY m.fecha_mensaje ASC)
                FROM dawa.mensajes_ia m
                WHERE m.id_conversacion = c.id_conversacion
            ), '[]'::jsonb) AS mensajes
        FROM dawa.conversaciones_ia c
        WHERE c.id_usuario = p_id_usuario
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   FEEDBACK DE MENSAJE IA
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_ia_feedback(
    p_id_mensaje BIGINT,
    p_id_usuario BIGINT,
    p_util BOOLEAN,
    p_comentario TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    INSERT INTO dawa.feedback_ia(id_mensaje, id_usuario, util, comentario)
    VALUES (p_id_mensaje, p_id_usuario, p_util, p_comentario)
    ON CONFLICT (id_mensaje, id_usuario) DO UPDATE
    SET util = EXCLUDED.util,
        comentario = EXCLUDED.comentario,
        fecha_feedback = CURRENT_TIMESTAMP
    RETURNING to_jsonb(feedback_ia)
    INTO v_result;

    RETURN v_result;
END;
$$;


/* ============================================================
   CLASIFICAR SOLICITUD IA
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_ia_clasificar_solicitud(
    p_id_solicitud BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_asignatura BIGINT;
    v_categoria TEXT;
    v_id_docente BIGINT;
    v_id_clasificacion BIGINT;
    v_result JSONB;
BEGIN
    SELECT
        a.id_asignatura,
        a.nombre
    INTO
        v_id_asignatura,
        v_categoria
    FROM dawa.solicitudes_tutoria st
    JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
    JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
    JOIN dawa.asignaturas a ON a.id_asignatura = p.id_asignatura
    WHERE st.id_solicitud = p_id_solicitud;

    SELECT da.id_docente
    INTO v_id_docente
    FROM dawa.docente_asignaturas da
    JOIN dawa.periodos_academicos pe ON pe.id_periodo = da.id_periodo
    WHERE da.id_asignatura = v_id_asignatura
      AND da.estado = TRUE
      AND pe.estado_periodo = 'activo'
    ORDER BY da.id_docente
    LIMIT 1;

    INSERT INTO dawa.clasificaciones_ia(
        id_solicitud,
        id_asignatura_sugerida,
        id_docente_sugerido,
        categoria_detectada,
        nivel_confianza,
        requiere_revision
    )
    VALUES (
        p_id_solicitud,
        v_id_asignatura,
        v_id_docente,
        v_categoria,
        85.00,
        FALSE
    )
    RETURNING id_clasificacion INTO v_id_clasificacion;

    SELECT to_jsonb(q)
    INTO v_result
    FROM (
        SELECT
            ci.id_clasificacion,
            ci.id_solicitud,
            ci.id_asignatura_sugerida,
            a.nombre AS asignatura_sugerida,
            ci.id_docente_sugerido,
            u.nombres AS docente_nombres,
            u.apellidos AS docente_apellidos,
            ci.categoria_detectada,
            ci.nivel_confianza,
            ci.requiere_revision,
            ci.fecha_clasificacion
        FROM dawa.clasificaciones_ia ci
        LEFT JOIN dawa.asignaturas a ON a.id_asignatura = ci.id_asignatura_sugerida
        LEFT JOIN dawa.docentes d ON d.id_docente = ci.id_docente_sugerido
        LEFT JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
        WHERE ci.id_clasificacion = v_id_clasificacion
    ) q;

    RETURN v_result;
END;
$$;


/* ============================================================
   SUGERIR DOCENTE
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_front_ia_sugerir_docente(
    p_id_asignatura BIGINT
)
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
            a.id_asignatura,
            a.nombre AS asignatura,
            COUNT(h.id_horario) AS total_horarios_disponibles
        FROM dawa.docente_asignaturas da
        JOIN dawa.docentes d ON d.id_docente = da.id_docente
        JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
        JOIN dawa.asignaturas a ON a.id_asignatura = da.id_asignatura
        LEFT JOIN dawa.horarios_docente h
               ON h.id_docente = d.id_docente
              AND h.id_periodo = da.id_periodo
              AND h.estado = TRUE
        JOIN dawa.periodos_academicos pe ON pe.id_periodo = da.id_periodo
        WHERE da.id_asignatura = p_id_asignatura
          AND da.estado = TRUE
          AND d.estado = TRUE
          AND u.estado_usuario = 'activo'
          AND pe.estado_periodo = 'activo'
        GROUP BY
            d.id_docente,
            d.id_usuario,
            u.nombres,
            u.apellidos,
            u.correo,
            d.titulo,
            d.especialidad,
            a.id_asignatura,
            a.nombre
    ) q;

    RETURN v_result;
END;
$$;