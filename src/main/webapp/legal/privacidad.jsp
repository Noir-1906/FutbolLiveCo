<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de Privacidad - FutbolLiveCo</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/legal.css">
</head>
<body>

<%@ include file="/navbar.jsp" %>

<main class="legal-main">
    <div class="legal-header">
        <h1 class="legal-title">Política de Privacidad</h1>
        <p class="legal-updated">Última actualización: <%= new java.text.SimpleDateFormat("dd 'de' MMMM 'de' yyyy", new java.util.Locale("es","ES")).format(new java.util.Date()) %></p>
    </div>

    <nav class="legal-nav">
        <a href="<%= request.getContextPath() %>/legal/terminos.jsp">Términos y Condiciones</a>
        <a href="<%= request.getContextPath() %>/legal/privacidad.jsp" class="active">Privacidad</a>
        <a href="<%= request.getContextPath() %>/legal/derechos-autor.jsp">Derechos de Autor</a>
        <a href="<%= request.getContextPath() %>/legal/contacto.jsp">Contacto</a>
    </nav>

    <section class="legal-section">
        <h2>1. Información que recopilamos</h2>
        <p>Al registrarse y utilizar FutbolLiveCo, podemos recopilar los siguientes datos:</p>
        <ul>
            <li><strong>Datos de registro:</strong> nombre, correo electrónico y contraseña (almacenada de forma cifrada mediante el algoritmo BCrypt, nunca en texto plano).</li>
            <li><strong>Datos de perfil:</strong> foto de perfil, en caso de que el usuario decida cargarla.</li>
            <li><strong>Datos técnicos:</strong> dirección IP, tipo de navegador e información de sesión, con fines de seguridad y funcionamiento del servicio.</li>
        </ul>
    </section>

    <section class="legal-section">
        <h2>2. Finalidad del tratamiento</h2>
        <p>Los datos recopilados se utilizan exclusivamente para:</p>
        <ul>
            <li>Permitir el acceso y autenticación del usuario en la Plataforma.</li>
            <li>Personalizar la experiencia del usuario (perfil, preferencias).</li>
            <li>Enviar comunicaciones estrictamente necesarias, como la recuperación de contraseña.</li>
            <li>Mejorar la seguridad y el funcionamiento técnico de la Plataforma.</li>
        </ul>
        <p>No utilizamos los datos personales con fines publicitarios ni los compartimos con terceros para fines comerciales.</p>
    </section>

    <section class="legal-section">
        <h2>3. Seguridad de la información</h2>
        <p>Las contraseñas se almacenan utilizando técnicas de cifrado unidireccional (hashing con BCrypt), por lo que ni siquiera el equipo administrador puede acceder a la contraseña original del usuario. Se implementan además medidas de protección contra ataques comunes, como limitación de intentos de acceso (rate limiting) y protección CSRF.</p>
    </section>

    <section class="legal-section">
        <h2>4. Servicios de terceros</h2>
        <p>Para ofrecer contenido deportivo, la Plataforma consulta servicios externos (proveedores de datos deportivos, noticias y video). Estas consultas no incluyen el envío de datos personales del usuario a dichos terceros; se realizan de forma anónima desde el servidor de la aplicación.</p>
    </section>

    <section class="legal-section">
        <h2>5. Derechos del usuario</h2>
        <p>De acuerdo con la Ley 1581 de 2012 de Colombia (Protección de Datos Personales), el usuario tiene derecho a:</p>
        <ul>
            <li>Conocer, actualizar y rectificar sus datos personales.</li>
            <li>Solicitar la eliminación de sus datos cuando no exista un deber legal de conservarlos.</li>
            <li>Revocar la autorización otorgada para el tratamiento de sus datos.</li>
        </ul>
        <p>Estas solicitudes pueden realizarse a través del correo indicado en la sección de <a href="<%= request.getContextPath() %>/legal/contacto.jsp">Contacto</a>.</p>
    </section>

    <section class="legal-section">
        <h2>6. Conservación de datos</h2>
        <p>Los datos personales se conservarán mientras la cuenta del usuario permanezca activa. El usuario puede solicitar la eliminación de su cuenta y datos asociados en cualquier momento.</p>
    </section>

    <section class="legal-section">
        <h2>7. Cambios en esta política</h2>
        <p>Esta Política de Privacidad puede actualizarse periódicamente. Cualquier cambio relevante será publicado en esta misma página.</p>
    </section>

    </main>

<%@ include file="/footer.jsp" %>

</body>
</html>
