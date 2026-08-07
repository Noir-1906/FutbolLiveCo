<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Términos y Condiciones - FutbolLiveCo</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/legal.css">
</head>
<body>

<%@ include file="/navbar.jsp" %>

<main class="legal-main">
    <div class="legal-header">
        <h1 class="legal-title">Términos y Condiciones</h1>
        <p class="legal-updated">Última actualización: <%= new java.text.SimpleDateFormat("dd 'de' MMMM 'de' yyyy", new java.util.Locale("es","ES")).format(new java.util.Date()) %></p>
    </div>

    <nav class="legal-nav">
        <a href="<%= request.getContextPath() %>/legal/terminos.jsp" class="active">Términos y Condiciones</a>
        <a href="<%= request.getContextPath() %>/legal/privacidad.jsp">Privacidad</a>
        <a href="<%= request.getContextPath() %>/legal/derechos-autor.jsp">Derechos de Autor</a>
        <a href="<%= request.getContextPath() %>/legal/contacto.jsp">Contacto</a>
    </nav>

    <section class="legal-section">
        <h2>1. Aceptación de los términos</h2>
        <p>Al acceder y utilizar FutbolLiveCo ("la Plataforma"), usted acepta quedar vinculado por estos Términos y Condiciones. Si no está de acuerdo con alguno de estos términos, le solicitamos no utilizar la Plataforma.</p>
    </section>

    <section class="legal-section">
        <h2>2. Descripción del servicio</h2>
        <p>FutbolLiveCo es una plataforma informativa que agrega y muestra datos deportivos relacionados con el fútbol, incluyendo resultados en vivo, calendarios de partidos, clasificaciones, estadísticas de jugadores, noticias y contenido audiovisual (highlights), obtenidos a través de servicios de terceros.</p>
    </section>

    <section class="legal-section">
        <h2>3. Registro de cuenta</h2>
        <p>Para acceder a determinadas funciones de la Plataforma, el usuario deberá crear una cuenta proporcionando información veraz y actualizada. El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso y de todas las actividades que ocurran bajo su cuenta.</p>
        <p>El usuario se compromete a notificar de inmediato cualquier uso no autorizado de su cuenta.</p>
    </section>

    <section class="legal-section">
        <h2>4. Uso aceptable</h2>
        <p>El usuario se compromete a utilizar la Plataforma de manera lícita y respetuosa, absteniéndose de:</p>
        <ul>
            <li>Intentar vulnerar la seguridad o integridad de la Plataforma.</li>
            <li>Utilizar la Plataforma para difundir contenido ofensivo, difamatorio o ilegal.</li>
            <li>Realizar ingeniería inversa, extracción masiva de datos (scraping) o uso automatizado no autorizado.</li>
            <li>Suplantar la identidad de otra persona o entidad.</li>
        </ul>
    </section>

    <section class="legal-section">
        <h2>5. Contenido de terceros</h2>
        <p>Parte de la información mostrada (noticias, estadísticas, resultados y videos) proviene de servicios y APIs de terceros. FutbolLiveCo no controla ni garantiza la exactitud, actualidad o disponibilidad continua de dicha información, y no se hace responsable por errores u omisiones en el contenido proporcionado por dichos terceros.</p>
    </section>

    <section class="legal-section">
        <h2>6. Limitación de responsabilidad</h2>
        <p>La Plataforma se ofrece "tal cual" y "según disponibilidad", sin garantías de ningún tipo. En la medida permitida por la ley aplicable, FutbolLiveCo no será responsable por daños directos o indirectos derivados del uso o la imposibilidad de uso de la Plataforma.</p>
    </section>

    <section class="legal-section">
        <h2>7. Modificaciones</h2>
        <p>Nos reservamos el derecho de modificar estos Términos en cualquier momento. Los cambios entrarán en vigor desde su publicación en esta página. El uso continuado de la Plataforma tras la publicación de los cambios constituye la aceptación de los mismos.</p>
    </section>

    <section class="legal-section">
        <h2>8. Legislación aplicable</h2>
        <p>Estos Términos se rigen por la legislación de la República de Colombia, sin perjuicio de las normas de protección al consumidor y de datos personales que resulten aplicables.</p>
    </section>

    </main>

<%@ include file="/footer.jsp" %>

</body>
</html>
