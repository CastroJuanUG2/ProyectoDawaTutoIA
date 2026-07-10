/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 03_indexes_triggers.sql
 Propósito: índices, triggers y validaciones de negocio a nivel de base de datos.
*/

SET search_path TO dawa, public;

/* ============================================================
   ÍNDICES RECOMENDADOS
   ============================================================ */

-- Seguridad
CREATE INDEX IF NOT EXISTS idx_usuarios_correo_lower ON dawa.usuarios (lower(correo));
CREATE INDEX IF NOT EXISTS idx_usuario_roles_usuario ON dawa.usuario_roles (id_usuario);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_rol ON dawa.usuario_roles (id_rol);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_rol ON dawa.rol_permisos (id_rol);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_permiso ON dawa.rol_permisos (id_permiso);

-- Administración académica
CREATE INDEX IF NOT EXISTS idx_carreras_facultad ON dawa.carreras (id_facultad);
CREATE INDEX IF NOT EXISTS idx_asignaturas_carrera ON dawa.asignaturas (id_carrera);
CREATE INDEX IF NOT EXISTS idx_estudiantes_carrera ON dawa.estudiantes (id_carrera);
CREATE INDEX IF NOT EXISTS idx_paralelos_asignatura ON dawa.paralelos (id_asignatura);
CREATE INDEX IF NOT EXISTS idx_paralelos_periodo ON dawa.paralelos (id_periodo);
CREATE INDEX IF NOT EXISTS idx_estudiante_paralelos_estudiante ON dawa.estudiante_paralelos (id_estudiante);
CREATE INDEX IF NOT EXISTS idx_estudiante_paralelos_paralelo ON dawa.estudiante_paralelos (id_paralelo);
CREATE INDEX IF NOT EXISTS idx_docente_asignaturas_docente ON dawa.docente_asignaturas (id_docente);
CREATE INDEX IF NOT EXISTS idx_docente_asignaturas_asignatura ON dawa.docente_asignaturas (id_asignatura);
CREATE INDEX IF NOT EXISTS idx_horarios_docente_docente ON dawa.horarios_docente (id_docente);
CREATE INDEX IF NOT EXISTS idx_horarios_docente_periodo ON dawa.horarios_docente (id_periodo);

-- Tutorías
CREATE INDEX IF NOT EXISTS idx_solicitudes_estudiante_paralelo ON dawa.solicitudes_tutoria (id_estudiante_paralelo);
CREATE INDEX IF NOT EXISTS idx_solicitudes_estado ON dawa.solicitudes_tutoria (estado_solicitud);
CREATE INDEX IF NOT EXISTS idx_solicitudes_fecha ON dawa.solicitudes_tutoria (fecha_solicitud);
CREATE INDEX IF NOT EXISTS idx_tutorias_solicitud ON dawa.tutorias (id_solicitud);
CREATE INDEX IF NOT EXISTS idx_tutorias_horario ON dawa.tutorias (id_horario);
CREATE INDEX IF NOT EXISTS idx_tutorias_fecha ON dawa.tutorias (fecha_tutoria);
CREATE INDEX IF NOT EXISTS idx_tutorias_estado ON dawa.tutorias (estado_tutoria);
CREATE UNIQUE INDEX IF NOT EXISTS uq_tutorias_horario_fecha_confirmada
    ON dawa.tutorias (id_horario, fecha_tutoria)
    WHERE estado_tutoria = 'confirmada';
CREATE INDEX IF NOT EXISTS idx_bitacoras_tutoria ON dawa.bitacoras_tutoria (id_tutoria);
CREATE INDEX IF NOT EXISTS idx_bitacoras_registrado_por ON dawa.bitacoras_tutoria (registrado_por);
CREATE INDEX IF NOT EXISTS idx_casos_estudiante ON dawa.casos_academicos (id_estudiante);
CREATE INDEX IF NOT EXISTS idx_seguimientos_caso ON dawa.seguimientos_academicos (id_caso);

-- IA
CREATE INDEX IF NOT EXISTS idx_base_conocimiento_categoria ON dawa.base_conocimiento_ia (categoria);
CREATE INDEX IF NOT EXISTS idx_conocimiento_palabra_trgm ON dawa.conocimiento_palabras_clave_ia USING gin (palabra_clave gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario ON dawa.conversaciones_ia (id_usuario);
CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion ON dawa.mensajes_ia (id_conversacion);
CREATE INDEX IF NOT EXISTS idx_mensaje_fuentes_mensaje ON dawa.mensaje_fuentes_ia (id_mensaje);
CREATE INDEX IF NOT EXISTS idx_clasificaciones_solicitud ON dawa.clasificaciones_ia (id_solicitud);
CREATE INDEX IF NOT EXISTS idx_feedback_mensaje ON dawa.feedback_ia (id_mensaje);
CREATE INDEX IF NOT EXISTS idx_escalamientos_mensaje ON dawa.escalamientos_ia (id_mensaje_origen);

-- Auditoría y soporte
CREATE INDEX IF NOT EXISTS idx_auditoria_usuario ON dawa.auditoria_accesos (id_usuario);
CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON dawa.auditoria_accesos (fecha_accion);
CREATE INDEX IF NOT EXISTS idx_notificaciones_usuario ON dawa.notificaciones (id_usuario);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON dawa.notificaciones (leida);
CREATE INDEX IF NOT EXISTS idx_logs_servicio ON dawa.logs_sistema (servicio);
CREATE INDEX IF NOT EXISTS idx_logs_fecha ON dawa.logs_sistema (fecha_log);
CREATE INDEX IF NOT EXISTS idx_archivos_subido_por ON dawa.archivos (subido_por);

/* ============================================================
   TRIGGERS DE ACTUALIZACIÓN DE FECHA
   ============================================================ */

DROP TRIGGER IF EXISTS trg_usuarios_actualizado_en ON dawa.usuarios;
CREATE TRIGGER trg_usuarios_actualizado_en
BEFORE UPDATE ON dawa.usuarios
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_facultades_actualizado_en ON dawa.facultades;
CREATE TRIGGER trg_facultades_actualizado_en
BEFORE UPDATE ON dawa.facultades
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_carreras_actualizado_en ON dawa.carreras;
CREATE TRIGGER trg_carreras_actualizado_en
BEFORE UPDATE ON dawa.carreras
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_asignaturas_actualizado_en ON dawa.asignaturas;
CREATE TRIGGER trg_asignaturas_actualizado_en
BEFORE UPDATE ON dawa.asignaturas
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_docentes_actualizado_en ON dawa.docentes;
CREATE TRIGGER trg_docentes_actualizado_en
BEFORE UPDATE ON dawa.docentes
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_estudiantes_actualizado_en ON dawa.estudiantes;
CREATE TRIGGER trg_estudiantes_actualizado_en
BEFORE UPDATE ON dawa.estudiantes
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_paralelos_actualizado_en ON dawa.paralelos;
CREATE TRIGGER trg_paralelos_actualizado_en
BEFORE UPDATE ON dawa.paralelos
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_tutorias_actualizado_en ON dawa.tutorias;
CREATE TRIGGER trg_tutorias_actualizado_en
BEFORE UPDATE ON dawa.tutorias
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_base_conocimiento_actualizado_en ON dawa.base_conocimiento_ia;
CREATE TRIGGER trg_base_conocimiento_actualizado_en
BEFORE UPDATE ON dawa.base_conocimiento_ia
FOR EACH ROW EXECUTE FUNCTION dawa.fn_set_actualizado_en();

/* ============================================================
   VALIDACIÓN: un estudiante no debe estar activo en dos paralelos
   de la misma asignatura y periodo académico.
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.fn_validar_estudiante_paralelo_unico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_asignatura BIGINT;
    v_id_periodo BIGINT;
    v_existe BOOLEAN;
BEGIN
    IF NEW.estado_inscripcion <> 'activo' THEN
        RETURN NEW;
    END IF;

    SELECT p.id_asignatura, p.id_periodo
    INTO v_id_asignatura, v_id_periodo
    FROM dawa.paralelos p
    WHERE p.id_paralelo = NEW.id_paralelo;

    SELECT EXISTS (
        SELECT 1
        FROM dawa.estudiante_paralelos ep
        JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
        WHERE ep.id_estudiante = NEW.id_estudiante
          AND ep.estado_inscripcion = 'activo'
          AND p.id_asignatura = v_id_asignatura
          AND p.id_periodo = v_id_periodo
          AND ep.id_estudiante_paralelo <> COALESCE(NEW.id_estudiante_paralelo, -1)
    ) INTO v_existe;

    IF v_existe THEN
        RAISE EXCEPTION 'El estudiante ya tiene un paralelo activo para la misma asignatura y periodo académico.';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_estudiante_paralelo_unico ON dawa.estudiante_paralelos;
CREATE TRIGGER trg_validar_estudiante_paralelo_unico
BEFORE INSERT OR UPDATE ON dawa.estudiante_paralelos
FOR EACH ROW EXECUTE FUNCTION dawa.fn_validar_estudiante_paralelo_unico();

/* ============================================================
   VALIDACIÓN: coherencia de tutorías.
   - El horario debe estar activo.
   - El horario debe pertenecer al mismo periodo del paralelo.
   - El docente del horario debe estar habilitado para la asignatura.
   ============================================================ */

CREATE OR REPLACE FUNCTION dawa.fn_validar_tutoria_coherencia()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_asignatura BIGINT;
    v_id_periodo_solicitud BIGINT;
    v_id_docente BIGINT;
    v_id_periodo_horario BIGINT;
    v_horario_activo BOOLEAN;
    v_docente_habilitado BOOLEAN;
BEGIN
    SELECT p.id_asignatura, p.id_periodo
    INTO v_id_asignatura, v_id_periodo_solicitud
    FROM dawa.solicitudes_tutoria st
    JOIN dawa.estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
    JOIN dawa.paralelos p ON p.id_paralelo = ep.id_paralelo
    WHERE st.id_solicitud = NEW.id_solicitud;

    SELECT hd.id_docente, hd.id_periodo, hd.estado
    INTO v_id_docente, v_id_periodo_horario, v_horario_activo
    FROM dawa.horarios_docente hd
    WHERE hd.id_horario = NEW.id_horario;

    IF NOT COALESCE(v_horario_activo, FALSE) THEN
        RAISE EXCEPTION 'No se puede asignar una tutoría a un horario docente inactivo.';
    END IF;

    IF v_id_periodo_solicitud <> v_id_periodo_horario THEN
        RAISE EXCEPTION 'El periodo académico de la solicitud no coincide con el periodo del horario docente.';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM dawa.docente_asignaturas da
        WHERE da.id_docente = v_id_docente
          AND da.id_asignatura = v_id_asignatura
          AND da.id_periodo = v_id_periodo_solicitud
          AND da.estado = TRUE
    ) INTO v_docente_habilitado;

    IF NOT v_docente_habilitado THEN
        RAISE EXCEPTION 'El docente del horario no está habilitado para atender la asignatura de la solicitud en este periodo.';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_tutoria_coherencia ON dawa.tutorias;
CREATE TRIGGER trg_validar_tutoria_coherencia
BEFORE INSERT OR UPDATE ON dawa.tutorias
FOR EACH ROW EXECUTE FUNCTION dawa.fn_validar_tutoria_coherencia();
