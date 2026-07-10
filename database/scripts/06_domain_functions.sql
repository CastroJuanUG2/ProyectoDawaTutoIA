/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 06_domain_functions.sql
 Propósito: funciones almacenadas de consulta e integración para Flask, además del CRUD genérico.
*/

SET search_path TO dawa, public;

/* ============================================================
   AUTENTICACIÓN Y CONTEXTO DE USUARIO
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_auth_login_lookup(p_correo TEXT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'usuario', to_jsonb(u) - 'password_hash',
        'password_hash', u.password_hash,
        'roles', COALESCE((
            SELECT jsonb_agg(r.nombre_rol ORDER BY r.nombre_rol)
            FROM dawa.usuario_roles ur
            JOIN dawa.roles r ON r.id_rol = ur.id_rol
            WHERE ur.id_usuario = u.id_usuario
              AND ur.estado = TRUE
              AND r.estado = TRUE
        ), '[]'::jsonb),
        'permisos', COALESCE((
            SELECT jsonb_agg(DISTINCT p.codigo ORDER BY p.codigo)
            FROM dawa.usuario_roles ur
            JOIN dawa.roles r ON r.id_rol = ur.id_rol
            JOIN dawa.rol_permisos rp ON rp.id_rol = r.id_rol
            JOIN dawa.permisos p ON p.id_permiso = rp.id_permiso
            WHERE ur.id_usuario = u.id_usuario
              AND ur.estado = TRUE
              AND r.estado = TRUE
              AND rp.estado = TRUE
              AND p.estado = TRUE
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM dawa.usuarios u
    WHERE lower(u.correo) = lower(p_correo)
      AND u.estado_usuario IN ('activo', 'bloqueado');

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_auth_actualizar_ultimo_acceso(p_id_usuario BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE dawa.usuarios
    SET ultimo_acceso = CURRENT_TIMESTAMP
    WHERE id_usuario = p_id_usuario
    RETURNING to_jsonb(usuarios) - 'password_hash'
    INTO v_result;

    INSERT INTO dawa.auditoria_accesos(id_usuario, accion, fecha_accion)
    VALUES (p_id_usuario, 'login_exitoso', CURRENT_TIMESTAMP);

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_auth_registrar_evento_acceso(
    p_id_usuario BIGINT,
    p_accion VARCHAR,
    p_ip_origen VARCHAR DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    INSERT INTO dawa.auditoria_accesos(id_usuario, accion, ip_origen, user_agent)
    VALUES (p_id_usuario, p_accion, p_ip_origen, p_user_agent)
    RETURNING to_jsonb(auditoria_accesos)
    INTO v_result;

    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_usuario_contexto(p_id_usuario BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'usuario', to_jsonb(u) - 'password_hash',
        'roles', COALESCE((
            SELECT jsonb_agg(r.nombre_rol ORDER BY r.nombre_rol)
            FROM dawa.usuario_roles ur
            JOIN dawa.roles r ON r.id_rol = ur.id_rol
            WHERE ur.id_usuario = u.id_usuario
              AND ur.estado = TRUE
              AND r.estado = TRUE
        ), '[]'::jsonb),
        'docente', COALESCE((SELECT to_jsonb(d) FROM dawa.docentes d WHERE d.id_usuario = u.id_usuario), '{}'::jsonb),
        'estudiante', COALESCE((SELECT to_jsonb(e) FROM dawa.estudiantes e WHERE e.id_usuario = u.id_usuario), '{}'::jsonb)
    )
    INTO v_result
    FROM dawa.usuarios u
    WHERE u.id_usuario = p_id_usuario;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;

/* ============================================================
   CONSULTAS ACADÉMICAS Y TUTORÍAS
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_get_tutorias_por_docente(p_id_docente BIGINT)
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
            t.fecha_tutoria,
            t.estado_tutoria,
            hd.dia_semana,
            hd.hora_inicio,
            hd.hora_fin,
            hd.modalidad,
            st.id_solicitud,
            st.tema,
            st.prioridad,
            a.nombre AS asignatura,
            p.nombre AS paralelo,
            u.nombres || ' ' || u.apellidos AS estudiante
        FROM dawa.tutorias t
        JOIN dawa.horarios_docente hd ON hd.id_horario = t.id_horario
        JOIN dawa.solicitudes_tutoria st ON st.id_solicitud = t.id_solicitud
        JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN dawa.estudiantes e ON e.id_estudiante = ep.id_estudiante
        JOIN dawa.usuarios u ON u.id_usuario = e.id_usuario
        JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN dawa.asignaturas a ON a.id_asignatura = p.id_asignatura
        WHERE hd.id_docente = p_id_docente
    ) q;

    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_tutorias_por_estudiante(p_id_estudiante BIGINT)
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
            t.fecha_tutoria,
            t.estado_tutoria,
            hd.dia_semana,
            hd.hora_inicio,
            hd.hora_fin,
            hd.modalidad,
            st.id_solicitud,
            st.tema,
            st.prioridad,
            a.nombre AS asignatura,
            p.nombre AS paralelo,
            ud.nombres || ' ' || ud.apellidos AS docente
        FROM dawa.tutorias t
        JOIN dawa.horarios_docente hd ON hd.id_horario = t.id_horario
        JOIN dawa.docentes d ON d.id_docente = hd.id_docente
        JOIN dawa.usuarios ud ON ud.id_usuario = d.id_usuario
        JOIN dawa.solicitudes_tutoria st ON st.id_solicitud = t.id_solicitud
        JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN dawa.asignaturas a ON a.id_asignatura = p.id_asignatura
        WHERE ep.id_estudiante = p_id_estudiante
    ) q;

    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_horarios_disponibles_por_asignatura(
    p_id_asignatura BIGINT,
    p_id_periodo BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.docente, q.dia_semana, q.hora_inicio), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            hd.id_horario,
            hd.dia_semana,
            hd.hora_inicio,
            hd.hora_fin,
            hd.modalidad,
            d.id_docente,
            u.nombres || ' ' || u.apellidos AS docente
        FROM dawa.docente_asignaturas da
        JOIN dawa.docentes d ON d.id_docente = da.id_docente
        JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
        JOIN dawa.horarios_docente hd ON hd.id_docente = d.id_docente AND hd.id_periodo = da.id_periodo
        WHERE da.id_asignatura = p_id_asignatura
          AND da.id_periodo = p_id_periodo
          AND da.estado = TRUE
          AND hd.estado = TRUE
    ) q;

    RETURN v_result;
END;
$$;

/* ============================================================
   IA Y NOTIFICACIONES
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.sp_ia_buscar_conocimiento(p_texto TEXT, p_limit INTEGER DEFAULT 5)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q)), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT DISTINCT
            bc.id_conocimiento,
            bc.pregunta_clave,
            bc.respuesta,
            bc.categoria,
            similarity(unaccent(lower(bc.pregunta_clave)), unaccent(lower(p_texto))) AS similitud
        FROM dawa.base_conocimiento_ia bc
        LEFT JOIN dawa.conocimiento_palabras_clave_ia pc ON pc.id_conocimiento = bc.id_conocimiento
        WHERE bc.estado = TRUE
          AND (
              unaccent(lower(bc.pregunta_clave)) % unaccent(lower(p_texto))
              OR unaccent(lower(pc.palabra_clave)) ILIKE '%' || unaccent(lower(p_texto)) || '%'
              OR unaccent(lower(bc.categoria)) ILIKE '%' || unaccent(lower(p_texto)) || '%'
          )
        ORDER BY similitud DESC NULLS LAST, bc.id_conocimiento
        LIMIT COALESCE(NULLIF(p_limit, 0), 5)
    ) q;

    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_get_notificaciones_usuario(p_id_usuario BIGINT, p_solo_no_leidas BOOLEAN DEFAULT FALSE)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(n) ORDER BY n.fecha_creacion DESC), '[]'::jsonb)
    INTO v_result
    FROM dawa.notificaciones n
    WHERE n.id_usuario = p_id_usuario
      AND (p_solo_no_leidas = FALSE OR n.leida = FALSE);

    RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION dawa.sp_marcar_notificacion_leida(p_id_notificacion BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE dawa.notificaciones
    SET leida = TRUE,
        fecha_lectura = CURRENT_TIMESTAMP
    WHERE id_notificacion = p_id_notificacion
    RETURNING to_jsonb(notificaciones)
    INTO v_result;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;
