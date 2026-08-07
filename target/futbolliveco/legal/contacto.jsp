<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contacto - FutbolLiveCo</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/legal.css">
</head>
<body>

<%@ include file="/navbar.jsp" %>

<main class="legal-main">
    <div class="legal-header">
        <h1 class="legal-title">Contacto</h1>
        <p class="legal-updated">Canales de comunicación oficiales de FutbolLiveCo</p>
    </div>

    <nav class="legal-nav">
        <a href="<%= request.getContextPath() %>/legal/terminos.jsp">Términos y Condiciones</a>
        <a href="<%= request.getContextPath() %>/legal/privacidad.jsp">Privacidad</a>
        <a href="<%= request.getContextPath() %>/legal/derechos-autor.jsp">Derechos de Autor</a>
        <a href="<%= request.getContextPath() %>/legal/contacto.jsp" class="active">Contacto</a>
    </nav>

    <section class="legal-section">
        <h2>¿En qué podemos ayudarte?</h2>
        <p>Si tienes dudas sobre el uso de la Plataforma, deseas ejercer tus derechos sobre tus datos personales, o quieres reportar algún inconveniente relacionado con el contenido mostrado, puedes contactarnos a través de los siguientes medios:</p>
    </section>

    <section class="legal-section">
        <ul class="legal-contact-list">
            <li><strong>Correo electrónico:</strong> contacto@futbolliveco.com</li>
            <li><strong>Repositorio del proyecto:</strong> <a href="https://github.com/Noir-1906/FutbolLiveCo" target="_blank" rel="noopener">github.com/Noir-1906/FutbolLiveCo</a></li>
        </ul>
    </section>
</main>

<%@ include file="/footer.jsp" %>

</body>
</html>
