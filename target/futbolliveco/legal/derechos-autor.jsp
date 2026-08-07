<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Derechos de Autor - FutbolLiveCo</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/legal.css">
</head>
<body>

<%@ include file="/navbar.jsp" %>

<main class="legal-main">
    <div class="legal-header">
        <h1 class="legal-title">Derechos de Autor</h1>
        <p class="legal-updated">Última actualización: <%= new java.text.SimpleDateFormat("dd 'de' MMMM 'de' yyyy", new java.util.Locale("es","ES")).format(new java.util.Date()) %></p>
    </div>

    <nav class="legal-nav">
        <a href="<%= request.getContextPath() %>/legal/terminos.jsp">Términos y Condiciones</a>
        <a href="<%= request.getContextPath() %>/legal/privacidad.jsp">Privacidad</a>
        <a href="<%= request.getContextPath() %>/legal/derechos-autor.jsp" class="active">Derechos de Autor</a>
        <a href="<%= request.getContextPath() %>/legal/contacto.jsp">Contacto</a>
    </nav>

    <section class="legal-section">
        <h2>1. Titularidad del sitio</h2>
        <p>FutbolLiveCo, incluyendo su diseño, estructura, código fuente propio, logotipos y elementos gráficos originales, es propiedad de sus autores. Todos los derechos sobre el desarrollo propio de esta plataforma pertenecen a su titular, salvo el contenido de terceros detallado a continuación.</p>
    </section>

    <section class="legal-section">
        <h2>2. Contenido de terceros</h2>
        <p>FutbolLiveCo agrega y muestra información deportiva obtenida a través de servicios de terceros, cuyos derechos de autor pertenecen a sus respectivos proveedores. En particular:</p>
        <ul>
            <li><strong>Resultados en vivo y estadísticas de partidos:</strong> proporcionados mediante servicios de datos deportivos de terceros (API-Sports).</li>
            <li><strong>Calendarios y clasificaciones:</strong> proporcionados por Football-Data.org.</li>
            <li><strong>Noticias:</strong> agregadas mediante NewsAPI, mostrando enlaces a las fuentes originales. FutbolLiveCo no reclama autoría sobre el contenido periodístico mostrado; cada noticia enlaza directamente a la publicación original de su respectivo medio.</li>
            <li><strong>Videos y highlights:</strong> mostrados mediante la API de YouTube Data, respetando los derechos de los canales y creadores originales de cada video.</li>
        </ul>
        <p>El uso de estos servicios se realiza conforme a sus respectivos términos de uso para desarrolladores.</p>
    </section>

    <section class="legal-section">
        <h2>3. Marcas y nombres de equipos</h2>
        <p>Los nombres de ligas, equipos, competiciones y jugadores mostrados en la Plataforma son marcas registradas o nombres de sus respectivos titulares (federaciones, clubes y organizaciones deportivas). Su mención en FutbolLiveCo tiene fines exclusivamente informativos y no implica afiliación, patrocinio o respaldo por parte de dichas entidades.</p>
    </section>

    <section class="legal-section">
        <h2>4. Uso del código fuente</h2>
        <p>Cualquier reutilización del código fuente propio del proyecto debe realizarse citando su origen y respetando la licencia bajo la cual se distribuya, si aplica.</p>
    </section>

    <section class="legal-section">
        <h2>5. Notificación de infracción</h2>
        <p>Si usted considera que algún contenido mostrado en FutbolLiveCo infringe sus derechos de autor, puede notificarlo a través del correo indicado en la sección de <a href="<%= request.getContextPath() %>/legal/contacto.jsp">Contacto</a>, y procederemos a revisar y, de ser necesario, retirar dicho contenido.</p>
    </section>

    </main>

<%@ include file="/footer.jsp" %>

</body>
</html>
