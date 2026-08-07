<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="com.mycompany.futbolliveco.util.CsrfUtil" %>
<%
    if (session.getAttribute("usuarioId") != null) {
        response.sendRedirect("home.jsp");
        return;
    }
    String redir = request.getParameter("redir");
    if (redir == null || redir.trim().isEmpty()) redir = "home.jsp";
    String csrfToken = CsrfUtil.getToken(request);
    String msgReset = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Login</title>
    <link rel="stylesheet" href="css/base.css">
    <link rel="stylesheet" href="css/navbar.css">
    <style>
        .input-wrapper { position: relative; }
        .toggle-password {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; color: #aaaaaa;
            cursor: pointer; font-size: 0.8rem;
            width: auto; margin: 0; padding: 0;
        }
        .toggle-password:hover { background: none; color: #e94560; }
        .form-group input.invalid { border-color: #e94560; }
        .form-group input.valid   { border-color: #4caf50; }
        button:disabled { opacity: 0.7; cursor: not-allowed; }
    </style>
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="card">
    <h1>FutbolLiveCo</h1>
    <p class="subtitle">Inicia sesión para continuar</p>

    <% if (msgReset != null && !msgReset.isEmpty()) { %>
    <p class="mensaje ok" style="margin-bottom:12px;">
        <%= java.net.URLDecoder.decode(msgReset, "UTF-8") %>
    </p>
    <% } %>

    <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" placeholder="tucorreo@email.com"
               autocomplete="email" oninput="validarEmail()">
    </div>

    <div class="form-group">
        <label for="password">Contraseña</label>
        <div class="input-wrapper">
            <input type="password" id="password" placeholder="••••••••"
                   autocomplete="current-password">
            <button class="toggle-password" onclick="togglePassword(this)" type="button">Mostrar</button>
        </div>
    </div>

    <button id="btn-login" onclick="login()">Iniciar sesión</button>
    <p class="mensaje" id="mensaje"></p>

    <div class="link" style="margin-bottom: 8px;">
        <a href="<%= request.getContextPath() %>/api/forgot-password">¿Olvidaste tu contraseña?</a>
    </div>
    <div class="link">
        ¿No tienes cuenta? <a href="register.jsp">Regístrate aquí</a>
    </div>
</div>

<script>
var REDIR       = '<%= redir %>';
var CSRF_TOKEN  = '<%= csrfToken %>';

function togglePassword(btn) {
    var input = document.getElementById('password');
    if (input.type === 'password') { input.type = 'text'; btn.textContent = 'Ocultar'; }
    else { input.type = 'password'; btn.textContent = 'Mostrar'; }
}

function validarEmail() {
    var input = document.getElementById('email');
    var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (input.value.length === 0) input.className = '';
    else if (regex.test(input.value)) input.className = 'valid';
    else input.className = 'invalid';
}

document.getElementById('email').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') document.getElementById('password').focus();
});
document.getElementById('password').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') login();
});

async function login() {
    var email    = document.getElementById('email').value.trim();
    var password = document.getElementById('password').value.trim();
    var mensaje  = document.getElementById('mensaje');
    var btn      = document.getElementById('btn-login');

    if (!email || !password) {
        mensaje.className = 'mensaje error';
        mensaje.textContent = 'Por favor llena todos los campos';
        return;
    }

    btn.textContent = 'Iniciando sesión...';
    btn.disabled = true;
    mensaje.textContent = '';

    try {
        var body = 'email='    + encodeURIComponent(email)
                 + '&password=' + encodeURIComponent(password)
                 + '&_csrf='    + encodeURIComponent(CSRF_TOKEN);
        var resp = await fetch('<%= request.getContextPath() %>/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body
        });
        var data = await resp.json();
        if (data.ok) {
            mensaje.className = 'mensaje ok';
            mensaje.textContent = '¡Bienvenido ' + data.nombre + '!';
            setTimeout(function() { window.location.href = REDIR; }, 800);
        } else {
            mensaje.className = 'mensaje error';
            mensaje.textContent = data.mensaje;
            btn.textContent = 'Iniciar sesión';
            btn.disabled = false;
        }
    } catch (e) {
        mensaje.className = 'mensaje error';
        mensaje.textContent = 'Error al conectar con el servidor';
        btn.textContent = 'Iniciar sesión';
        btn.disabled = false;
    }
}
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
