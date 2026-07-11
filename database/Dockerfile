# Dockerfile - PostgreSQL 17 para Proyecto DAWA Tutorías IA
# Ubicación sugerida: database/Dockerfile
# Contexto de build sugerido en docker-compose.yml: ./database
#
# Este Dockerfile prepara un contenedor PostgreSQL 17 que ejecuta automáticamente
# los scripts SQL de setup cuando el volumen de datos está vacío.
#
# Nota importante:
# - PostgreSQL crea la base indicada por POSTGRES_DB automáticamente.
# - Por eso NO se ejecuta 00_create_database.sql dentro de /docker-entrypoint-initdb.d/.
# - Los demás scripts se copian con prefijo numérico para respetar el orden.

FROM postgres:17

LABEL project="Proyecto DAWA Tutorías IA"
LABEL service="postgres-db"
LABEL description="Base de datos PostgreSQL 17 con scripts de inicialización para DAWA Tutorías IA"

ENV POSTGRES_DB=dawa_tutorias_ia_db
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN mkdir -p /scripts

COPY scripts/ /scripts/

COPY scripts/ALL_IN_ONE_AFTER_DATABASE.sql /docker-entrypoint-initdb.d/01_all_in_one_after_database.sql
COPY scripts/08_seed_demo_users.sql /docker-entrypoint-initdb.d/02_seed_demo_users.sql
COPY scripts/09_frontend_domain_functions.sql /docker-entrypoint-initdb.d/03_frontend_domain_functions.sql
COPY scripts/10_frontend_tutoring_functions.sql /docker-entrypoint-initdb.d/04_frontend_tutoring_functions.sql
COPY scripts/11_frontend_notification_functions.sql /docker-entrypoint-initdb.d/05_frontend_notification_functions.sql
COPY scripts/12_frontend_ia_functions.sql /docker-entrypoint-initdb.d/06_frontend_ia_functions.sql

RUN chmod -R 644 /scripts/*.sql /docker-entrypoint-initdb.d/*.sql

EXPOSE 5432