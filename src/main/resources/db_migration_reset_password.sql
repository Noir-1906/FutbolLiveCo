-- Migración: soporte para recuperación de contraseña por email
-- Ejecutar una sola vez en la base de datos futbolliveco

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS reset_token      VARCHAR(64)  NULL,
    ADD COLUMN IF NOT EXISTS reset_token_exp  DATETIME     NULL;

-- Índice para búsquedas rápidas por token
CREATE INDEX IF NOT EXISTS idx_usuarios_reset_token ON usuarios (reset_token);
