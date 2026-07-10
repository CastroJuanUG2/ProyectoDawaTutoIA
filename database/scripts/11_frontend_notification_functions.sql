/*
 Proyecto DAWA - Funciones de dominio para Notificaciones
 Archivo: 11_frontend_notification_functions.sql
*/

SET search_path TO dawa, public;

CREATE OR REPLACE FUNCTION dawa.sp_front_marcar_notificacion_leida(
    p_id_notificacion BIGINT,
    p_id_usuario BIGINT
)
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
      AND id_usuario = p_id_usuario
    RETURNING to_jsonb(notificaciones)
    INTO v_result;

    RETURN COALESCE(v_result, '{}'::jsonb);
END;
$$;