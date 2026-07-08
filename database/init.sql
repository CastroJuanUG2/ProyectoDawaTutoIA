
-- ================================================================
-- Proyecto DAWA: Sistema Web Inteligente de Gestión de Tutorías
-- Académicas con Agente de IA
-- Archivo: database/init.sql
-- Motor: PostgreSQL 17
-- Uso previsto: Docker + Flask/Python + pgAdmin 9.11
--
-- Este archivo crea la estructura completa de la base de datos:
-- esquema, extensiones, tablas, restricciones, índices,
-- trigger functions, triggers y funciones almacenadas.
--
-- Nota para Docker:
-- La base de datos debe crearse desde POSTGRES_DB en docker-compose.
-- Este script se ejecuta dentro de la base ya creada.
-- ================================================================

CREATE SCHEMA IF NOT EXISTS dawa;
SET search_path TO dawa, public;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;


-- ================================================================
-- 1. Módulo de Seguridad
-- ================================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario        BIGSERIAL PRIMARY KEY,
    nombres           VARCHAR(100) NOT NULL,
    apellidos         VARCHAR(100) NOT NULL,
    correo            VARCHAR(150) NOT NULL UNIQUE,
    password_hash     TEXT NOT NULL,
    estado_usuario    VARCHAR(20) NOT NULL DEFAULT 'activo',
    ultimo_acceso     TIMESTAMP,
    creado_en         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en    TIMESTAMP,
    CONSTRAINT chk_usuarios_estado CHECK (estado_usuario IN ('activo', 'inactivo', 'bloqueado')),
    CONSTRAINT chk_usuarios_correo CHECK (correo ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')
);

CREATE TABLE IF NOT EXISTS roles (
    id_rol       BIGSERIAL PRIMARY KEY,
    nombre_rol   VARCHAR(50) NOT NULL UNIQUE,
    descripcion  TEXT,
    estado       BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS permisos (
    id_permiso   BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(100) NOT NULL UNIQUE,
    descripcion  TEXT,
    estado       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS usuario_roles (
    id_usuario_rol BIGSERIAL PRIMARY KEY,
    id_usuario     BIGINT NOT NULL REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    id_rol         BIGINT NOT NULL REFERENCES roles(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
    asignado_en    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_usuario_roles UNIQUE (id_usuario, id_rol)
);

CREATE TABLE IF NOT EXISTS rol_permisos (
    id_rol_permiso BIGSERIAL PRIMARY KEY,
    id_rol         BIGINT NOT NULL REFERENCES roles(id_rol) ON UPDATE CASCADE ON DELETE CASCADE,
    id_permiso     BIGINT NOT NULL REFERENCES permisos(id_permiso) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_rol_permisos UNIQUE (id_rol, id_permiso)
);

-- ================================================================
-- 2. Módulo de Administración Académica
-- ================================================================

CREATE TABLE IF NOT EXISTS facultades (
    id_facultad    BIGSERIAL PRIMARY KEY,
    nombre         VARCHAR(150) NOT NULL UNIQUE,
    descripcion    TEXT,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carreras (
    id_carrera     BIGSERIAL PRIMARY KEY,
    id_facultad    BIGINT NOT NULL REFERENCES facultades(id_facultad) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre         VARCHAR(150) NOT NULL,
    codigo         VARCHAR(30) UNIQUE,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);

CREATE TABLE IF NOT EXISTS periodos_academicos (
    id_periodo     BIGSERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL UNIQUE,
    fecha_inicio   DATE NOT NULL,
    fecha_fin      DATE NOT NULL,
    estado_periodo VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_periodos_estado CHECK (estado_periodo IN ('pendiente', 'activo', 'cerrado')),
    CONSTRAINT chk_periodos_fechas CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE IF NOT EXISTS asignaturas (
    id_asignatura  BIGSERIAL PRIMARY KEY,
    id_carrera     BIGINT NOT NULL REFERENCES carreras(id_carrera) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre         VARCHAR(150) NOT NULL,
    codigo         VARCHAR(30),
    nivel          INTEGER NOT NULL,
    descripcion    TEXT,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,
    CONSTRAINT chk_asignaturas_nivel CHECK (nivel > 0),
    CONSTRAINT uq_asignaturas_carrera_codigo UNIQUE (id_carrera, codigo)
);

CREATE TABLE IF NOT EXISTS docentes (
    id_docente     BIGSERIAL PRIMARY KEY,
    id_usuario     BIGINT NOT NULL UNIQUE REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    titulo         VARCHAR(100),
    especialidad   VARCHAR(150),
    telefono       VARCHAR(20),
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);

CREATE TABLE IF NOT EXISTS estudiantes (
    id_estudiante  BIGSERIAL PRIMARY KEY,
    id_usuario     BIGINT NOT NULL UNIQUE REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    id_carrera     BIGINT NOT NULL REFERENCES carreras(id_carrera) ON UPDATE CASCADE ON DELETE RESTRICT,
    matricula      VARCHAR(50) NOT NULL UNIQUE,
    nivel_actual   INTEGER NOT NULL,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,
    CONSTRAINT chk_estudiantes_nivel CHECK (nivel_actual > 0)
);

-- Paralelos funciona como grupo por asignatura y periodo.
-- No incluye docente titular ni cupo máximo, por decisión aprobada.
CREATE TABLE IF NOT EXISTS paralelos (
    id_paralelo    BIGSERIAL PRIMARY KEY,
    id_asignatura  BIGINT NOT NULL REFERENCES asignaturas(id_asignatura) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_periodo     BIGINT NOT NULL REFERENCES periodos_academicos(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre         VARCHAR(50) NOT NULL,
    jornada        VARCHAR(30),
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,
    CONSTRAINT chk_paralelos_jornada CHECK (jornada IS NULL OR jornada IN ('matutina', 'vespertina', 'nocturna', 'intensiva')),
    CONSTRAINT uq_paralelos_asignatura_periodo_nombre UNIQUE (id_asignatura, id_periodo, nombre)
);

CREATE TABLE IF NOT EXISTS estudiante_paralelos (
    id_estudiante_paralelo BIGSERIAL PRIMARY KEY,
    id_estudiante          BIGINT NOT NULL REFERENCES estudiantes(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    id_paralelo            BIGINT NOT NULL REFERENCES paralelos(id_paralelo) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha_asignacion       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_inscripcion     VARCHAR(30) NOT NULL DEFAULT 'activo',
    CONSTRAINT chk_estudiante_paralelos_estado CHECK (estado_inscripcion IN ('activo', 'inactivo', 'retirado')),
    CONSTRAINT uq_estudiante_paralelo UNIQUE (id_estudiante, id_paralelo)
);

CREATE TABLE IF NOT EXISTS docente_asignaturas (
    id_docente_asignatura BIGSERIAL PRIMARY KEY,
    id_docente            BIGINT NOT NULL REFERENCES docentes(id_docente) ON UPDATE CASCADE ON DELETE CASCADE,
    id_asignatura         BIGINT NOT NULL REFERENCES asignaturas(id_asignatura) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_periodo            BIGINT NOT NULL REFERENCES periodos_academicos(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado                BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_docente_asignatura_periodo UNIQUE (id_docente, id_asignatura, id_periodo)
);

CREATE TABLE IF NOT EXISTS horarios_docente (
    id_horario    BIGSERIAL PRIMARY KEY,
    id_docente    BIGINT NOT NULL REFERENCES docentes(id_docente) ON UPDATE CASCADE ON DELETE CASCADE,
    id_periodo    BIGINT NOT NULL REFERENCES periodos_academicos(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    dia_semana    VARCHAR(20) NOT NULL,
    hora_inicio   TIME NOT NULL,
    hora_fin      TIME NOT NULL,
    modalidad     VARCHAR(30) NOT NULL,
    estado        BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_horarios_dia CHECK (dia_semana IN ('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo')),
    CONSTRAINT chk_horarios_modalidad CHECK (modalidad IN ('presencial', 'virtual', 'hibrida')),
    CONSTRAINT chk_horarios_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT uq_horario_docente_periodo_bloque UNIQUE (id_docente, id_periodo, dia_semana, hora_inicio, hora_fin)
);

-- ================================================================
-- 3. Módulo de Tutorías y Seguimiento
-- ================================================================

CREATE TABLE IF NOT EXISTS solicitudes_tutoria (
    id_solicitud           BIGSERIAL PRIMARY KEY,
    id_estudiante_paralelo BIGINT NOT NULL REFERENCES estudiante_paralelos(id_estudiante_paralelo) ON UPDATE CASCADE ON DELETE RESTRICT,
    tema                   VARCHAR(200) NOT NULL,
    descripcion            TEXT,
    prioridad              VARCHAR(20) NOT NULL DEFAULT 'media',
    estado_solicitud       VARCHAR(30) NOT NULL DEFAULT 'solicitada',
    origen                 VARCHAR(30) NOT NULL DEFAULT 'web',
    fecha_solicitud        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_solicitudes_prioridad CHECK (prioridad IN ('baja', 'media', 'alta')),
    CONSTRAINT chk_solicitudes_estado CHECK (estado_solicitud IN ('solicitada', 'pendiente', 'aceptada', 'rechazada', 'cancelada')),
    CONSTRAINT chk_solicitudes_origen CHECK (origen IN ('web', 'agente_ia'))
);

CREATE TABLE IF NOT EXISTS tutorias (
    id_tutoria         BIGSERIAL PRIMARY KEY,
    id_solicitud       BIGINT NOT NULL UNIQUE REFERENCES solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_horario         BIGINT NOT NULL REFERENCES horarios_docente(id_horario) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha_tutoria      DATE NOT NULL,
    estado_tutoria     VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    motivo_cancelacion TEXT,
    creado_en          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en     TIMESTAMP,
    CONSTRAINT chk_tutorias_estado CHECK (estado_tutoria IN ('solicitada', 'pendiente', 'confirmada', 'atendida', 'cancelada', 'no_asistida')),
    CONSTRAINT chk_tutorias_cancelacion CHECK (estado_tutoria <> 'cancelada' OR motivo_cancelacion IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS asistencias_tutoria (
    id_asistencia      BIGSERIAL PRIMARY KEY,
    id_tutoria         BIGINT NOT NULL UNIQUE REFERENCES tutorias(id_tutoria) ON UPDATE CASCADE ON DELETE CASCADE,
    asistio_estudiante BOOLEAN NOT NULL DEFAULT FALSE,
    asistio_docente    BOOLEAN NOT NULL DEFAULT FALSE,
    observacion        TEXT,
    fecha_registro     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bitacoras_tutoria (
    id_bitacora          BIGSERIAL PRIMARY KEY,
    id_tutoria           BIGINT NOT NULL REFERENCES tutorias(id_tutoria) ON UPDATE CASCADE ON DELETE CASCADE,
    registrado_por       BIGINT NOT NULL REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    observaciones        TEXT NOT NULL,
    recomendaciones      TEXT,
    acuerdos             TEXT,
    requiere_seguimiento BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS temas_recurrentes (
    id_tema_recurrente BIGSERIAL PRIMARY KEY,
    nombre             VARCHAR(150) NOT NULL UNIQUE,
    descripcion        TEXT,
    estado             BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS solicitud_temas (
    id_solicitud_tema  BIGSERIAL PRIMARY KEY,
    id_solicitud       BIGINT NOT NULL REFERENCES solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    id_tema_recurrente BIGINT NOT NULL REFERENCES temas_recurrentes(id_tema_recurrente) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_solicitud_tema UNIQUE (id_solicitud, id_tema_recurrente)
);

CREATE TABLE IF NOT EXISTS casos_academicos (
    id_caso           BIGSERIAL PRIMARY KEY,
    id_estudiante     BIGINT NOT NULL REFERENCES estudiantes(id_estudiante) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_tutoria_origen BIGINT REFERENCES tutorias(id_tutoria) ON UPDATE CASCADE ON DELETE SET NULL,
    descripcion       TEXT NOT NULL,
    estado_caso       VARCHAR(30) NOT NULL DEFAULT 'abierto',
    fecha_apertura    DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_cierre      DATE,
    CONSTRAINT chk_casos_estado CHECK (estado_caso IN ('abierto', 'en_proceso', 'cerrado')),
    CONSTRAINT chk_casos_fecha_cierre CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura)
);

CREATE TABLE IF NOT EXISTS seguimientos_academicos (
    id_seguimiento      BIGSERIAL PRIMARY KEY,
    id_caso             BIGINT NOT NULL REFERENCES casos_academicos(id_caso) ON UPDATE CASCADE ON DELETE CASCADE,
    descripcion         TEXT NOT NULL,
    estado_seguimiento  VARCHAR(30) NOT NULL DEFAULT 'abierto',
    fecha_registro      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre        DATE,
    CONSTRAINT chk_seguimientos_estado CHECK (estado_seguimiento IN ('abierto', 'en_proceso', 'cerrado'))
);

-- ================================================================
-- 4. Módulo del Agente de IA
-- ================================================================

CREATE TABLE IF NOT EXISTS documentos_base_ia (
    id_documento   BIGSERIAL PRIMARY KEY,
    titulo         VARCHAR(200) NOT NULL,
    descripcion    TEXT,
    fuente         VARCHAR(200),
    tipo_documento VARCHAR(50),
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS base_conocimiento_ia (
    id_conocimiento BIGSERIAL PRIMARY KEY,
    id_documento    BIGINT REFERENCES documentos_base_ia(id_documento) ON UPDATE CASCADE ON DELETE SET NULL,
    pregunta_clave  VARCHAR(250) NOT NULL,
    respuesta       TEXT NOT NULL,
    categoria       VARCHAR(100),
    estado          BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en  TIMESTAMP
);

CREATE TABLE IF NOT EXISTS conocimiento_palabras_clave_ia (
    id_palabra_clave BIGSERIAL PRIMARY KEY,
    id_conocimiento  BIGINT NOT NULL REFERENCES base_conocimiento_ia(id_conocimiento) ON UPDATE CASCADE ON DELETE CASCADE,
    palabra_clave    VARCHAR(100) NOT NULL,
    CONSTRAINT uq_conocimiento_palabra UNIQUE (id_conocimiento, palabra_clave)
);

CREATE TABLE IF NOT EXISTS conversaciones_ia (
    id_conversacion     BIGSERIAL PRIMARY KEY,
    id_usuario          BIGINT NOT NULL REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    contexto            VARCHAR(150),
    estado_conversacion VARCHAR(30) NOT NULL DEFAULT 'abierta',
    fecha_inicio        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre        TIMESTAMP,
    CONSTRAINT chk_conversaciones_estado CHECK (estado_conversacion IN ('abierta', 'cerrada', 'escalada'))
);

CREATE TABLE IF NOT EXISTS mensajes_ia (
    id_mensaje             BIGSERIAL PRIMARY KEY,
    id_conversacion        BIGINT NOT NULL REFERENCES conversaciones_ia(id_conversacion) ON UPDATE CASCADE ON DELETE CASCADE,
    remitente              VARCHAR(20) NOT NULL,
    mensaje                TEXT NOT NULL,
    requiere_escalamiento  BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_mensaje          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_mensajes_remitente CHECK (remitente IN ('usuario', 'agente'))
);

CREATE TABLE IF NOT EXISTS mensaje_fuentes_ia (
    id_mensaje_fuente BIGSERIAL PRIMARY KEY,
    id_mensaje        BIGINT NOT NULL REFERENCES mensajes_ia(id_mensaje) ON UPDATE CASCADE ON DELETE CASCADE,
    id_conocimiento   BIGINT NOT NULL REFERENCES base_conocimiento_ia(id_conocimiento) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_mensaje_fuente UNIQUE (id_mensaje, id_conocimiento)
);

CREATE TABLE IF NOT EXISTS clasificaciones_ia (
    id_clasificacion       BIGSERIAL PRIMARY KEY,
    id_solicitud           BIGINT NOT NULL REFERENCES solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    id_asignatura_sugerida BIGINT REFERENCES asignaturas(id_asignatura) ON UPDATE CASCADE ON DELETE SET NULL,
    id_docente_sugerido    BIGINT REFERENCES docentes(id_docente) ON UPDATE CASCADE ON DELETE SET NULL,
    categoria_detectada    VARCHAR(100),
    nivel_confianza        NUMERIC(5,2),
    requiere_revision      BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_clasificacion    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_clasificaciones_confianza CHECK (nivel_confianza IS NULL OR (nivel_confianza >= 0 AND nivel_confianza <= 100))
);

CREATE TABLE IF NOT EXISTS feedback_ia (
    id_feedback    BIGSERIAL PRIMARY KEY,
    id_mensaje     BIGINT NOT NULL REFERENCES mensajes_ia(id_mensaje) ON UPDATE CASCADE ON DELETE CASCADE,
    id_usuario     BIGINT NOT NULL REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    util           BOOLEAN NOT NULL,
    comentario     TEXT,
    fecha_feedback TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_feedback_mensaje_usuario UNIQUE (id_mensaje, id_usuario)
);

CREATE TABLE IF NOT EXISTS escalamientos_ia (
    id_escalamiento     BIGSERIAL PRIMARY KEY,
    id_mensaje_origen   BIGINT NOT NULL REFERENCES mensajes_ia(id_mensaje) ON UPDATE CASCADE ON DELETE CASCADE,
    id_usuario_destino  BIGINT REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    motivo              TEXT NOT NULL,
    estado_escalamiento VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    fecha_escalamiento  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion    TIMESTAMP,
    CONSTRAINT chk_escalamientos_estado CHECK (estado_escalamiento IN ('pendiente', 'en_revision', 'resuelto', 'cancelado'))
);

-- ================================================================
-- 5. Auditoría, Notificaciones y Soporte
-- ================================================================

CREATE TABLE IF NOT EXISTS auditoria_accesos (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_usuario   BIGINT REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    accion       VARCHAR(100) NOT NULL,
    ip_origen    VARCHAR(50),
    user_agent   TEXT,
    fecha_accion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notificaciones (
    id_notificacion BIGSERIAL PRIMARY KEY,
    id_usuario      BIGINT NOT NULL REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    titulo          VARCHAR(150) NOT NULL,
    mensaje         TEXT NOT NULL,
    tipo            VARCHAR(50),
    leida           BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_lectura   TIMESTAMP
);

CREATE TABLE IF NOT EXISTS parametros_sistema (
    id_parametro  BIGSERIAL PRIMARY KEY,
    clave         VARCHAR(100) NOT NULL UNIQUE,
    valor         TEXT NOT NULL,
    tipo_dato     VARCHAR(30) NOT NULL,
    descripcion   TEXT,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_parametros_tipo CHECK (tipo_dato IN ('integer', 'boolean', 'text', 'decimal', 'time', 'json'))
);

CREATE TABLE IF NOT EXISTS logs_sistema (
    id_log      BIGSERIAL PRIMARY KEY,
    id_usuario  BIGINT REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    servicio    VARCHAR(100),
    accion      VARCHAR(150),
    descripcion TEXT,
    nivel       VARCHAR(30),
    fecha_log   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_logs_nivel CHECK (nivel IS NULL OR nivel IN ('info', 'warning', 'error', 'critical'))
);

CREATE TABLE IF NOT EXISTS archivos (
    id_archivo     BIGSERIAL PRIMARY KEY,
    nombre_archivo VARCHAR(200) NOT NULL,
    ruta_archivo   TEXT NOT NULL,
    tipo_archivo   VARCHAR(100),
    subido_por     BIGINT REFERENCES usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    fecha_subida   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS archivo_solicitud (
    id_archivo_solicitud BIGSERIAL PRIMARY KEY,
    id_archivo           BIGINT NOT NULL REFERENCES archivos(id_archivo) ON UPDATE CASCADE ON DELETE CASCADE,
    id_solicitud         BIGINT NOT NULL REFERENCES solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_archivo_solicitud UNIQUE (id_archivo, id_solicitud)
);

CREATE TABLE IF NOT EXISTS archivo_bitacora (
    id_archivo_bitacora BIGSERIAL PRIMARY KEY,
    id_archivo          BIGINT NOT NULL REFERENCES archivos(id_archivo) ON UPDATE CASCADE ON DELETE CASCADE,
    id_bitacora         BIGINT NOT NULL REFERENCES bitacoras_tutoria(id_bitacora) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_archivo_bitacora UNIQUE (id_archivo, id_bitacora)
);

CREATE TABLE IF NOT EXISTS archivo_documento_ia (
    id_archivo_documento_ia BIGSERIAL PRIMARY KEY,
    id_archivo              BIGINT NOT NULL REFERENCES archivos(id_archivo) ON UPDATE CASCADE ON DELETE CASCADE,
    id_documento            BIGINT NOT NULL REFERENCES documentos_base_ia(id_documento) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_archivo_documento_ia UNIQUE (id_archivo, id_documento)
);

-- Tabla técnica para controlar qué tablas pueden ser operadas por el motor CRUD.
CREATE TABLE IF NOT EXISTS crud_metadata (
    table_name         TEXT PRIMARY KEY,
    pk_column          TEXT NOT NULL,
    soft_delete_column TEXT,
    soft_delete_value  TEXT,
    enabled            BOOLEAN NOT NULL DEFAULT TRUE
);


-- ================================================================
-- Índices para consultas frecuentes
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_usuarios_correo ON usuarios (correo);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_usuario ON usuario_roles (id_usuario);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_rol ON usuario_roles (id_rol);
CREATE INDEX IF NOT EXISTS idx_rol_permisos_rol ON rol_permisos (id_rol);

CREATE INDEX IF NOT EXISTS idx_carreras_facultad ON carreras (id_facultad);
CREATE INDEX IF NOT EXISTS idx_asignaturas_carrera ON asignaturas (id_carrera);
CREATE INDEX IF NOT EXISTS idx_estudiantes_carrera ON estudiantes (id_carrera);
CREATE INDEX IF NOT EXISTS idx_paralelos_asignatura_periodo ON paralelos (id_asignatura, id_periodo);
CREATE INDEX IF NOT EXISTS idx_estudiante_paralelos_estudiante ON estudiante_paralelos (id_estudiante);
CREATE INDEX IF NOT EXISTS idx_estudiante_paralelos_paralelo ON estudiante_paralelos (id_paralelo);
CREATE INDEX IF NOT EXISTS idx_docente_asignaturas_docente ON docente_asignaturas (id_docente);
CREATE INDEX IF NOT EXISTS idx_docente_asignaturas_asignatura_periodo ON docente_asignaturas (id_asignatura, id_periodo);
CREATE INDEX IF NOT EXISTS idx_horarios_docente_docente_periodo ON horarios_docente (id_docente, id_periodo);

CREATE INDEX IF NOT EXISTS idx_solicitudes_estudiante_paralelo ON solicitudes_tutoria (id_estudiante_paralelo);
CREATE INDEX IF NOT EXISTS idx_solicitudes_estado_fecha ON solicitudes_tutoria (estado_solicitud, fecha_solicitud);
CREATE INDEX IF NOT EXISTS idx_tutorias_horario_fecha ON tutorias (id_horario, fecha_tutoria);
CREATE INDEX IF NOT EXISTS idx_tutorias_estado_fecha ON tutorias (estado_tutoria, fecha_tutoria);
CREATE UNIQUE INDEX IF NOT EXISTS uq_tutorias_horario_fecha_confirmada
    ON tutorias (id_horario, fecha_tutoria)
    WHERE estado_tutoria = 'confirmada';
CREATE INDEX IF NOT EXISTS idx_bitacoras_tutoria ON bitacoras_tutoria (id_tutoria);
CREATE INDEX IF NOT EXISTS idx_casos_estudiante ON casos_academicos (id_estudiante);
CREATE INDEX IF NOT EXISTS idx_seguimientos_caso ON seguimientos_academicos (id_caso);

CREATE INDEX IF NOT EXISTS idx_base_conocimiento_categoria ON base_conocimiento_ia (categoria);
CREATE INDEX IF NOT EXISTS idx_base_conocimiento_pregunta_trgm ON base_conocimiento_ia USING GIN (pregunta_clave gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_base_conocimiento_respuesta_trgm ON base_conocimiento_ia USING GIN (respuesta gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_palabras_clave_trgm ON conocimiento_palabras_clave_ia USING GIN (palabra_clave gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuario ON conversaciones_ia (id_usuario);
CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion ON mensajes_ia (id_conversacion);
CREATE INDEX IF NOT EXISTS idx_clasificaciones_solicitud ON clasificaciones_ia (id_solicitud);
CREATE INDEX IF NOT EXISTS idx_feedback_mensaje ON feedback_ia (id_mensaje);
CREATE INDEX IF NOT EXISTS idx_escalamientos_mensaje ON escalamientos_ia (id_mensaje_origen);

CREATE INDEX IF NOT EXISTS idx_auditoria_usuario_fecha ON auditoria_accesos (id_usuario, fecha_accion);
CREATE INDEX IF NOT EXISTS idx_notificaciones_usuario_leida ON notificaciones (id_usuario, leida);
CREATE INDEX IF NOT EXISTS idx_logs_servicio_fecha ON logs_sistema (servicio, fecha_log);
CREATE INDEX IF NOT EXISTS idx_archivos_subido_por ON archivos (subido_por);


-- ================================================================
-- Trigger functions y triggers de reglas de negocio
-- ================================================================

CREATE OR REPLACE FUNCTION fn_set_actualizado_en()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_estudiante_paralelo_unico()
RETURNS TRIGGER AS $$
DECLARE
    v_id_asignatura BIGINT;
    v_id_periodo BIGINT;
BEGIN
    IF NEW.estado_inscripcion <> 'activo' THEN
        RETURN NEW;
    END IF;

    SELECT p.id_asignatura, p.id_periodo
    INTO v_id_asignatura, v_id_periodo
    FROM paralelos p
    WHERE p.id_paralelo = NEW.id_paralelo;

    IF EXISTS (
        SELECT 1
        FROM estudiante_paralelos ep
        JOIN paralelos p ON p.id_paralelo = ep.id_paralelo
        WHERE ep.id_estudiante = NEW.id_estudiante
          AND ep.estado_inscripcion = 'activo'
          AND ep.id_estudiante_paralelo <> COALESCE(NEW.id_estudiante_paralelo, -1)
          AND p.id_asignatura = v_id_asignatura
          AND p.id_periodo = v_id_periodo
    ) THEN
        RAISE EXCEPTION 'El estudiante ya tiene un paralelo activo para la misma asignatura y periodo.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_tutoria_coherencia()
RETURNS TRIGGER AS $$
DECLARE
    v_id_asignatura BIGINT;
    v_id_periodo_solicitud BIGINT;
    v_id_docente BIGINT;
    v_id_periodo_horario BIGINT;
    v_horario_activo BOOLEAN;
BEGIN
    SELECT p.id_asignatura, p.id_periodo
    INTO v_id_asignatura, v_id_periodo_solicitud
    FROM solicitudes_tutoria st
    JOIN estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
    JOIN paralelos p ON p.id_paralelo = ep.id_paralelo
    WHERE st.id_solicitud = NEW.id_solicitud;

    IF v_id_asignatura IS NULL THEN
        RAISE EXCEPTION 'La solicitud no está asociada a una asignatura válida.';
    END IF;

    SELECT hd.id_docente, hd.id_periodo, hd.estado
    INTO v_id_docente, v_id_periodo_horario, v_horario_activo
    FROM horarios_docente hd
    WHERE hd.id_horario = NEW.id_horario;

    IF v_id_docente IS NULL THEN
        RAISE EXCEPTION 'El horario docente no existe.';
    END IF;

    IF v_horario_activo IS FALSE THEN
        RAISE EXCEPTION 'No se puede asignar una tutoría a un horario docente inactivo.';
    END IF;

    IF v_id_periodo_solicitud <> v_id_periodo_horario THEN
        RAISE EXCEPTION 'El periodo de la solicitud no coincide con el periodo del horario docente.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM docente_asignaturas da
        WHERE da.id_docente = v_id_docente
          AND da.id_asignatura = v_id_asignatura
          AND da.id_periodo = v_id_periodo_solicitud
          AND da.estado = TRUE
    ) THEN
        RAISE EXCEPTION 'El docente del horario no está habilitado para atender la asignatura solicitada en el periodo correspondiente.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_usuarios_actualizado_en ON usuarios;
CREATE TRIGGER trg_usuarios_actualizado_en BEFORE UPDATE ON usuarios
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_facultades_actualizado_en ON facultades;
CREATE TRIGGER trg_facultades_actualizado_en BEFORE UPDATE ON facultades
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_carreras_actualizado_en ON carreras;
CREATE TRIGGER trg_carreras_actualizado_en BEFORE UPDATE ON carreras
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_asignaturas_actualizado_en ON asignaturas;
CREATE TRIGGER trg_asignaturas_actualizado_en BEFORE UPDATE ON asignaturas
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_docentes_actualizado_en ON docentes;
CREATE TRIGGER trg_docentes_actualizado_en BEFORE UPDATE ON docentes
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_estudiantes_actualizado_en ON estudiantes;
CREATE TRIGGER trg_estudiantes_actualizado_en BEFORE UPDATE ON estudiantes
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_paralelos_actualizado_en ON paralelos;
CREATE TRIGGER trg_paralelos_actualizado_en BEFORE UPDATE ON paralelos
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_tutorias_actualizado_en ON tutorias;
CREATE TRIGGER trg_tutorias_actualizado_en BEFORE UPDATE ON tutorias
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_base_conocimiento_actualizado_en ON base_conocimiento_ia;
CREATE TRIGGER trg_base_conocimiento_actualizado_en BEFORE UPDATE ON base_conocimiento_ia
FOR EACH ROW EXECUTE FUNCTION fn_set_actualizado_en();

DROP TRIGGER IF EXISTS trg_validar_estudiante_paralelo_unico ON estudiante_paralelos;
CREATE TRIGGER trg_validar_estudiante_paralelo_unico BEFORE INSERT OR UPDATE ON estudiante_paralelos
FOR EACH ROW EXECUTE FUNCTION fn_validar_estudiante_paralelo_unico();

DROP TRIGGER IF EXISTS trg_validar_tutoria_coherencia ON tutorias;
CREATE TRIGGER trg_validar_tutoria_coherencia BEFORE INSERT OR UPDATE ON tutorias
FOR EACH ROW EXECUTE FUNCTION fn_validar_tutoria_coherencia();

-- ================================================================
-- Metadatos del motor CRUD
-- ================================================================

INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('usuarios', 'id_usuario', 'estado_usuario', 'inactivo', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('roles', 'id_rol', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('permisos', 'id_permiso', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('usuario_roles', 'id_usuario_rol', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('rol_permisos', 'id_rol_permiso', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('facultades', 'id_facultad', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('carreras', 'id_carrera', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('periodos_academicos', 'id_periodo', 'estado_periodo', 'cerrado', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('asignaturas', 'id_asignatura', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('docentes', 'id_docente', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('estudiantes', 'id_estudiante', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('paralelos', 'id_paralelo', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('estudiante_paralelos', 'id_estudiante_paralelo', 'estado_inscripcion', 'inactivo', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('docente_asignaturas', 'id_docente_asignatura', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('horarios_docente', 'id_horario', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('solicitudes_tutoria', 'id_solicitud', 'estado_solicitud', 'cancelada', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('tutorias', 'id_tutoria', 'estado_tutoria', 'cancelada', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('asistencias_tutoria', 'id_asistencia', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('bitacoras_tutoria', 'id_bitacora', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('temas_recurrentes', 'id_tema_recurrente', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('solicitud_temas', 'id_solicitud_tema', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('casos_academicos', 'id_caso', 'estado_caso', 'cerrado', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('seguimientos_academicos', 'id_seguimiento', 'estado_seguimiento', 'cerrado', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('documentos_base_ia', 'id_documento', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('base_conocimiento_ia', 'id_conocimiento', 'estado', 'false', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('conocimiento_palabras_clave_ia', 'id_palabra_clave', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('conversaciones_ia', 'id_conversacion', 'estado_conversacion', 'cerrada', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('mensajes_ia', 'id_mensaje', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('mensaje_fuentes_ia', 'id_mensaje_fuente', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('clasificaciones_ia', 'id_clasificacion', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('feedback_ia', 'id_feedback', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('escalamientos_ia', 'id_escalamiento', 'estado_escalamiento', 'cancelado', TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('auditoria_accesos', 'id_auditoria', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('notificaciones', 'id_notificacion', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('parametros_sistema', 'id_parametro', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('logs_sistema', 'id_log', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('archivos', 'id_archivo', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('archivo_solicitud', 'id_archivo_solicitud', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('archivo_bitacora', 'id_archivo_bitacora', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;
INSERT INTO crud_metadata(table_name, pk_column, soft_delete_column, soft_delete_value, enabled) VALUES ('archivo_documento_ia', 'id_archivo_documento_ia', NULL, NULL, TRUE) ON CONFLICT (table_name) DO UPDATE SET pk_column = EXCLUDED.pk_column, soft_delete_column = EXCLUDED.soft_delete_column, soft_delete_value = EXCLUDED.soft_delete_value, enabled = EXCLUDED.enabled;


-- ================================================================
-- Motor CRUD genérico con JSONB
-- Backend Flask debe llamar los wrappers sp_* definidos más abajo.
-- ================================================================

CREATE OR REPLACE FUNCTION fn_assert_crud_table(p_table_name TEXT)
RETURNS crud_metadata AS $$
DECLARE
    v_meta crud_metadata%ROWTYPE;
BEGIN
    SELECT * INTO v_meta
    FROM crud_metadata
    WHERE table_name = p_table_name
      AND enabled = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tabla no habilitada para CRUD: %', p_table_name;
    END IF;

    IF to_regclass(format('dawa.%I', p_table_name)) IS NULL THEN
        RAISE EXCEPTION 'Tabla inexistente en esquema dawa: %', p_table_name;
    END IF;

    RETURN v_meta;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION fn_crud_create(p_table_name TEXT, p_payload JSONB)
RETURNS JSONB AS $$
DECLARE
    v_meta crud_metadata%ROWTYPE;
    v_reg REGCLASS;
    v_cols TEXT;
    v_select TEXT;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    v_meta := fn_assert_crud_table(p_table_name);
    v_reg := to_regclass(format('dawa.%I', p_table_name));

    SELECT string_agg(format('%I', a.attname), ', ' ORDER BY a.attnum),
           string_agg(format('x.%I', a.attname), ', ' ORDER BY a.attnum)
    INTO v_cols, v_select
    FROM pg_attribute a
    WHERE a.attrelid = v_reg
      AND a.attnum > 0
      AND NOT a.attisdropped
      AND a.attname <> v_meta.pk_column
      AND a.attgenerated = ''
      AND a.attname IN (SELECT jsonb_object_keys(p_payload));

    IF v_cols IS NULL THEN
        RAISE EXCEPTION 'Payload sin columnas válidas para tabla %', p_table_name;
    END IF;

    v_sql := format(
        'INSERT INTO dawa.%I (%s) SELECT %s FROM jsonb_populate_record(NULL::dawa.%I, $1) AS x RETURNING to_jsonb(%I.*)',
        p_table_name, v_cols, v_select, p_table_name, p_table_name
    );

    EXECUTE v_sql INTO v_result USING p_payload;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_crud_get(p_table_name TEXT, p_id BIGINT)
RETURNS JSONB AS $$
DECLARE
    v_meta crud_metadata%ROWTYPE;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    v_meta := fn_assert_crud_table(p_table_name);
    v_sql := format('SELECT COALESCE(to_jsonb(t), ''{}''::jsonb) FROM dawa.%I t WHERE t.%I = $1', p_table_name, v_meta.pk_column);
    EXECUTE v_sql INTO v_result USING p_id;
    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION fn_crud_list(p_table_name TEXT, p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$
DECLARE
    v_meta crud_metadata%ROWTYPE;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    v_meta := fn_assert_crud_table(p_table_name);
    v_sql := format(
        'SELECT COALESCE(jsonb_agg(to_jsonb(t)), ''[]''::jsonb) FROM (SELECT * FROM dawa.%I ORDER BY %I LIMIT $1 OFFSET $2) t',
        p_table_name, v_meta.pk_column
    );
    EXECUTE v_sql INTO v_result USING GREATEST(p_limit, 1), GREATEST(p_offset, 0);
    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION fn_crud_update(p_table_name TEXT, p_id BIGINT, p_payload JSONB)
RETURNS JSONB AS $$
DECLARE
    v_meta crud_metadata%ROWTYPE;
    v_reg REGCLASS;
    v_set TEXT;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    v_meta := fn_assert_crud_table(p_table_name);
    v_reg := to_regclass(format('dawa.%I', p_table_name));

    SELECT string_agg(format('%I = x.%I', a.attname, a.attname), ', ' ORDER BY a.attnum)
    INTO v_set
    FROM pg_attribute a
    WHERE a.attrelid = v_reg
      AND a.attnum > 0
      AND NOT a.attisdropped
      AND a.attname <> v_meta.pk_column
      AND a.attgenerated = ''
      AND a.attname IN (SELECT jsonb_object_keys(p_payload));

    IF v_set IS NULL THEN
        RAISE EXCEPTION 'Payload sin columnas válidas para actualizar tabla %', p_table_name;
    END IF;

    v_sql := format(
        'UPDATE dawa.%I AS t SET %s FROM jsonb_populate_record(NULL::dawa.%I, $1) AS x WHERE t.%I = $2 RETURNING to_jsonb(t.*)',
        p_table_name, v_set, p_table_name, v_meta.pk_column
    );

    EXECUTE v_sql INTO v_result USING p_payload, p_id;
    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_crud_delete(p_table_name TEXT, p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$
DECLARE
    v_meta crud_metadata%ROWTYPE;
    v_sql TEXT;
    v_result JSONB;
BEGIN
    v_meta := fn_assert_crud_table(p_table_name);

    IF p_hard_delete OR v_meta.soft_delete_column IS NULL THEN
        v_sql := format('DELETE FROM dawa.%I WHERE %I = $1 RETURNING to_jsonb(%I.*)', p_table_name, v_meta.pk_column, p_table_name);
        EXECUTE v_sql INTO v_result USING p_id;
        RETURN COALESCE(v_result, '{}'::jsonb);
    END IF;

    v_sql := format(
        'UPDATE dawa.%I AS t
         SET %I = x.%I
         FROM jsonb_populate_record(NULL::dawa.%I, jsonb_build_object(%L, $1)) AS x
         WHERE t.%I = $2
         RETURNING to_jsonb(t.*)',
        p_table_name,
        v_meta.soft_delete_column,
        v_meta.soft_delete_column,
        p_table_name,
        v_meta.soft_delete_column,
        v_meta.pk_column
    );
    EXECUTE v_sql INTO v_result USING v_meta.soft_delete_value, p_id;
    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- Wrappers CRUD por tabla
-- Estas funciones son las que debe consumir Flask para operaciones CRUD.
-- ================================================================


CREATE OR REPLACE FUNCTION sp_create_usuarios(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('usuarios', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_usuarios(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('usuarios', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_usuarios(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('usuarios', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_usuarios(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('usuarios', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_usuarios(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('usuarios', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_roles(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('roles', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_roles(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('roles', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_roles(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('roles', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_roles(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('roles', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_roles(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('roles', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_permisos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('permisos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_permisos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('permisos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_permisos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('permisos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_permisos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('permisos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_permisos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('permisos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_usuario_roles(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('usuario_roles', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_usuario_roles(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('usuario_roles', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_usuario_roles(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('usuario_roles', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_usuario_roles(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('usuario_roles', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_usuario_roles(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('usuario_roles', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_rol_permisos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('rol_permisos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_rol_permisos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('rol_permisos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_rol_permisos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('rol_permisos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_rol_permisos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('rol_permisos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_rol_permisos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('rol_permisos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_facultades(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('facultades', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_facultades(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('facultades', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_facultades(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('facultades', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_facultades(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('facultades', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_facultades(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('facultades', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_carreras(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('carreras', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_carreras(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('carreras', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_carreras(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('carreras', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_carreras(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('carreras', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_carreras(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('carreras', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_periodos_academicos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('periodos_academicos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_periodos_academicos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('periodos_academicos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_periodos_academicos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('periodos_academicos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_periodos_academicos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('periodos_academicos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_periodos_academicos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('periodos_academicos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_asignaturas(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('asignaturas', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_asignaturas(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('asignaturas', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_asignaturas(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('asignaturas', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_asignaturas(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('asignaturas', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_asignaturas(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('asignaturas', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_docentes(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('docentes', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_docentes(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('docentes', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_docentes(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('docentes', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_docentes(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('docentes', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_docentes(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('docentes', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_estudiantes(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('estudiantes', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_estudiantes(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('estudiantes', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_estudiantes(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('estudiantes', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_estudiantes(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('estudiantes', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_estudiantes(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('estudiantes', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_paralelos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('paralelos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_paralelos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('paralelos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_paralelos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('paralelos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_paralelos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('paralelos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_paralelos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('paralelos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_estudiante_paralelos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('estudiante_paralelos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_estudiante_paralelos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('estudiante_paralelos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_estudiante_paralelos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('estudiante_paralelos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_estudiante_paralelos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('estudiante_paralelos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_estudiante_paralelos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('estudiante_paralelos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_docente_asignaturas(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('docente_asignaturas', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_docente_asignaturas(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('docente_asignaturas', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_docente_asignaturas(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('docente_asignaturas', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_docente_asignaturas(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('docente_asignaturas', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_docente_asignaturas(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('docente_asignaturas', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_horarios_docente(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('horarios_docente', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_horarios_docente(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('horarios_docente', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_horarios_docente(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('horarios_docente', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_horarios_docente(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('horarios_docente', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_horarios_docente(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('horarios_docente', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_solicitudes_tutoria(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('solicitudes_tutoria', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_solicitudes_tutoria(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('solicitudes_tutoria', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_solicitudes_tutoria(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('solicitudes_tutoria', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_solicitudes_tutoria(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('solicitudes_tutoria', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_solicitudes_tutoria(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('solicitudes_tutoria', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_tutorias(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('tutorias', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_tutorias(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('tutorias', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_tutorias(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('tutorias', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_tutorias(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('tutorias', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_tutorias(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('tutorias', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_asistencias_tutoria(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('asistencias_tutoria', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_asistencias_tutoria(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('asistencias_tutoria', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_asistencias_tutoria(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('asistencias_tutoria', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_asistencias_tutoria(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('asistencias_tutoria', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_asistencias_tutoria(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('asistencias_tutoria', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_bitacoras_tutoria(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('bitacoras_tutoria', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_bitacoras_tutoria(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('bitacoras_tutoria', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_bitacoras_tutoria(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('bitacoras_tutoria', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_bitacoras_tutoria(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('bitacoras_tutoria', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_bitacoras_tutoria(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('bitacoras_tutoria', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_temas_recurrentes(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('temas_recurrentes', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_temas_recurrentes(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('temas_recurrentes', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_temas_recurrentes(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('temas_recurrentes', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_temas_recurrentes(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('temas_recurrentes', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_temas_recurrentes(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('temas_recurrentes', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_solicitud_temas(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('solicitud_temas', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_solicitud_temas(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('solicitud_temas', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_solicitud_temas(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('solicitud_temas', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_solicitud_temas(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('solicitud_temas', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_solicitud_temas(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('solicitud_temas', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_casos_academicos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('casos_academicos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_casos_academicos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('casos_academicos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_casos_academicos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('casos_academicos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_casos_academicos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('casos_academicos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_casos_academicos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('casos_academicos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_seguimientos_academicos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('seguimientos_academicos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_seguimientos_academicos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('seguimientos_academicos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_seguimientos_academicos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('seguimientos_academicos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_seguimientos_academicos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('seguimientos_academicos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_seguimientos_academicos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('seguimientos_academicos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_documentos_base_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('documentos_base_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_documentos_base_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('documentos_base_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_documentos_base_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('documentos_base_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_documentos_base_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('documentos_base_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_documentos_base_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('documentos_base_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_base_conocimiento_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('base_conocimiento_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_base_conocimiento_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('base_conocimiento_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_base_conocimiento_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('base_conocimiento_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_base_conocimiento_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('base_conocimiento_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_base_conocimiento_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('base_conocimiento_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_conocimiento_palabras_clave_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('conocimiento_palabras_clave_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_conocimiento_palabras_clave_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('conocimiento_palabras_clave_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_conocimiento_palabras_clave_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('conocimiento_palabras_clave_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_conocimiento_palabras_clave_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('conocimiento_palabras_clave_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_conocimiento_palabras_clave_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('conocimiento_palabras_clave_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_conversaciones_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('conversaciones_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_conversaciones_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('conversaciones_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_conversaciones_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('conversaciones_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_conversaciones_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('conversaciones_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_conversaciones_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('conversaciones_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_mensajes_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('mensajes_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_mensajes_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('mensajes_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_mensajes_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('mensajes_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_mensajes_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('mensajes_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_mensajes_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('mensajes_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_mensaje_fuentes_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('mensaje_fuentes_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_mensaje_fuentes_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('mensaje_fuentes_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_mensaje_fuentes_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('mensaje_fuentes_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_mensaje_fuentes_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('mensaje_fuentes_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_mensaje_fuentes_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('mensaje_fuentes_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_clasificaciones_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('clasificaciones_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_clasificaciones_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('clasificaciones_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_clasificaciones_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('clasificaciones_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_clasificaciones_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('clasificaciones_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_clasificaciones_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('clasificaciones_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_feedback_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('feedback_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_feedback_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('feedback_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_feedback_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('feedback_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_feedback_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('feedback_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_feedback_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('feedback_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_escalamientos_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('escalamientos_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_escalamientos_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('escalamientos_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_escalamientos_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('escalamientos_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_escalamientos_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('escalamientos_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_escalamientos_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('escalamientos_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_auditoria_accesos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('auditoria_accesos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_auditoria_accesos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('auditoria_accesos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_auditoria_accesos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('auditoria_accesos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_auditoria_accesos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('auditoria_accesos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_auditoria_accesos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('auditoria_accesos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_notificaciones(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('notificaciones', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_notificaciones(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('notificaciones', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_notificaciones(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('notificaciones', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_notificaciones(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('notificaciones', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_notificaciones(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('notificaciones', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_parametros_sistema(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('parametros_sistema', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_parametros_sistema(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('parametros_sistema', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_parametros_sistema(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('parametros_sistema', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_parametros_sistema(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('parametros_sistema', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_parametros_sistema(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('parametros_sistema', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_logs_sistema(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('logs_sistema', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_logs_sistema(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('logs_sistema', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_logs_sistema(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('logs_sistema', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_logs_sistema(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('logs_sistema', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_logs_sistema(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('logs_sistema', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_archivos(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('archivos', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_archivos(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('archivos', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_archivos(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('archivos', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_archivos(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('archivos', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_archivos(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('archivos', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_archivo_solicitud(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('archivo_solicitud', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_archivo_solicitud(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('archivo_solicitud', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_archivo_solicitud(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('archivo_solicitud', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_archivo_solicitud(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('archivo_solicitud', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_archivo_solicitud(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('archivo_solicitud', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_archivo_bitacora(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('archivo_bitacora', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_archivo_bitacora(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('archivo_bitacora', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_archivo_bitacora(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('archivo_bitacora', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_archivo_bitacora(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('archivo_bitacora', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_archivo_bitacora(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('archivo_bitacora', p_id, p_hard_delete); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_create_archivo_documento_ia(p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_create('archivo_documento_ia', p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_get_archivo_documento_ia(p_id BIGINT)
RETURNS JSONB AS $$ SELECT fn_crud_get('archivo_documento_ia', p_id); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_list_archivo_documento_ia(p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)
RETURNS JSONB AS $$ SELECT fn_crud_list('archivo_documento_ia', p_limit, p_offset); $$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION sp_update_archivo_documento_ia(p_id BIGINT, p_data JSONB)
RETURNS JSONB AS $$ SELECT fn_crud_update('archivo_documento_ia', p_id, p_data); $$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION sp_delete_archivo_documento_ia(p_id BIGINT, p_hard_delete BOOLEAN DEFAULT FALSE)
RETURNS JSONB AS $$ SELECT fn_crud_delete('archivo_documento_ia', p_id, p_hard_delete); $$ LANGUAGE sql;

-- ================================================================
-- Funciones de dominio para autenticación, tutorías, IA y notificaciones
-- ================================================================

CREATE OR REPLACE FUNCTION sp_auth_login_lookup(p_correo VARCHAR)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'usuario', to_jsonb(u),
        'password_hash', u.password_hash,
        'roles', COALESCE((
            SELECT jsonb_agg(DISTINCT r.nombre_rol)
            FROM usuario_roles ur
            JOIN roles r ON r.id_rol = ur.id_rol
            WHERE ur.id_usuario = u.id_usuario AND ur.estado = TRUE AND r.estado = TRUE
        ), '[]'::jsonb),
        'permisos', COALESCE((
            SELECT jsonb_agg(DISTINCT p.codigo)
            FROM usuario_roles ur
            JOIN roles r ON r.id_rol = ur.id_rol
            JOIN rol_permisos rp ON rp.id_rol = r.id_rol
            JOIN permisos p ON p.id_permiso = rp.id_permiso
            WHERE ur.id_usuario = u.id_usuario
              AND ur.estado = TRUE
              AND r.estado = TRUE
              AND rp.estado = TRUE
              AND p.estado = TRUE
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM usuarios u
    WHERE lower(u.correo) = lower(p_correo)
      AND u.estado_usuario = 'activo';

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_auth_registrar_evento_acceso(
    p_id_usuario BIGINT,
    p_accion VARCHAR,
    p_ip_origen VARCHAR DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    INSERT INTO auditoria_accesos(id_usuario, accion, ip_origen, user_agent)
    VALUES (p_id_usuario, p_accion, p_ip_origen, p_user_agent)
    RETURNING to_jsonb(auditoria_accesos.*) INTO v_result;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_auth_actualizar_ultimo_acceso(
    p_id_usuario BIGINT,
    p_ip_origen VARCHAR DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE usuarios
    SET ultimo_acceso = CURRENT_TIMESTAMP
    WHERE id_usuario = p_id_usuario
    RETURNING to_jsonb(usuarios.*) INTO v_result;

    PERFORM sp_auth_registrar_evento_acceso(p_id_usuario, 'login_exitoso', p_ip_origen, p_user_agent);
    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_usuario_contexto(p_id_usuario BIGINT)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'usuario', to_jsonb(u) - 'password_hash',
        'roles', COALESCE((
            SELECT jsonb_agg(DISTINCT r.nombre_rol)
            FROM usuario_roles ur
            JOIN roles r ON r.id_rol = ur.id_rol
            WHERE ur.id_usuario = u.id_usuario AND ur.estado = TRUE AND r.estado = TRUE
        ), '[]'::jsonb),
        'permisos', COALESCE((
            SELECT jsonb_agg(DISTINCT p.codigo)
            FROM usuario_roles ur
            JOIN roles r ON r.id_rol = ur.id_rol
            JOIN rol_permisos rp ON rp.id_rol = r.id_rol
            JOIN permisos p ON p.id_permiso = rp.id_permiso
            WHERE ur.id_usuario = u.id_usuario
              AND ur.estado = TRUE AND r.estado = TRUE AND rp.estado = TRUE AND p.estado = TRUE
        ), '[]'::jsonb),
        'docente', COALESCE((SELECT to_jsonb(d) FROM docentes d WHERE d.id_usuario = u.id_usuario), 'null'::jsonb),
        'estudiante', COALESCE((SELECT to_jsonb(e) FROM estudiantes e WHERE e.id_usuario = u.id_usuario), 'null'::jsonb)
    )
    INTO v_result
    FROM usuarios u
    WHERE u.id_usuario = p_id_usuario;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_get_tutorias_por_docente(p_id_docente BIGINT)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q)), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            t.id_tutoria,
            t.fecha_tutoria,
            t.estado_tutoria,
            t.motivo_cancelacion,
            hd.dia_semana,
            hd.hora_inicio,
            hd.hora_fin,
            hd.modalidad,
            st.id_solicitud,
            st.tema,
            st.descripcion,
            st.prioridad,
            a.nombre AS asignatura,
            p.nombre AS paralelo,
            u.nombres AS estudiante_nombres,
            u.apellidos AS estudiante_apellidos
        FROM tutorias t
        JOIN horarios_docente hd ON hd.id_horario = t.id_horario
        JOIN solicitudes_tutoria st ON st.id_solicitud = t.id_solicitud
        JOIN estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN estudiantes e ON e.id_estudiante = ep.id_estudiante
        JOIN usuarios u ON u.id_usuario = e.id_usuario
        JOIN paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN asignaturas a ON a.id_asignatura = p.id_asignatura
        WHERE hd.id_docente = p_id_docente
        ORDER BY t.fecha_tutoria DESC, hd.hora_inicio DESC
    ) q;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_get_tutorias_por_estudiante(p_id_estudiante BIGINT)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q)), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            t.id_tutoria,
            t.fecha_tutoria,
            t.estado_tutoria,
            t.motivo_cancelacion,
            hd.dia_semana,
            hd.hora_inicio,
            hd.hora_fin,
            hd.modalidad,
            st.id_solicitud,
            st.tema,
            st.descripcion,
            st.prioridad,
            a.nombre AS asignatura,
            p.nombre AS paralelo,
            ud.nombres AS docente_nombres,
            ud.apellidos AS docente_apellidos
        FROM tutorias t
        JOIN horarios_docente hd ON hd.id_horario = t.id_horario
        JOIN docentes d ON d.id_docente = hd.id_docente
        JOIN usuarios ud ON ud.id_usuario = d.id_usuario
        JOIN solicitudes_tutoria st ON st.id_solicitud = t.id_solicitud
        JOIN estudiante_paralelos ep ON ep.id_estudiante_paralelo = st.id_estudiante_paralelo
        JOIN paralelos p ON p.id_paralelo = ep.id_paralelo
        JOIN asignaturas a ON a.id_asignatura = p.id_asignatura
        WHERE ep.id_estudiante = p_id_estudiante
        ORDER BY t.fecha_tutoria DESC, hd.hora_inicio DESC
    ) q;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_get_horarios_disponibles_por_asignatura(
    p_id_asignatura BIGINT,
    p_id_periodo BIGINT
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(q)), '[]'::jsonb)
    INTO v_result
    FROM (
        SELECT
            hd.id_horario,
            hd.id_docente,
            u.nombres AS docente_nombres,
            u.apellidos AS docente_apellidos,
            hd.dia_semana,
            hd.hora_inicio,
            hd.hora_fin,
            hd.modalidad
        FROM horarios_docente hd
        JOIN docentes d ON d.id_docente = hd.id_docente
        JOIN usuarios u ON u.id_usuario = d.id_usuario
        JOIN docente_asignaturas da ON da.id_docente = d.id_docente
        WHERE da.id_asignatura = p_id_asignatura
          AND da.id_periodo = p_id_periodo
          AND da.estado = TRUE
          AND hd.id_periodo = p_id_periodo
          AND hd.estado = TRUE
          AND d.estado = TRUE
        ORDER BY hd.dia_semana, hd.hora_inicio
    ) q;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_ia_buscar_conocimiento(p_texto TEXT, p_limit INTEGER DEFAULT 5)
RETURNS JSONB AS $$
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
            GREATEST(
                similarity(unaccent(lower(bc.pregunta_clave)), unaccent(lower(p_texto))),
                similarity(unaccent(lower(COALESCE(bc.respuesta, ''))), unaccent(lower(p_texto))),
                COALESCE(MAX(similarity(unaccent(lower(k.palabra_clave)), unaccent(lower(p_texto)))) OVER (PARTITION BY bc.id_conocimiento), 0)
            ) AS score
        FROM base_conocimiento_ia bc
        LEFT JOIN conocimiento_palabras_clave_ia k ON k.id_conocimiento = bc.id_conocimiento
        WHERE bc.estado = TRUE
          AND (
                unaccent(lower(bc.pregunta_clave)) % unaccent(lower(p_texto))
             OR unaccent(lower(COALESCE(bc.respuesta, ''))) % unaccent(lower(p_texto))
             OR unaccent(lower(COALESCE(k.palabra_clave, ''))) % unaccent(lower(p_texto))
             OR unaccent(lower(bc.pregunta_clave)) LIKE '%' || unaccent(lower(p_texto)) || '%'
             OR unaccent(lower(COALESCE(k.palabra_clave, ''))) LIKE '%' || unaccent(lower(p_texto)) || '%'
          )
        ORDER BY score DESC, bc.id_conocimiento
        LIMIT GREATEST(p_limit, 1)
    ) q;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_get_notificaciones_usuario(
    p_id_usuario BIGINT,
    p_solo_no_leidas BOOLEAN DEFAULT FALSE
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(n) ORDER BY n.fecha_creacion DESC), '[]'::jsonb)
    INTO v_result
    FROM notificaciones n
    WHERE n.id_usuario = p_id_usuario
      AND (p_solo_no_leidas = FALSE OR n.leida = FALSE);

    RETURN v_result;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sp_marcar_notificacion_leida(p_id_notificacion BIGINT)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    UPDATE notificaciones
    SET leida = TRUE,
        fecha_lectura = CURRENT_TIMESTAMP
    WHERE id_notificacion = p_id_notificacion
    RETURNING to_jsonb(notificaciones.*) INTO v_result;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

