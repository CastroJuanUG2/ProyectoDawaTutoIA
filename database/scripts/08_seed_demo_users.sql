
/*
 Seed complementario para pruebas de integración DAWA.
 Crea usuarios demo, perfiles docente/estudiante, asignaciones y horarios.
*/

SET search_path TO dawa, public;

/* ============================================================
   USUARIOS DEMO
   ============================================================ */

INSERT INTO dawa.usuarios(nombres, apellidos, correo, password_hash, estado_usuario)
VALUES
('Dean', 'Leon', 'admin@ug.edu.ec', 'scrypt:32768:8:1$M0mCibFxWWfnpZaC$4746bd6e974fdec5ad7515a17f7952972357f107858d53c6ea13525933d86338322b5d176b0f484dac00433fbfb9ea07867f9bf5d66e7474340d03020acc50e1', 'activo'),
('Juan', 'Docente', 'docente@ug.edu.ec', 'scrypt:32768:8:1$QFVdXAftVbaUiLoC$5e432f8e0e1219ab330ffeff0fc295baca7af2dba773cc43619fe18b946eae29193e53d168a570d85eb14e09472d4954b15ed806b36bbbf77a7152acda3bd003', 'activo'),
('Estudiante', 'Demo', 'estudiante@ug.edu.ec', 'scrypt:32768:8:1$QaY8drYG7I9uoXM9$fb9a2f20f4741ff49e41f0e69a8d3373b92b37d0c75da87173056f6566c9090ab4a40d221b71ae2668a24911ea508bafdcf1981f733cb50c3d821e28d1abc08d', 'activo')
ON CONFLICT (correo) DO UPDATE
SET nombres = EXCLUDED.nombres,
    apellidos = EXCLUDED.apellidos,
    password_hash = EXCLUDED.password_hash,
    estado_usuario = EXCLUDED.estado_usuario,
    actualizado_en = CURRENT_TIMESTAMP;

/* ============================================================
   ASIGNACIÓN DE ROLES
   ============================================================ */

INSERT INTO dawa.usuario_roles(id_usuario, id_rol, estado)
SELECT u.id_usuario, r.id_rol, TRUE
FROM dawa.usuarios u
JOIN dawa.roles r ON r.nombre_rol = 'ADMIN'
WHERE u.correo = 'admin@ug.edu.ec'
ON CONFLICT (id_usuario, id_rol) DO UPDATE
SET estado = TRUE;

INSERT INTO dawa.usuario_roles(id_usuario, id_rol, estado)
SELECT u.id_usuario, r.id_rol, TRUE
FROM dawa.usuarios u
JOIN dawa.roles r ON r.nombre_rol = 'DOCENTE'
WHERE u.correo = 'docente@ug.edu.ec'
ON CONFLICT (id_usuario, id_rol) DO UPDATE
SET estado = TRUE;

INSERT INTO dawa.usuario_roles(id_usuario, id_rol, estado)
SELECT u.id_usuario, r.id_rol, TRUE
FROM dawa.usuarios u
JOIN dawa.roles r ON r.nombre_rol = 'ESTUDIANTE'
WHERE u.correo = 'estudiante@ug.edu.ec'
ON CONFLICT (id_usuario, id_rol) DO UPDATE
SET estado = TRUE;

/* ============================================================
   PERFIL DOCENTE
   ============================================================ */

INSERT INTO dawa.docentes(id_usuario, titulo, especialidad, telefono, estado)
SELECT u.id_usuario, 'Ing.', 'Desarrollo Web', '0999999999', TRUE
FROM dawa.usuarios u
WHERE u.correo = 'docente@ug.edu.ec'
ON CONFLICT (id_usuario) DO UPDATE
SET titulo = EXCLUDED.titulo,
    especialidad = EXCLUDED.especialidad,
    telefono = EXCLUDED.telefono,
    estado = TRUE,
    actualizado_en = CURRENT_TIMESTAMP;

/* ============================================================
   PERFIL ESTUDIANTE
   ============================================================ */

INSERT INTO dawa.estudiantes(id_usuario, id_carrera, matricula, nivel_actual, estado)
SELECT u.id_usuario, c.id_carrera, 'EST-0001', 6, TRUE
FROM dawa.usuarios u
JOIN dawa.carreras c ON c.codigo = 'SOF'
WHERE u.correo = 'estudiante@ug.edu.ec'
ON CONFLICT (id_usuario) DO UPDATE
SET id_carrera = EXCLUDED.id_carrera,
    matricula = EXCLUDED.matricula,
    nivel_actual = EXCLUDED.nivel_actual,
    estado = TRUE,
    actualizado_en = CURRENT_TIMESTAMP;

/* ============================================================
   DOCENTE - ASIGNATURAS
   ============================================================ */

INSERT INTO dawa.docente_asignaturas(id_docente, id_asignatura, id_periodo, estado)
SELECT d.id_docente, a.id_asignatura, p.id_periodo, TRUE
FROM dawa.docentes d
JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
JOIN dawa.asignaturas a ON a.codigo IN ('DAWA', 'BDA', 'BI')
JOIN dawa.periodos_academicos p ON p.nombre = '2026-2027 CI'
WHERE u.correo = 'docente@ug.edu.ec'
ON CONFLICT (id_docente, id_asignatura, id_periodo) DO UPDATE
SET estado = TRUE;

/* ============================================================
   ESTUDIANTE - PARALELOS
   ============================================================ */

INSERT INTO dawa.estudiante_paralelos(id_estudiante, id_paralelo, estado_inscripcion)
SELECT e.id_estudiante, pa.id_paralelo, 'activo'
FROM dawa.estudiantes e
JOIN dawa.usuarios u ON u.id_usuario = e.id_usuario
JOIN dawa.paralelos pa ON pa.estado = TRUE
WHERE u.correo = 'estudiante@ug.edu.ec'
ON CONFLICT (id_estudiante, id_paralelo) DO UPDATE
SET estado_inscripcion = 'activo';

/* ============================================================
   HORARIOS DOCENTE
   ============================================================ */

INSERT INTO dawa.horarios_docente(id_docente, id_periodo, dia_semana, hora_inicio, hora_fin, modalidad, estado)
SELECT d.id_docente, p.id_periodo, 'lunes', '09:00', '11:00', 'virtual', TRUE
FROM dawa.docentes d
JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
JOIN dawa.periodos_academicos p ON p.nombre = '2026-2027 CI'
WHERE u.correo = 'docente@ug.edu.ec'
ON CONFLICT (id_docente, id_periodo, dia_semana, hora_inicio, hora_fin) DO UPDATE
SET modalidad = EXCLUDED.modalidad,
    estado = TRUE;

INSERT INTO dawa.horarios_docente(id_docente, id_periodo, dia_semana, hora_inicio, hora_fin, modalidad, estado)
SELECT d.id_docente, p.id_periodo, 'miercoles', '14:00', '16:00', 'presencial', TRUE
FROM dawa.docentes d
JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
JOIN dawa.periodos_academicos p ON p.nombre = '2026-2027 CI'
WHERE u.correo = 'docente@ug.edu.ec'
ON CONFLICT (id_docente, id_periodo, dia_semana, hora_inicio, hora_fin) DO UPDATE
SET modalidad = EXCLUDED.modalidad,
    estado = TRUE;

INSERT INTO dawa.horarios_docente(id_docente, id_periodo, dia_semana, hora_inicio, hora_fin, modalidad, estado)
SELECT d.id_docente, p.id_periodo, 'viernes', '15:00', '17:00', 'hibrida', TRUE
FROM dawa.docentes d
JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario
JOIN dawa.periodos_academicos p ON p.nombre = '2026-2027 CI'
WHERE u.correo = 'docente@ug.edu.ec'
ON CONFLICT (id_docente, id_periodo, dia_semana, hora_inicio, hora_fin) DO UPDATE
SET modalidad = EXCLUDED.modalidad,
    estado = TRUE;

/* ============================================================
   NOTIFICACIONES DEMO
   ============================================================ */

INSERT INTO dawa.notificaciones(id_usuario, titulo, mensaje, tipo, leida)
SELECT u.id_usuario,
       'Bienvenido al sistema',
       'Tu usuario demo fue creado correctamente para pruebas de integración.',
       'sistema',
       FALSE
FROM dawa.usuarios u
WHERE u.correo IN ('admin@ug.edu.ec', 'docente@ug.edu.ec', 'estudiante@ug.edu.ec');

