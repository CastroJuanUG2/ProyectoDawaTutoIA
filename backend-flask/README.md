# Backend Flask - Proyecto DAWA Tutorías IA

## Descripción

Este backend funciona como **API Gateway** del proyecto:

**Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA**

El frontend no debe consumir directamente los microservicios internos. Debe consumir únicamente este backend mediante:

```txt
http://localhost:3012/api/v1
```

---

## Rol del backend

El backend `backend-flask` cumple las siguientes funciones:

- Recibir peticiones del frontend.
- Validar autenticación mediante JWT.
- Gestionar roles y permisos.
- Exponer endpoints REST bajo `/api/v1`.
- Conectarse con PostgreSQL.
- Consumir funciones almacenadas del esquema `dawa`.
- Devolver respuestas JSON estándar con `success`, `message`, `service`, `trace_id`, `timestamp` y `data`.

---

## Tecnologías usadas

```txt
Python
Flask
Flask-Cors
PyJWT
psycopg
python-dotenv
PostgreSQL 17
Docker
Docker Compose
```

---

## Puertos

### Backend Flask

```txt
Puerto externo Docker: 3012
Puerto interno Flask: 3013
```

Por eso se consume desde navegador, Thunder Client o frontend así:

```txt
http://localhost:3012/api/v1
```

### PostgreSQL

```txt
Puerto externo Docker: 5435
Puerto interno PostgreSQL: 5432
```

Desde la PC local:

```txt
localhost:5435
```

Desde Docker, el backend usa:

```txt
postgres-db:5432
```

---

## Estructura principal

La estructura principal del backend es la siguiente:

```txt
backend-flask/
│
├── app/
│   ├── db/
│   │   ├── __init__.py
│   │   └── postgres.py
│   │
│   ├── routes/
│   │   ├── academic_routes.py
│   │   ├── auth_routes.py
│   │   ├── health_routes.py
│   │   ├── ia_routes.py
│   │   ├── notification_routes.py
│   │   └── tutoring_routes.py
│   │
│   ├── utils/
│   │   ├── auth_guard.py
│   │   ├── jwt_utils.py
│   │   ├── responses.py
│   │   └── trace.py
│   │
│   ├── __init__.py
│   └── config.py
│
├── tools/
│   └── generate_demo_seed.py
│
├── app.py
├── Dockerfile
├── .dockerignore
├── .env
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Variables de entorno principales

En desarrollo local, el archivo `.env` usa:

```env
FLASK_ENV=development
FLASK_DEBUG=True

APP_HOST=0.0.0.0
APP_PORT=3013

API_PREFIX=/api/v1
SERVICE_NAME=backend-flask

DB_HOST=localhost
DB_PORT=5435
DB_NAME=dawa_tutorias_ia_db
DB_USER=postgres
DB_PASSWORD=postgres
DB_SCHEMA=dawa

JWT_SECRET_KEY=dev_secret_key_dawa_tutorias_ia
JWT_ALGORITHM=HS256
JWT_EXPIRES_MINUTES=120
```

En Docker Compose, el backend usa:

```env
DB_HOST=postgres-db
DB_PORT=5432
```

---

## Ejecución local sin Docker

Ubicarse en la carpeta del backend:

```powershell
cd C:\Users\usuario\Desktop\ProyectoDawaTutoIA\backend-flask
```

Activar entorno virtual:

```powershell
.venv\Scripts\activate
```

Instalar dependencias:

```powershell
pip install -r requirements.txt
```

Levantar Flask:

```powershell
python app.py
```

En modo local directo, Flask queda en:

```txt
http://localhost:3013/api/v1
```

---

## Ejecución con Docker

Ubicarse en la raíz del proyecto:

```powershell
cd C:\Users\usuario\Desktop\ProyectoDawaTutoIA
```

Levantar PostgreSQL:

```powershell
docker compose up -d postgres-db
```

Construir y levantar backend Flask:

```powershell
docker compose up -d --build backend-flask
```

Verificar contenedores:

```powershell
docker compose ps
```

Ver logs del backend:

```powershell
docker compose logs -f backend-flask
```

Ver logs de PostgreSQL:

```powershell
docker compose logs -f postgres-db
```

Detener contenedores:

```powershell
docker compose down
```

Detener y eliminar volumen de base de datos:

```powershell
docker compose down -v
```

> Usar `down -v` solo si se desea borrar completamente la base de datos cargada.

---

## Comandos útiles de PostgreSQL en Docker

Entrar a PostgreSQL:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db
```

Ver tablas del esquema `dawa`:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -c "\dt dawa.*"
```

Ver usuarios:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -c "SELECT id_usuario, nombres, apellidos, correo, estado_usuario FROM dawa.usuarios;"
```

Ver docentes:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -c "SELECT d.id_docente, u.nombres, u.apellidos, u.correo, d.especialidad FROM dawa.docentes d JOIN dawa.usuarios u ON u.id_usuario = d.id_usuario;"
```

Ver horarios docentes:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -c "SELECT id_horario, id_docente, id_periodo, dia_semana, hora_inicio, hora_fin, modalidad, estado FROM dawa.horarios_docente;"
```

Ver tutorías:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -c "SELECT id_tutoria, id_solicitud, id_horario, fecha_tutoria, estado_tutoria FROM dawa.tutorias;"
```

Ver bitácoras:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -c "SELECT id_bitacora, id_tutoria, registrado_por, observaciones, recomendaciones, requiere_seguimiento, fecha_registro FROM dawa.bitacoras_tutoria;"
```

---

## Scripts SQL del proyecto

Los scripts SQL están en:

```txt
database/scripts
```

Orden principal usado:

```txt
00_create_database.sql
ALL_IN_ONE_AFTER_DATABASE.sql
08_seed_demo_users.sql
09_frontend_domain_functions.sql
10_frontend_tutoring_functions.sql
11_frontend_notification_functions.sql
12_frontend_ia_functions.sql
```

Ejecutar un script desde Docker:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -f /scripts/NOMBRE_SCRIPT.sql
```

Ejemplo:

```powershell
docker compose exec postgres-db psql -U postgres -d dawa_tutorias_ia_db -f /scripts/12_frontend_ia_functions.sql
```

---

## Endpoints de prueba rápida

### Health

```http
GET http://localhost:3012/api/v1/health
```

### Health DB

```http
GET http://localhost:3012/api/v1/health/db
```

### Login

```http
POST http://localhost:3012/api/v1/auth/login
```

Body:

```json
{
  "correo": "admin@ug.edu.ec",
  "password": "Admin123"
}
```

### Auth me

```http
GET http://localhost:3012/api/v1/auth/me
```

Header:

```txt
Authorization: Bearer TOKEN
```

---

## Usuarios demo

```txt
ADMIN
correo: admin@ug.edu.ec
password: Admin123

DOCENTE
correo: docente@ug.edu.ec
password: Docente123

ESTUDIANTE
correo: estudiante@ug.edu.ec
password: Estudiante123
```

---

## Formato de respuesta estándar

Respuesta correcta:

```json
{
  "success": true,
  "message": "Mensaje de respuesta",
  "service": "backend-flask",
  "trace_id": "uuid",
  "timestamp": "2026-07-10T00:00:00+00:00",
  "data": {}
}
```

Respuesta de error:

```json
{
  "success": false,
  "message": "Error CODIGO_ERROR",
  "service": "backend-flask",
  "trace_id": "uuid",
  "timestamp": "2026-07-10T00:00:00+00:00",
  "data": null,
  "error": {
    "code": "CODIGO_ERROR"
  }
}
```

---

## Seguridad

Reglas aplicadas:

- No devolver `password`.
- No devolver `password_hash`.
- Enviar JWT como Bearer Token.
- Usar códigos de error constantes.
- Incluir `trace_id` en cada respuesta.
- Incluir `service`.
- Mantener fechas en formato ISO 8601.
- No exponer detalles internos de errores de base de datos al frontend.

---

## Endpoints completos

La documentación completa de endpoints para frontend está en:

```txt
docs/API_GATEWAY_ENDPOINTS.md
```

---

## Troubleshooting

### El backend no responde por `3012`

Verificar contenedores:

```powershell
docker compose ps
```

Ver logs:

```powershell
docker compose logs -f backend-flask
```

---

### El backend responde por `3013`, pero no por `3012`

Eso significa que probablemente se está ejecutando Flask local, no Docker.

Docker debe exponer:

```yaml
ports:
  - "3012:3013"
```

---

### Error de conexión a PostgreSQL desde Docker

Verificar que en Docker Compose el backend tenga:

```env
DB_HOST=postgres-db
DB_PORT=5432
```

No debe usar:

```env
DB_HOST=localhost
DB_PORT=5435
```

dentro del contenedor.

---

### Error `ROUTE_NOT_FOUND`

Revisar:

- Que la URL tenga `/api/v1`.
- Que el método HTTP sea correcto.
- Que no se esté usando un parámetro literal como `ID_MENSAJE_AGENTE`.
- Que la ruta esté registrada en `app/__init__.py`.

---

### Error `AUTH_TOKEN_REQUIRED`

Falta enviar:

```txt
Authorization: Bearer TOKEN
```

---

### Error `AUTH_FORBIDDEN`

El usuario autenticado no tiene el rol necesario para ese endpoint.

---

## Estado actual

El backend ya tiene funcionando los módulos:

```txt
Auth
Académico
Tutorías
Notificaciones
Agente IA
Health
```

Y está listo para ser consumido desde el frontend mediante:

```env
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:3012/api/v1
```