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
