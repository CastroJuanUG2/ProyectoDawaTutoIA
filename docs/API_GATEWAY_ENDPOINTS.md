# API Gateway - Proyecto DAWA Tutorías IA

## Estado actual

Backend API Gateway funcionando en Docker:

```txt
http://localhost:3012/api/v1
```

El frontend debe consumir únicamente esta URL mediante:

```env
NEXT_PUBLIC_API_GATEWAY_URL=http://localhost:3012/api/v1
```

No consumir directamente los servicios internos:

```txt
seguridad
servicio-administrador-acad
servicio-tutoria
servicio-agente-ia
```

---

## Autenticación

Todos los endpoints protegidos deben enviar el token JWT así:

```txt
Authorization: Bearer TOKEN
```

El backend nunca devuelve `password` ni `password_hash`.

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

## Respuesta estándar

Respuesta exitosa:

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

# Endpoints disponibles

## Health

```http
GET /health
GET /health/db
```

---

## Auth

```http
POST /auth/login
GET  /auth/me
POST /auth/logout
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

Respuesta principal:

```json
{
  "success": true,
  "message": "Inicio de sesión correcto",
  "data": {
    "access_token": "jwt",
    "token_type": "Bearer",
    "usuario": {
      "id_usuario": 1,
      "nombres": "Dean",
      "apellidos": "Leon",
      "correo": "admin@ug.edu.ec",
      "roles": ["ADMIN"],
      "permisos": [],
      "activo": true,
      "estado_usuario": "activo"
    }
  }
}
```

---

## Académico

```http
GET  /academico/carreras
GET  /academico/asignaturas
GET  /academico/docentes
GET  /academico/docentes/{id_docente}/horarios
POST /academico/horarios
```

### Crear horario docente

```http
POST http://localhost:3012/api/v1/academico/horarios
```

Body:

```json
{
  "id_docente": 1,
  "dia_semana": "martes",
  "hora_inicio": "08:00",
  "hora_fin": "10:00",
  "modalidad": "virtual"
}
```

---

## Tutorías

```http
POST  /tutorias/solicitudes
GET   /tutorias/estudiantes/{id_estudiante}/solicitudes
GET   /tutorias/docentes/{id_docente}/solicitudes
POST  /tutorias/disponibilidad/validar
POST  /tutorias
PATCH /tutorias/{id_tutoria}/confirmar
PATCH /tutorias/{id_tutoria}/cancelar
POST  /tutorias/{id_tutoria}/bitacora
```

### Crear solicitud de tutoría

```http
POST http://localhost:3012/api/v1/tutorias/solicitudes
```

Body:

```json
{
  "id_estudiante": 1,
  "id_asignatura": 1,
  "tema": "Dudas sobre componentes en Next.js",
  "descripcion": "Necesito apoyo para entender componentes y consumo de API.",
  "prioridad": "media"
}
```

### Validar disponibilidad

```http
POST http://localhost:3012/api/v1/tutorias/disponibilidad/validar
```

Body:

```json
{
  "id_horario": 1,
  "fecha_tutoria": "2026-07-13"
}
```

### Crear tutoría

```http
POST http://localhost:3012/api/v1/tutorias
```

Body:

```json
{
  "id_solicitud": 1,
  "id_horario": 1,
  "fecha_tutoria": "2026-07-13"
}
```

### Registrar bitácora

```http
POST http://localhost:3012/api/v1/tutorias/1/bitacora
```

Body:

```json
{
  "observaciones": "El estudiante presentó dudas sobre componentes, manejo de estado y consumo de API desde el frontend.",
  "recomendaciones": "Revisar useState, useEffect y consumo de endpoints desde el API Gateway.",
  "acuerdos": "El estudiante realizará una prueba consumiendo el endpoint de horarios docentes.",
  "requiere_seguimiento": true
}
```

---

## Notificaciones

```http
GET   /notificaciones
GET   /notificaciones?solo_no_leidas=true
PATCH /notificaciones/{id_notificacion}/leer
```

### Marcar notificación como leída

```http
PATCH http://localhost:3012/api/v1/notificaciones/1/leer
```

---

## IA

```http
POST /ia/chat
POST /ia/clasificar-solicitud
POST /ia/sugerir-docente
GET  /ia/usuarios/{id_usuario}/historial
POST /ia/mensajes/{id_mensaje}/feedback
```

### Chat IA

```http
POST http://localhost:3012/api/v1/ia/chat
```

Body:

```json
{
  "mensaje": "¿Cómo solicito una tutoría académica?",
  "contexto": "tutorias"
}
```

### Feedback IA

```http
POST http://localhost:3012/api/v1/ia/mensajes/2/feedback
```

Body:

```json
{
  "util": true,
  "comentario": "La respuesta fue clara para orientar al estudiante."
}
```

### Sugerir docente

```http
POST http://localhost:3012/api/v1/ia/sugerir-docente
```

Body:

```json
{
  "id_asignatura": 1
}
```

### Clasificar solicitud

```http
POST http://localhost:3012/api/v1/ia/clasificar-solicitud
```

Body:

```json
{
  "id_solicitud": 1
}
```

---

# Códigos de error comunes

```txt
AUTH_MISSING_CREDENTIALS
AUTH_INVALID_CREDENTIALS
AUTH_TOKEN_REQUIRED
AUTH_TOKEN_EXPIRED
AUTH_TOKEN_INVALID
AUTH_FORBIDDEN
AUTH_USER_NOT_FOUND
VALIDATION_REQUIRED_FIELDS
DATABASE_QUERY_ERROR
ROUTE_NOT_FOUND
NOTIFICATION_NOT_FOUND
ACADEMIC_PERIODO_NOT_FOUND
```

---

# Nota para frontend

El frontend debe leer siempre:

```txt
response.success
response.message
response.data
response.error?.code
```

No asumir que `data` siempre tendrá contenido. En errores puede venir como `null`.