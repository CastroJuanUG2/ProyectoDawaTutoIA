# Scripts SQL - Proyecto DAWA Tutorías Académicas con Agente de IA

## Entorno objetivo

- PostgreSQL 17
- pgAdmin 9.11
- Backend: Python + Flask
- Acceso a datos: funciones almacenadas y procedimientos lógicos en PostgreSQL. El backend no debe integrar SQL directo para CRUD.

## Orden de ejecución recomendado

Ejecutar primero `00_create_database.sql` desde una conexión general al servidor PostgreSQL.
Luego conectarse a la base `dawa_tutorias_ia_db` y ejecutar en este orden:

1. `01_schema_extensions.sql`
2. `02_tables.sql`
3. `03_indexes_triggers.sql`
4. `04_crud_engine.sql`
5. `05_crud_wrappers.sql`
6. `06_domain_functions.sql`
7. `07_seed_data.sql`

## Enfoque de integración con Flask

El backend debe llamar funciones como:

```sql
SELECT dawa.sp_create_usuarios('{"nombres":"Dean","apellidos":"Leon","correo":"dean@test.com","password_hash":"hash"}'::jsonb);
SELECT dawa.sp_get_usuarios(1);
SELECT dawa.sp_list_usuarios(100, 0);
SELECT dawa.sp_update_usuarios(1, '{"estado_usuario":"activo"}'::jsonb);
SELECT dawa.sp_delete_usuarios(1, false);
```

También se incluyen funciones de dominio para login, contexto de usuario, tutorías e IA:

```sql
SELECT dawa.sp_auth_login_lookup('correo@dominio.com');
SELECT dawa.sp_get_usuario_contexto(1);
SELECT dawa.sp_get_tutorias_por_docente(1);
SELECT dawa.sp_get_tutorias_por_estudiante(1);
SELECT dawa.sp_ia_buscar_conocimiento('horario de tutoría');
SELECT dawa.sp_get_notificaciones_usuario(1, true);
```

## Observaciones importantes

- La tabla `paralelos` no tiene `id_docente_titular` ni `cupo_maximo`, de acuerdo con el ajuste aprobado.
- `solicitudes_tutoria` usa `id_estudiante_paralelo` para mantener el modelo normalizado.
- `tutorias` usa `id_horario`; no repite docente, hora de inicio, hora de fin ni modalidad.
- `archivos_adjuntos` fue reemplazada por `archivos` y tablas puente específicas.
- Las operaciones CRUD están expuestas por funciones específicas por tabla, pero internamente usan un motor JSONB validado por una lista permitida.

## Seguridad recomendada para producción

- Crear un usuario de base de datos específico para Flask.
- Otorgar permiso de ejecución únicamente sobre funciones del esquema `dawa`.
- Evitar otorgar permisos directos de INSERT, UPDATE o DELETE sobre tablas al usuario de aplicación.
- Generar `password_hash` desde Flask usando una librería segura como Werkzeug, bcrypt o Argon2.
