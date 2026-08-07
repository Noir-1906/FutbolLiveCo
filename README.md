# FutbolLiveCo

Aplicación web Jakarta EE para seguir el fútbol en tiempo real: noticias, partidos en vivo, programados y highlights.

## Requisitos

- Java 17+
- Maven 3.8+
- MySQL 8.0+ / 9.x
- Tomcat 10.1+ (Jakarta EE 10, namespace `jakarta.*`)

## Configuración inicial

1. **Configurar credenciales:**
   ```bash
   cp src/main/resources/config.properties.example src/main/resources/config.properties
   # Editar config.properties con tus credenciales reales
   ```

2. **Crear la base de datos:**
   ```bash
   mysql -u root -p < schema.sql
   ```

3. **Compilar y desplegar:**
   ```bash
   mvn clean package
   cp target/futbolliveco.war $TOMCAT_HOME/webapps/
   ```

## APIs externas requeridas

| API | Para qué | Dónde obtener clave |
|-----|----------|---------------------|
| API-Football | Partidos en vivo | https://www.api-football.com/ |
| NewsAPI | Noticias de fútbol | https://newsapi.org/ |
| Football-data.org | Partidos programados | https://www.football-data.org/ |
| YouTube Data API v3 | Highlights | https://console.cloud.google.com/ |

## CORS

Los servlets de API solo permiten peticiones desde:
- `http://localhost:8080` (desarrollo local)
- `https://futbolliveco.co` (producción)

Si usas otro dominio, editar `ORIGENES_PERMITIDOS` en `LiveServlet.java` y `NoticiaServlet.java`.

## Fotos de perfil

Las fotos se guardan en disco (no en la base de datos).
Por defecto: `~/futbolliveco-fotos/`
Configurable en `web.xml` con el parámetro `fotos.dir`.

## Tests

```bash
mvn test
```

## Seguridad implementada

- Protección CSRF en todos los formularios (Synchronizer Token)
- Rate limiting en login (10 intentos / 15 min por IP)
- Contraseñas hasheadas con BCrypt
- Sesión regenerada tras login (anti session fixation)
- Cookie HttpOnly
- CORS con lista blanca de orígenes
- Pool de conexiones HikariCP con health check
- Fotos de perfil en disco (no Base64 en BD)
- Credenciales fuera del repositorio (config.properties en .gitignore)
- PreparedStatements en todo el DAO (anti SQL injection)
