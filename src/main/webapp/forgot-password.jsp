<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    if (session.getAttribute("usuarioId") != null) {
        response.sendRedirect("home.jsp");
        return;
    }
    String status = request.getParameter("status");
    String error  = request.getParameter("error");
    boolean enviado = "enviado".equals(status);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo – Recuperar contraseña</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <style>
        .info-box {
            background: rgba(79,172,254,0.08);
            border: 1px solid rgba(79,172,254,0.3);
            border-radius: var(--r-md);
            padding: 14px 16px;
            margin-bottom: 20px;
            font-size: 0.85rem;
            color: #7ec8fa;
            text-align: center;
            line-height: 1.5;
        }
        .ok-box {
            background: rgba(76,175,80,0.1);
            border: 1px solid rgba(76,175,80,0.35);
            border-radius: var(--r-md);
            padding: 20px 16px;
            margin-bottom: 20px;
            font-size: 0.9rem;
            color: var(--green-live);
            text-align: center;
            line-height: 1.6;
        }
        .ok-box .icon { font-size: 2rem; display: block; margin-bottom: 8px; }
        button:disabled { opacity: 0.7; cursor: not-allowed; }
        .form-group input.invalid { border-color: #e94560; }
        .form-group input.valid   { border-color: #4caf50; }
    </style>
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="card">
    <h1>FutbolLiveCo</h1>
    <p class="subtitle">Recuperar contraseña</p>

    <% if (error != null && !error.isEmpty()) { %>
        <p class="mensaje error" style="margin-bottom:16px;">
            <%= java.net.URLDecoder.decode(error, "UTF-8") %>
        </p>
    <% } %>

    <% if (enviado) { %>
        <div class="ok-box">
            <span class="icon">📧</span>
            Si ese correo está registrado, recibirás un enlace para restablecer
            tu contraseña en los próximos minutos.<br>
            <small style="color:#888;">Revisa también tu carpeta de spam.</small>
        </div>
        <div class="link">
            <a href="<%= request.getContextPath() %>/login.jsp">← Volver al inicio de sesión</a>
        </div>
    <% } else { %>
        <div class="info-box">
            Ingresa tu email y te enviaremos un enlace para crear una nueva contraseña.
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" placeholder="tucorreo@gmail.com"
                   autocomplete="email" oninput="validarEmail()">
        </div>

        <button id="btn-enviar" onclick="enviar()">Enviar enlace</button>
        <p class="mensaje" id="mensaje"></p>

        <div class="link">
            ¿Recuerdas tu contraseña? <a href="<%= request.getContextPath() %>/login.jsp">Inicia sesión</a>
        </div>
    <% } %>
</div>

<script>
function validarEmail() {
    var input = document.getElementById('email');
    var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (input.value.length === 0) input.className = '';
    else if (regex.test(input.value)) input.className = 'valid';
    else input.className = 'invalid';
}

document.getElementById && document.getElementById('email') &&
    document.getElementById('email').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') enviar();
    });

function enviar() {
    var email   = document.getElementById('email').value.trim();
    var mensaje = document.getElementById('mensaje');
    var btn     = document.getElementById('btn-enviar');

    if (!email) {
        mensaje.className = 'mensaje error';
        mensaje.textContent = 'Por favor ingresa tu email.';
        return;
    }

    btn.disabled = true;
    btn.textContent = 'Enviando...';
    mensaje.textContent = '';

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '<%= request.getContextPath() %>/api/forgot-password';
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'email';
    input.value = email;
    form.appendChild(input);
    document.body.appendChild(form);
    form.submit();
}
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
