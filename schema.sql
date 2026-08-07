-- ============================================================
-- FutbolLiveCo - Script de creación de base de datos
-- ============================================================
-- Ejecutar: mysql -u root -p < schema.sql

CREATE DATABASE IF NOT EXISTS futbolliveco
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE futbolliveco;

CREATE TABLE IF NOT EXISTS usuarios (
    id          INT          NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(100) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    password    VARCHAR(60)  NOT NULL,        -- hash BCrypt (siempre 60 chars)
    foto_ruta   VARCHAR(255) DEFAULT NULL,    -- ruta relativa, ej: /fotos/42.jpg
    creado_en   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuarios      PRIMARY KEY (id),
    CONSTRAINT uq_usuarios_email UNIQUE      (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índice para búsquedas frecuentes por email (login)
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
