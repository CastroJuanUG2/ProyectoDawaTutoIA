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
/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 02_tables.sql
 Propósito: creación del modelo físico normalizado hasta 3FN.
 Base: PostgreSQL 17.
*/

SET search_path TO dawa, public;

/* ============================================================
   1. SEGURIDAD
   ============================================================ */

CREATE TABLE IF NOT EXISTS dawa.usuarios (
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
    CONSTRAINT chk_usuarios_correo_formato CHECK (correo ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')
);
COMMENT ON TABLE dawa.usuarios IS 'Usuarios base del sistema. Contiene credenciales, datos personales mínimos y estado de acceso.';

CREATE TABLE IF NOT EXISTS dawa.roles (
    id_rol       BIGSERIAL PRIMARY KEY,
    nombre_rol   VARCHAR(50) NOT NULL UNIQUE,
    descripcion  TEXT,
    estado       BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE dawa.roles IS 'Catálogo de roles del sistema: ADMIN, COORDINADOR, DOCENTE, ESTUDIANTE.';

CREATE TABLE IF NOT EXISTS dawa.permisos (
    id_permiso   BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(100) NOT NULL UNIQUE,
    descripcion  TEXT,
    estado       BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE dawa.permisos IS 'Catálogo de permisos autorizables por rol.';

CREATE TABLE IF NOT EXISTS dawa.usuario_roles (
    id_usuario_rol BIGSERIAL PRIMARY KEY,
    id_usuario     BIGINT NOT NULL REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_rol         BIGINT NOT NULL REFERENCES dawa.roles(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
    asignado_en    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_usuario_roles UNIQUE (id_usuario, id_rol)
);
COMMENT ON TABLE dawa.usuario_roles IS 'Relación N:M entre usuarios y roles.';

CREATE TABLE IF NOT EXISTS dawa.rol_permisos (
    id_rol_permiso BIGSERIAL PRIMARY KEY,
    id_rol         BIGINT NOT NULL REFERENCES dawa.roles(id_rol) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_permiso     BIGINT NOT NULL REFERENCES dawa.permisos(id_permiso) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_rol_permisos UNIQUE (id_rol, id_permiso)
);
COMMENT ON TABLE dawa.rol_permisos IS 'Relación N:M entre roles y permisos.';

/* ============================================================
   2. ADMINISTRACIÓN ACADÉMICA
   ============================================================ */

CREATE TABLE IF NOT EXISTS dawa.facultades (
    id_facultad    BIGSERIAL PRIMARY KEY,
    nombre         VARCHAR(150) NOT NULL UNIQUE,
    descripcion    TEXT,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);
COMMENT ON TABLE dawa.facultades IS 'Facultades registradas en el sistema.';

CREATE TABLE IF NOT EXISTS dawa.carreras (
    id_carrera     BIGSERIAL PRIMARY KEY,
    id_facultad    BIGINT NOT NULL REFERENCES dawa.facultades(id_facultad) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre         VARCHAR(150) NOT NULL,
    codigo         VARCHAR(30) UNIQUE,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);
COMMENT ON TABLE dawa.carreras IS 'Carreras académicas asociadas a facultades.';

CREATE TABLE IF NOT EXISTS dawa.periodos_academicos (
    id_periodo     BIGSERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL UNIQUE,
    fecha_inicio   DATE NOT NULL,
    fecha_fin      DATE NOT NULL,
    estado_periodo VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_periodos_fechas CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT chk_periodos_estado CHECK (estado_periodo IN ('pendiente', 'activo', 'cerrado'))
);
COMMENT ON TABLE dawa.periodos_academicos IS 'Periodos académicos gestionados por el sistema.';

CREATE TABLE IF NOT EXISTS dawa.asignaturas (
    id_asignatura  BIGSERIAL PRIMARY KEY,
    id_carrera     BIGINT NOT NULL REFERENCES dawa.carreras(id_carrera) ON UPDATE CASCADE ON DELETE RESTRICT,
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
COMMENT ON TABLE dawa.asignaturas IS 'Asignaturas pertenecientes a una carrera.';

CREATE TABLE IF NOT EXISTS dawa.docentes (
    id_docente     BIGSERIAL PRIMARY KEY,
    id_usuario     BIGINT NOT NULL UNIQUE REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    titulo         VARCHAR(100),
    especialidad   VARCHAR(150),
    telefono       VARCHAR(20),
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);
COMMENT ON TABLE dawa.docentes IS 'Perfil académico del usuario docente.';

CREATE TABLE IF NOT EXISTS dawa.estudiantes (
    id_estudiante  BIGSERIAL PRIMARY KEY,
    id_usuario     BIGINT NOT NULL UNIQUE REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_carrera     BIGINT NOT NULL REFERENCES dawa.carreras(id_carrera) ON UPDATE CASCADE ON DELETE RESTRICT,
    matricula      VARCHAR(50) NOT NULL UNIQUE,
    nivel_actual   INTEGER NOT NULL,
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,
    CONSTRAINT chk_estudiantes_nivel CHECK (nivel_actual > 0)
);
COMMENT ON TABLE dawa.estudiantes IS 'Perfil académico del usuario estudiante.';

CREATE TABLE IF NOT EXISTS dawa.paralelos (
    id_paralelo    BIGSERIAL PRIMARY KEY,
    id_asignatura  BIGINT NOT NULL REFERENCES dawa.asignaturas(id_asignatura) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_periodo     BIGINT NOT NULL REFERENCES dawa.periodos_academicos(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    nombre         VARCHAR(50) NOT NULL,
    jornada        VARCHAR(30),
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,
    CONSTRAINT chk_paralelos_jornada CHECK (jornada IS NULL OR jornada IN ('matutina', 'vespertina', 'nocturna', 'intensiva')),
    CONSTRAINT uq_paralelos_asignatura_periodo_nombre UNIQUE (id_asignatura, id_periodo, nombre)
);
COMMENT ON TABLE dawa.paralelos IS 'Grupo académico de una asignatura dentro de un periodo. No gestiona docente titular ni cupos.';

CREATE TABLE IF NOT EXISTS dawa.estudiante_paralelos (
    id_estudiante_paralelo BIGSERIAL PRIMARY KEY,
    id_estudiante          BIGINT NOT NULL REFERENCES dawa.estudiantes(id_estudiante) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_paralelo            BIGINT NOT NULL REFERENCES dawa.paralelos(id_paralelo) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha_asignacion       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_inscripcion     VARCHAR(30) NOT NULL DEFAULT 'activo',
    CONSTRAINT chk_estudiante_paralelos_estado CHECK (estado_inscripcion IN ('activo', 'inactivo', 'retirado', 'finalizado')),
    CONSTRAINT uq_estudiante_paralelos UNIQUE (id_estudiante, id_paralelo)
);
COMMENT ON TABLE dawa.estudiante_paralelos IS 'Asignación académica de estudiantes a paralelos por asignatura y periodo.';

CREATE TABLE IF NOT EXISTS dawa.docente_asignaturas (
    id_docente_asignatura BIGSERIAL PRIMARY KEY,
    id_docente            BIGINT NOT NULL REFERENCES dawa.docentes(id_docente) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_asignatura         BIGINT NOT NULL REFERENCES dawa.asignaturas(id_asignatura) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_periodo            BIGINT NOT NULL REFERENCES dawa.periodos_academicos(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    estado                BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_docente_asignaturas UNIQUE (id_docente, id_asignatura, id_periodo)
);
COMMENT ON TABLE dawa.docente_asignaturas IS 'Asignaturas que un docente puede atender en tutorías dentro de un periodo.';

CREATE TABLE IF NOT EXISTS dawa.horarios_docente (
    id_horario  BIGSERIAL PRIMARY KEY,
    id_docente  BIGINT NOT NULL REFERENCES dawa.docentes(id_docente) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_periodo  BIGINT NOT NULL REFERENCES dawa.periodos_academicos(id_periodo) ON UPDATE CASCADE ON DELETE RESTRICT,
    dia_semana  VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin    TIME NOT NULL,
    modalidad   VARCHAR(30) NOT NULL,
    estado      BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_horarios_dia CHECK (dia_semana IN ('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo')),
    CONSTRAINT chk_horarios_modalidad CHECK (modalidad IN ('presencial', 'virtual', 'hibrida')),
    CONSTRAINT chk_horarios_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT uq_horarios_docente UNIQUE (id_docente, id_periodo, dia_semana, hora_inicio, hora_fin)
);
COMMENT ON TABLE dawa.horarios_docente IS 'Disponibilidad del docente para tutorías.';

/* ============================================================
   3. TUTORÍAS Y SEGUIMIENTO
   ============================================================ */

CREATE TABLE IF NOT EXISTS dawa.solicitudes_tutoria (
    id_solicitud           BIGSERIAL PRIMARY KEY,
    id_estudiante_paralelo BIGINT NOT NULL REFERENCES dawa.estudiante_paralelos(id_estudiante_paralelo) ON UPDATE CASCADE ON DELETE RESTRICT,
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
COMMENT ON TABLE dawa.solicitudes_tutoria IS 'Solicitudes de tutoría originadas desde la relación estudiante-paralelo.';

CREATE TABLE IF NOT EXISTS dawa.tutorias (
    id_tutoria         BIGSERIAL PRIMARY KEY,
    id_solicitud       BIGINT NOT NULL UNIQUE REFERENCES dawa.solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_horario         BIGINT NOT NULL REFERENCES dawa.horarios_docente(id_horario) ON UPDATE CASCADE ON DELETE RESTRICT,
    fecha_tutoria      DATE NOT NULL,
    estado_tutoria     VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    motivo_cancelacion TEXT,
    creado_en          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en     TIMESTAMP,
    CONSTRAINT chk_tutorias_estado CHECK (estado_tutoria IN ('solicitada', 'pendiente', 'confirmada', 'atendida', 'cancelada', 'no_asistida')),
    CONSTRAINT chk_tutorias_cancelacion CHECK ((estado_tutoria <> 'cancelada') OR (motivo_cancelacion IS NOT NULL AND length(trim(motivo_cancelacion)) > 0))
);
COMMENT ON TABLE dawa.tutorias IS 'Tutorías programadas a partir de solicitudes y horarios docentes.';

CREATE TABLE IF NOT EXISTS dawa.asistencias_tutoria (
    id_asistencia      BIGSERIAL PRIMARY KEY,
    id_tutoria         BIGINT NOT NULL UNIQUE REFERENCES dawa.tutorias(id_tutoria) ON UPDATE CASCADE ON DELETE RESTRICT,
    asistio_estudiante BOOLEAN NOT NULL DEFAULT FALSE,
    asistio_docente    BOOLEAN NOT NULL DEFAULT FALSE,
    observacion        TEXT,
    fecha_registro     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE dawa.asistencias_tutoria IS 'Registro único de asistencia por tutoría.';

CREATE TABLE IF NOT EXISTS dawa.bitacoras_tutoria (
    id_bitacora          BIGSERIAL PRIMARY KEY,
    id_tutoria           BIGINT NOT NULL REFERENCES dawa.tutorias(id_tutoria) ON UPDATE CASCADE ON DELETE RESTRICT,
    registrado_por       BIGINT NOT NULL REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    observaciones        TEXT NOT NULL,
    recomendaciones      TEXT,
    acuerdos             TEXT,
    requiere_seguimiento BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE dawa.bitacoras_tutoria IS 'Bitácoras de atención académica registradas por usuarios autorizados.';

CREATE TABLE IF NOT EXISTS dawa.temas_recurrentes (
    id_tema_recurrente BIGSERIAL PRIMARY KEY,
    nombre             VARCHAR(150) NOT NULL UNIQUE,
    descripcion        TEXT,
    estado             BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE dawa.temas_recurrentes IS 'Catálogo de temas recurrentes en tutorías.';

CREATE TABLE IF NOT EXISTS dawa.solicitud_temas (
    id_solicitud_tema  BIGSERIAL PRIMARY KEY,
    id_solicitud       BIGINT NOT NULL REFERENCES dawa.solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    id_tema_recurrente BIGINT NOT NULL REFERENCES dawa.temas_recurrentes(id_tema_recurrente) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_solicitud_temas UNIQUE (id_solicitud, id_tema_recurrente)
);
COMMENT ON TABLE dawa.solicitud_temas IS 'Relación N:M entre solicitudes y temas recurrentes.';

CREATE TABLE IF NOT EXISTS dawa.casos_academicos (
    id_caso           BIGSERIAL PRIMARY KEY,
    id_estudiante     BIGINT NOT NULL REFERENCES dawa.estudiantes(id_estudiante) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_tutoria_origen BIGINT REFERENCES dawa.tutorias(id_tutoria) ON UPDATE CASCADE ON DELETE SET NULL,
    descripcion       TEXT NOT NULL,
    estado_caso       VARCHAR(30) NOT NULL DEFAULT 'abierto',
    fecha_apertura    DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_cierre      DATE,
    CONSTRAINT chk_casos_estado CHECK (estado_caso IN ('abierto', 'en_proceso', 'cerrado')),
    CONSTRAINT chk_casos_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura)
);
COMMENT ON TABLE dawa.casos_academicos IS 'Casos académicos que requieren seguimiento posterior.';

CREATE TABLE IF NOT EXISTS dawa.seguimientos_academicos (
    id_seguimiento     BIGSERIAL PRIMARY KEY,
    id_caso            BIGINT NOT NULL REFERENCES dawa.casos_academicos(id_caso) ON UPDATE CASCADE ON DELETE RESTRICT,
    descripcion        TEXT NOT NULL,
    estado_seguimiento VARCHAR(30) NOT NULL DEFAULT 'en_proceso',
    fecha_registro     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre       DATE,
    CONSTRAINT chk_seguimientos_estado CHECK (estado_seguimiento IN ('abierto', 'en_proceso', 'cerrado'))
);
COMMENT ON TABLE dawa.seguimientos_academicos IS 'Avances o acciones realizadas sobre casos académicos.';

/* ============================================================
   4. AGENTE DE INTELIGENCIA ARTIFICIAL
   ============================================================ */

CREATE TABLE IF NOT EXISTS dawa.documentos_base_ia (
    id_documento   BIGSERIAL PRIMARY KEY,
    titulo         VARCHAR(200) NOT NULL,
    descripcion    TEXT,
    fuente         VARCHAR(200),
    tipo_documento VARCHAR(50),
    estado         BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE dawa.documentos_base_ia IS 'Documentos o fuentes institucionales utilizadas por el agente de IA.';

CREATE TABLE IF NOT EXISTS dawa.base_conocimiento_ia (
    id_conocimiento BIGSERIAL PRIMARY KEY,
    id_documento    BIGINT REFERENCES dawa.documentos_base_ia(id_documento) ON UPDATE CASCADE ON DELETE SET NULL,
    pregunta_clave  VARCHAR(250) NOT NULL,
    respuesta       TEXT NOT NULL,
    categoria       VARCHAR(100),
    estado          BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en  TIMESTAMP
);
COMMENT ON TABLE dawa.base_conocimiento_ia IS 'Preguntas y respuestas controladas para el agente IA.';

CREATE TABLE IF NOT EXISTS dawa.conocimiento_palabras_clave_ia (
    id_palabra_clave BIGSERIAL PRIMARY KEY,
    id_conocimiento  BIGINT NOT NULL REFERENCES dawa.base_conocimiento_ia(id_conocimiento) ON UPDATE CASCADE ON DELETE CASCADE,
    palabra_clave    VARCHAR(100) NOT NULL,
    CONSTRAINT uq_conocimiento_palabra UNIQUE (id_conocimiento, palabra_clave)
);
COMMENT ON TABLE dawa.conocimiento_palabras_clave_ia IS 'Palabras clave normalizadas para búsqueda en base de conocimiento IA.';

CREATE TABLE IF NOT EXISTS dawa.conversaciones_ia (
    id_conversacion      BIGSERIAL PRIMARY KEY,
    id_usuario           BIGINT NOT NULL REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    contexto             VARCHAR(150),
    estado_conversacion  VARCHAR(30) NOT NULL DEFAULT 'abierta',
    fecha_inicio         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre         TIMESTAMP,
    CONSTRAINT chk_conversaciones_estado CHECK (estado_conversacion IN ('abierta', 'cerrada', 'escalada')),
    CONSTRAINT chk_conversaciones_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_inicio)
);
COMMENT ON TABLE dawa.conversaciones_ia IS 'Conversaciones de usuarios con el agente IA.';

CREATE TABLE IF NOT EXISTS dawa.mensajes_ia (
    id_mensaje             BIGSERIAL PRIMARY KEY,
    id_conversacion        BIGINT NOT NULL REFERENCES dawa.conversaciones_ia(id_conversacion) ON UPDATE CASCADE ON DELETE CASCADE,
    remitente              VARCHAR(20) NOT NULL,
    mensaje                TEXT NOT NULL,
    requiere_escalamiento  BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_mensaje          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_mensajes_remitente CHECK (remitente IN ('usuario', 'agente'))
);
COMMENT ON TABLE dawa.mensajes_ia IS 'Mensajes de usuario y agente dentro de una conversación IA.';

CREATE TABLE IF NOT EXISTS dawa.mensaje_fuentes_ia (
    id_mensaje_fuente BIGSERIAL PRIMARY KEY,
    id_mensaje        BIGINT NOT NULL REFERENCES dawa.mensajes_ia(id_mensaje) ON UPDATE CASCADE ON DELETE CASCADE,
    id_conocimiento   BIGINT NOT NULL REFERENCES dawa.base_conocimiento_ia(id_conocimiento) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_mensaje_fuentes UNIQUE (id_mensaje, id_conocimiento)
);
COMMENT ON TABLE dawa.mensaje_fuentes_ia IS 'Fuentes de conocimiento utilizadas para generar una respuesta IA.';

CREATE TABLE IF NOT EXISTS dawa.clasificaciones_ia (
    id_clasificacion       BIGSERIAL PRIMARY KEY,
    id_solicitud           BIGINT NOT NULL REFERENCES dawa.solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    id_asignatura_sugerida BIGINT REFERENCES dawa.asignaturas(id_asignatura) ON UPDATE CASCADE ON DELETE SET NULL,
    id_docente_sugerido    BIGINT REFERENCES dawa.docentes(id_docente) ON UPDATE CASCADE ON DELETE SET NULL,
    categoria_detectada    VARCHAR(100),
    nivel_confianza        NUMERIC(5,2),
    requiere_revision      BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_clasificacion    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_clasificaciones_confianza CHECK (nivel_confianza IS NULL OR (nivel_confianza >= 0 AND nivel_confianza <= 100))
);
COMMENT ON TABLE dawa.clasificaciones_ia IS 'Clasificaciones automáticas de solicitudes generadas por el agente IA.';

CREATE TABLE IF NOT EXISTS dawa.feedback_ia (
    id_feedback    BIGSERIAL PRIMARY KEY,
    id_mensaje     BIGINT NOT NULL REFERENCES dawa.mensajes_ia(id_mensaje) ON UPDATE CASCADE ON DELETE CASCADE,
    id_usuario     BIGINT NOT NULL REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    util           BOOLEAN NOT NULL,
    comentario     TEXT,
    fecha_feedback TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_feedback_mensaje_usuario UNIQUE (id_mensaje, id_usuario)
);
COMMENT ON TABLE dawa.feedback_ia IS 'Evaluación de utilidad de respuestas del agente IA.';

CREATE TABLE IF NOT EXISTS dawa.escalamientos_ia (
    id_escalamiento      BIGSERIAL PRIMARY KEY,
    id_mensaje_origen    BIGINT NOT NULL REFERENCES dawa.mensajes_ia(id_mensaje) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_usuario_destino   BIGINT REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    motivo               TEXT NOT NULL,
    estado_escalamiento  VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    fecha_escalamiento   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion     TIMESTAMP,
    CONSTRAINT chk_escalamientos_estado CHECK (estado_escalamiento IN ('pendiente', 'en_revision', 'resuelto', 'cancelado')),
    CONSTRAINT chk_escalamientos_fechas CHECK (fecha_resolucion IS NULL OR fecha_resolucion >= fecha_escalamiento)
);
COMMENT ON TABLE dawa.escalamientos_ia IS 'Mensajes de IA escalados a revisión humana.';

/* ============================================================
   5. AUDITORÍA, NOTIFICACIONES Y SOPORTE
   ============================================================ */

CREATE TABLE IF NOT EXISTS dawa.auditoria_accesos (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_usuario   BIGINT REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    accion       VARCHAR(100) NOT NULL,
    ip_origen    VARCHAR(50),
    user_agent   TEXT,
    fecha_accion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE dawa.auditoria_accesos IS 'Eventos de autenticación y seguridad de acceso.';

CREATE TABLE IF NOT EXISTS dawa.notificaciones (
    id_notificacion BIGSERIAL PRIMARY KEY,
    id_usuario      BIGINT NOT NULL REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    titulo          VARCHAR(150) NOT NULL,
    mensaje         TEXT NOT NULL,
    tipo            VARCHAR(50),
    leida           BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_lectura   TIMESTAMP,
    CONSTRAINT chk_notificaciones_fechas CHECK (fecha_lectura IS NULL OR fecha_lectura >= fecha_creacion)
);
COMMENT ON TABLE dawa.notificaciones IS 'Notificaciones internas para usuarios.';

CREATE TABLE IF NOT EXISTS dawa.parametros_sistema (
    id_parametro  BIGSERIAL PRIMARY KEY,
    clave         VARCHAR(100) NOT NULL UNIQUE,
    valor         TEXT NOT NULL,
    tipo_dato     VARCHAR(30) NOT NULL,
    descripcion   TEXT,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_parametros_tipo CHECK (tipo_dato IN ('integer', 'boolean', 'text', 'decimal', 'date', 'time'))
);
COMMENT ON TABLE dawa.parametros_sistema IS 'Parámetros configurables del sistema.';

CREATE TABLE IF NOT EXISTS dawa.logs_sistema (
    id_log      BIGSERIAL PRIMARY KEY,
    id_usuario  BIGINT REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    servicio    VARCHAR(100),
    accion      VARCHAR(150),
    descripcion TEXT,
    nivel       VARCHAR(30),
    fecha_log   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_logs_nivel CHECK (nivel IS NULL OR nivel IN ('info', 'warning', 'error', 'critical'))
);
COMMENT ON TABLE dawa.logs_sistema IS 'Logs técnicos y funcionales generados por microservicios.';

CREATE TABLE IF NOT EXISTS dawa.archivos (
    id_archivo      BIGSERIAL PRIMARY KEY,
    nombre_archivo  VARCHAR(200) NOT NULL,
    ruta_archivo    TEXT NOT NULL,
    tipo_archivo    VARCHAR(100),
    subido_por      BIGINT REFERENCES dawa.usuarios(id_usuario) ON UPDATE CASCADE ON DELETE SET NULL,
    fecha_subida    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE dawa.archivos IS 'Metadatos de archivos cargados al sistema.';

CREATE TABLE IF NOT EXISTS dawa.archivo_solicitud (
    id_archivo_solicitud BIGSERIAL PRIMARY KEY,
    id_archivo           BIGINT NOT NULL REFERENCES dawa.archivos(id_archivo) ON UPDATE CASCADE ON DELETE CASCADE,
    id_solicitud         BIGINT NOT NULL REFERENCES dawa.solicitudes_tutoria(id_solicitud) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_archivo_solicitud UNIQUE (id_archivo, id_solicitud)
);
COMMENT ON TABLE dawa.archivo_solicitud IS 'Relación entre archivos y solicitudes de tutoría.';

CREATE TABLE IF NOT EXISTS dawa.archivo_bitacora (
    id_archivo_bitacora BIGSERIAL PRIMARY KEY,
    id_archivo          BIGINT NOT NULL REFERENCES dawa.archivos(id_archivo) ON UPDATE CASCADE ON DELETE CASCADE,
    id_bitacora         BIGINT NOT NULL REFERENCES dawa.bitacoras_tutoria(id_bitacora) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_archivo_bitacora UNIQUE (id_archivo, id_bitacora)
);
COMMENT ON TABLE dawa.archivo_bitacora IS 'Relación entre archivos y bitácoras de tutoría.';

CREATE TABLE IF NOT EXISTS dawa.archivo_documento_ia (
    id_archivo_documento_ia BIGSERIAL PRIMARY KEY,
    id_archivo              BIGINT NOT NULL REFERENCES dawa.archivos(id_archivo) ON UPDATE CASCADE ON DELETE CASCADE,
    id_documento            BIGINT NOT NULL REFERENCES dawa.documentos_base_ia(id_documento) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_archivo_documento_ia UNIQUE (id_archivo, id_documento)
);
COMMENT ON TABLE dawa.archivo_documento_ia IS 'Relación entre archivos y documentos base de IA.';
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
/*
 Proyecto DAWA - Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA
 Archivo: 07_seed_data.sql
 Propósito: datos iniciales mínimos para pruebas de integración.
 Nota: las contraseñas deben ser reemplazadas por hashes generados desde Flask/Werkzeug o librería equivalente.
*/

SET search_path TO dawa, public;

/* ============================================================
   ROLES
   ============================================================ */

INSERT INTO dawa.roles(nombre_rol, descripcion, estado)
VALUES
('ADMIN', 'Administrador general del sistema.', TRUE),
('COORDINADOR', 'Coordinador académico con acceso a supervisión y reportes.', TRUE),
('DOCENTE', 'Docente tutor encargado de atender solicitudes y registrar bitácoras.', TRUE),
('ESTUDIANTE', 'Estudiante que solicita tutorías y consulta el agente IA.', TRUE)
ON CONFLICT (nombre_rol) DO NOTHING;

/* ============================================================
   PERMISOS
   ============================================================ */

INSERT INTO dawa.permisos(codigo, descripcion, estado)
VALUES
('GESTIONAR_USUARIOS', 'Crear, consultar, actualizar y desactivar usuarios.', TRUE),
('GESTIONAR_ROLES', 'Administrar roles y asignaciones.', TRUE),
('GESTIONAR_PERMISOS', 'Administrar permisos por rol.', TRUE),
('GESTIONAR_ACADEMICO', 'Gestionar facultades, carreras, periodos, asignaturas, paralelos, docentes y estudiantes.', TRUE),
('SOLICITAR_TUTORIA', 'Registrar solicitudes de tutoría.', TRUE),
('CONFIRMAR_TUTORIA', 'Confirmar o cancelar tutorías.', TRUE),
('REGISTRAR_ASISTENCIA', 'Registrar asistencia a tutorías.', TRUE),
('REGISTRAR_BITACORA', 'Registrar bitácoras de atención.', TRUE),
('GESTIONAR_SEGUIMIENTO', 'Gestionar casos y seguimientos académicos.', TRUE),
('VER_REPORTES', 'Consultar reportes administrativos.', TRUE),
('USAR_AGENTE_IA', 'Usar el agente IA académico.', TRUE),
('GESTIONAR_BASE_IA', 'Gestionar documentos y base de conocimiento IA.', TRUE),
('VER_AUDITORIA', 'Consultar auditoría y logs del sistema.', TRUE)
ON CONFLICT (codigo) DO NOTHING;

/* ============================================================
   ASIGNACIÓN DE PERMISOS POR ROL
   ============================================================ */

-- ADMIN: todos los permisos.
INSERT INTO dawa.rol_permisos(id_rol, id_permiso, estado)
SELECT r.id_rol, p.id_permiso, TRUE
FROM dawa.roles r
CROSS JOIN dawa.permisos p
WHERE r.nombre_rol = 'ADMIN'
ON CONFLICT (id_rol, id_permiso) DO NOTHING;

-- COORDINADOR: gestión académica, tutorías, seguimiento, reportes, IA y auditoría funcional.
INSERT INTO dawa.rol_permisos(id_rol, id_permiso, estado)
SELECT r.id_rol, p.id_permiso, TRUE
FROM dawa.roles r
JOIN dawa.permisos p ON p.codigo IN (
    'GESTIONAR_ACADEMICO', 'CONFIRMAR_TUTORIA', 'REGISTRAR_ASISTENCIA',
    'REGISTRAR_BITACORA', 'GESTIONAR_SEGUIMIENTO', 'VER_REPORTES',
    'USAR_AGENTE_IA', 'GESTIONAR_BASE_IA', 'VER_AUDITORIA'
)
WHERE r.nombre_rol = 'COORDINADOR'
ON CONFLICT (id_rol, id_permiso) DO NOTHING;

-- DOCENTE: atención de tutorías.
INSERT INTO dawa.rol_permisos(id_rol, id_permiso, estado)
SELECT r.id_rol, p.id_permiso, TRUE
FROM dawa.roles r
JOIN dawa.permisos p ON p.codigo IN (
    'CONFIRMAR_TUTORIA', 'REGISTRAR_ASISTENCIA', 'REGISTRAR_BITACORA',
    'GESTIONAR_SEGUIMIENTO', 'USAR_AGENTE_IA'
)
WHERE r.nombre_rol = 'DOCENTE'
ON CONFLICT (id_rol, id_permiso) DO NOTHING;

-- ESTUDIANTE: solicitud de tutorías y uso del agente IA.
INSERT INTO dawa.rol_permisos(id_rol, id_permiso, estado)
SELECT r.id_rol, p.id_permiso, TRUE
FROM dawa.roles r
JOIN dawa.permisos p ON p.codigo IN ('SOLICITAR_TUTORIA', 'USAR_AGENTE_IA')
WHERE r.nombre_rol = 'ESTUDIANTE'
ON CONFLICT (id_rol, id_permiso) DO NOTHING;

/* ============================================================
   PARÁMETROS DEL SISTEMA
   ============================================================ */

INSERT INTO dawa.parametros_sistema(clave, valor, tipo_dato, descripcion)
VALUES
('tiempo_limite_cancelacion_horas', '24', 'integer', 'Tiempo máximo permitido para cancelar una tutoría antes de su inicio.'),
('max_intentos_login', '5', 'integer', 'Intentos fallidos permitidos antes de bloquear temporalmente una cuenta.'),
('respuesta_ia_modo_seguro', 'true', 'boolean', 'Obliga al agente IA a responder solo con información controlada.'),
('tiempo_respuesta_ia_max_segundos', '10', 'integer', 'Tiempo de respuesta esperado para consultas simples del agente IA.')
ON CONFLICT (clave) DO UPDATE
SET valor = EXCLUDED.valor,
    tipo_dato = EXCLUDED.tipo_dato,
    descripcion = EXCLUDED.descripcion,
    actualizado_en = CURRENT_TIMESTAMP;

/* ============================================================
   DATOS ACADÉMICOS DE EJEMPLO
   ============================================================ */

INSERT INTO dawa.facultades(nombre, descripcion, estado)
VALUES ('Facultad de Ciencias Matemáticas y Físicas', 'Facultad base para pruebas del sistema DAWA.', TRUE)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO dawa.carreras(id_facultad, nombre, codigo, estado)
SELECT f.id_facultad, 'Software', 'SOF', TRUE
FROM dawa.facultades f
WHERE f.nombre = 'Facultad de Ciencias Matemáticas y Físicas'
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO dawa.periodos_academicos(nombre, fecha_inicio, fecha_fin, estado_periodo)
VALUES ('2026-2027 CI', '2026-05-01', '2026-09-30', 'activo')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO dawa.asignaturas(id_carrera, nombre, codigo, nivel, descripcion, estado)
SELECT c.id_carrera, x.nombre, x.codigo, x.nivel, x.descripcion, TRUE
FROM dawa.carreras c
CROSS JOIN (VALUES
    ('Desarrollo de Aplicaciones Web', 'DAWA', 6, 'Asignatura base del proyecto integrador.'),
    ('Base de Datos Avanzada', 'BDA', 6, 'Asignatura orientada al diseño y administración de bases de datos.'),
    ('Inteligencia de Negocios', 'BI', 6, 'Asignatura orientada al análisis de datos y reportes.')
) AS x(nombre, codigo, nivel, descripcion)
WHERE c.codigo = 'SOF'
ON CONFLICT (id_carrera, codigo) DO NOTHING;

INSERT INTO dawa.paralelos(id_asignatura, id_periodo, nombre, jornada, estado)
SELECT a.id_asignatura, p.id_periodo, 'A', 'matutina', TRUE
FROM dawa.asignaturas a
JOIN dawa.periodos_academicos p ON p.nombre = '2026-2027 CI'
WHERE a.codigo IN ('DAWA', 'BDA', 'BI')
ON CONFLICT (id_asignatura, id_periodo, nombre) DO NOTHING;

/* ============================================================
   BASE DE CONOCIMIENTO IA DE EJEMPLO
   ============================================================ */

INSERT INTO dawa.documentos_base_ia(titulo, descripcion, fuente, tipo_documento, estado)
VALUES ('FAQ Tutorías Académicas', 'Preguntas frecuentes para orientar solicitudes de tutoría.', 'Base institucional parametrizada', 'FAQ', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO dawa.base_conocimiento_ia(id_documento, pregunta_clave, respuesta, categoria, estado)
SELECT d.id_documento,
       '¿Cómo solicito una tutoría académica?',
       'Para solicitar una tutoría, el estudiante debe ingresar al módulo de tutorías, seleccionar la asignatura/paralelo asociado, describir el tema de consulta y enviar la solicitud. La respuesta de IA es solo una orientación y no una decisión académica definitiva.',
       'tutorias',
       TRUE
FROM dawa.documentos_base_ia d
WHERE d.titulo = 'FAQ Tutorías Académicas'
ON CONFLICT DO NOTHING;

INSERT INTO dawa.conocimiento_palabras_clave_ia(id_conocimiento, palabra_clave)
SELECT bc.id_conocimiento, x.palabra
FROM dawa.base_conocimiento_ia bc
CROSS JOIN (VALUES ('tutoria'), ('solicitud'), ('horario'), ('docente')) AS x(palabra)
WHERE bc.pregunta_clave = '¿Cómo solicito una tutoría académica?'
ON CONFLICT (id_conocimiento, palabra_clave) DO NOTHING;
