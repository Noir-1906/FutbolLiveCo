# ============================================================
# Etapa 1: Construcción del WAR con Maven
# ============================================================
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
# Optimización: descarga las dependencias en una capa separada. Docker solo
# repite este paso (lento) si pom.xml cambia; si solo cambias tu código
# (src/), esta capa se reutiliza desde caché y el build es mucho más rápido.
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -o

# ============================================================
# Etapa 2: Imagen final con Tomcat 10 (Jakarta EE 10)
# ============================================================
FROM tomcat:10.1-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/futbolliveco.war /usr/local/tomcat/webapps/ROOT.war

# Railway asigna el puerto dinámicamente mediante la variable PORT.
# Este script ajusta el puerto de Tomcat antes de arrancar.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
