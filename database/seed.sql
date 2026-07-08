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
