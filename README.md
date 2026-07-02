# ProyectoDawaTutoIA

Sistema Web Inteligente de Gestión de Tutorías Académicas con Agente de IA.

## Descripción general

El proyecto consiste en una plataforma web para gestionar tutorías académicas, solicitudes estudiantiles, disponibilidad docente, seguimiento académico y asistencia inicial mediante un agente de Inteligencia Artificial.

El sistema se organiza bajo una arquitectura basada en microservicios, utilizando backend en Python, frontend en Next.js, base de datos PostgreSQL, Docker y control de versiones con GitHub.

## Estructura del proyecto

```txt
ProyectoDawaTutoIA/
│
├── services/
│   ├── security-service/
│   ├── academic-admin-service/
│   ├── tutoring-service/
│   └── ai-agent-service/
│
├── web-app/
│
├── database/
│   ├── init.sql
│   └── seed.sql
│
├── docker-compose.yml
├── .env.example
└── README.md
