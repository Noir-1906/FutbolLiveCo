#!/bin/sh
set -e

# Railway inyecta la variable PORT; si no existe (ej. pruebas locales), usa 8080
PORT="${PORT:-8080}"

sed -i "s/port=\"8080\"/port=\"${PORT}\"/" /usr/local/tomcat/conf/server.xml

# Optimización: activar compresión GZIP en el Connector HTTP.
# Reduce el peso de HTML/CSS/JS/JSON enviados al navegador (~60-80% menos en texto).
sed -i 's|protocol="HTTP/1.1"|protocol="HTTP/1.1"\n               compression="on"\n               compressionMinSize="1024"\n               compressibleMimeType="text/html,text/xml,text/css,text/javascript,application/javascript,application/json,text/plain"|' /usr/local/tomcat/conf/server.xml

exec catalina.sh run
