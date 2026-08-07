<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="com.mycompany.futbolliveco.util.CsrfUtil" %>
<%
    if (session.getAttribute("usuarioId") != null) {
        response.sendRedirect("home.jsp");
        return;
    }
    String csrfToken = CsrfUtil.getToken(request);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Registro</title>
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
        .form-group input.valid  { border-color: #4caf50; }
        button:disabled { opacity: 0.7; cursor: not-allowed; }
        .password-hint { font-size: 0.75rem; margin-top: 4px; }
    </style>
</head>
<body>

<%@ include file="navbar.jsp" %>
    <div class="card">
        <h1>FutbolLiveCo</h1>
        <p class="subtitle">Crea tu cuenta</p>

        <div class="form-group">
            <label for="nombre">Nombre</label>
            <input type="text" id="nombre" placeholder="Tu nombre" autocomplete="name">
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" placeholder="tucorreo@email.com"
                   autocomplete="email" oninput="validarEmail()">
        </div>

        <div class="form-group">
            <label for="password">Contraseña</label>
            <div class="input-wrapper">
                <input type="password" id="password" placeholder="••••••••"
                       autocomplete="new-password" oninput="validarPassword()">
                <button class="toggle-password" onclick="togglePassword('password', this)" type="button">Mostrar</button>
            </div>
            <p class="password-hint" id="password-hint"></p>
        </div>

        <div class="form-group">
            <label for="confirmar">Confirmar contraseña</label>
            <div class="input-wrapper">
                <input type="password" id="confirmar" placeholder="••••••••"
                       autocomplete="new-password" oninput="validarConfirmar()">
                <button class="toggle-password" onclick="togglePassword('confirmar', this)" type="button">Mostrar</button>
            </div>
        </div>

        <button id="btn-register" onclick="registrar()">Crear cuenta</button>
        <p class="mensaje" id="mensaje"></p>

        <div class="link">
            ¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión aquí</a>
        </div>
    </div>

    <script>
        var CSRF_TOKEN = '<%= csrfToken %>';

        function togglePassword(inputId, btn) {
            var input = document.getElementById(inputId);
            if (input.type === 'password') {
                input.type = 'text'; btn.textContent = 'Ocultar';
            } else {
                input.type = 'password'; btn.textContent = 'Mostrar';
            }
        }

        function validarEmail() {
            var input = document.getElementById('email');
            var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (input.value.length === 0) input.className = '';
            else if (regex.test(input.value)) input.className = 'valid';
            else input.className = 'invalid';
        }

        function validarPassword() {
            var input = document.getElementById('password');
            var hint  = document.getElementById('password-hint');
            if (input.value.length === 0) {
                input.className = ''; hint.textContent = '';
            } else if (input.value.length < 8) {
                input.className = 'invalid';
                hint.textContent = 'Mínimo 8 caracteres';
                hint.style.color = '#e94560';
            } else {
                input.className = 'valid';
                hint.textContent = 'Contraseña válida';
                hint.style.color = '#4caf50';
            }
            validarConfirmar();
        }

        function validarConfirmar() {
            var pass = document.getElementById('password').value;
            var conf = document.getElementById('confirmar');
            if (conf.value.length === 0) { conf.className = ''; return; }
            conf.className = (conf.value === pass) ? 'valid' : 'invalid';
        }

        document.getElementById('confirmar').addEventListener('keydown', function(e) {
            if (e.key === 'Enter') registrar();
        });

        async function registrar() {
            var nombre    = document.getElementById('nombre').value.trim();
            var email     = document.getElementById('email').value.trim();
            var password  = document.getElementById('password').value.trim();
            var confirmar = document.getElementById('confirmar').value.trim();
            var mensaje   = document.getElementById('mensaje');
            var btn       = document.getElementById('btn-register');

            if (!nombre || !email || !password || !confirmar) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Por favor llena todos los campos';
                return;
            }
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Por favor ingresa un email válido';
                return;
            }
            if (password.length < 8) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'La contraseña debe tener al menos 8 caracteres';
                return;
            }
            if (password !== confirmar) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Las contraseñas no coinciden';
                return;
            }

            btn.textContent = 'Creando cuenta...';
            btn.disabled = true;
            mensaje.textContent = '';

            try {
                var body = 'nombre='   + encodeURIComponent(nombre)
                         + '&email='    + encodeURIComponent(email)
                         + '&password=' + encodeURIComponent(password)
                         + '&_csrf='    + encodeURIComponent(CSRF_TOKEN);
                var resp = await fetch('<%= request.getContextPath() %>/api/register', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: body
                });
                var data = await resp.json();
                if (data.ok) {
                    mensaje.className = 'mensaje ok';
                    mensaje.textContent = '¡Cuenta creada correctamente!';
                    setTimeout(function() { window.location.href = 'login.jsp'; }, 1500);
                } else {
                    mensaje.className = 'mensaje error';
                    mensaje.textContent = data.mensaje;
                    btn.textContent = 'Crear cuenta';
                    btn.disabled = false;
                }
            } catch (e) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Error al conectar con el servidor';
                btn.textContent = 'Crear cuenta';
                btn.disabled = false;
            }
        }
    </script>
<%@ include file="/footer.jsp" %>

</body>
</html>
