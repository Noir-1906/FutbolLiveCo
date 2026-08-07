package com.mycompany.futbolliveco.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Carga la configuración de la aplicación.
 * Prioridad: 1) Variable de entorno (ej. en Railway/producción)
 *            2) src/main/resources/config.properties (desarrollo local)
 *
 * Esto permite que en Railway las credenciales se configuren como
 * variables de entorno (Settings > Variables) sin tener que subir
 * config.properties (con datos sensibles) al repositorio.
 *
 * Conversión de nombre: "db.url" -> variable de entorno "DB_URL"
 *                        "api.live.key" -> "API_LIVE_KEY"
 */
public class ConfigManager {

    private static final Properties props = new Properties();

    static {
        try (InputStream in = ConfigManager.class
                .getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (in != null) {
                props.load(in);
            }
            // Si no existe config.properties (ej. en Railway, donde el
            // archivo no se sube al repo), no se lanza error: se asume
            // que todo vendrá de variables de entorno.
        } catch (IOException e) {
            throw new RuntimeException("Error leyendo config.properties", e);
        }
    }

    private static String envKey(String key) {
        return key.toUpperCase().replace('.', '_');
    }

    public static String get(String key) {
        String envValue = System.getenv(envKey(key));
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }
        return props.getProperty(key);
    }

    public static String get(String key, String defaultValue) {
        String value = get(key);
        return (value != null) ? value : defaultValue;
    }

    private ConfigManager() {}
}
