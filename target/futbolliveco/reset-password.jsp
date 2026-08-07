<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    String tokenError = (String) request.getAttribute("tokenError");
    Boolean tokenValido = (Boolean) request.getAttribute("tokenValido");
    String token = (String) request.getAttribute("token");
    String formError = (String) request.getAttribute("formError");
    if (tokenValido == null) tokenValido = false;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo – Nueva contraseña</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
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
        .strength-bar {
            height: 4px; border-radius: 2px;
            background: #2a2d3e; margin-top: 6px;
            overflow: hidden;
        }
        .strength-fill {
            height: 100%; width: 0;
            transition: width 0.3s, background 0.3s;
            border-radius: 2px;
        }
        .strength-label {
            font-size: 0.72rem; margin-top: 4px;
            color: var(--text-muted);
        }
        .error-box {
            background: rgba(233,69,96,0.1);
            border: 1px solid rgba(233,69,96,0.35);
            border-radius: var(--r-md);
            padding: 16px; margin-bottom: 20px;
            font-size: 0.88rem; color: #e94560;
            text-align: center; line-height: 1.5;
        }
        button:disabled { opacity: 0.7; cursor: not-allowed; }
    </style>
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="card">
    <h1>FutbolLiveCo</h1>
    <p class="subtitle">Crear nueva contraseña</p>

    <% if (tokenError != null) { %>
        <!-- Token inválido o expirado -->
        <div class="error-box">
            <strong>Enlace no válido</strong><br>
            <%= tokenError %>
        </div>
        <div class="link" style="text-align:center;margin-top:0;">
            <a href="<%= request.getContextPath() %>/api/forgot-password">
                ← Solicitar un nuevo enlace
            </a>
        </div>

    <% } else if (tokenValido) { %>
        <!-- Formulario de nueva contraseña -->
        <% if (formError != null) { %>
            <p class="mensaje error" style="margin-bottom:16px;"><%= formError %></p>
        <% } %>

        <form id="reset-form"
              action="<%= request.getContextPath() %>/api/reset-password"
              method="POST" onsubmit="return validarFormulario()">

            <input type="hidden" name="token" value="<%= token %>">

            <div class="form-group">
                <label for="password">Nueva contraseña</label>
                <div class="input-wrapper">
                    <input type="password" id="password" name="password"
                           placeholder="Mínimo 8 caracteres"
                           autocomplete="new-password"
                           oninput="evaluarFortaleza(); validarCoincidencia()">
                    <button class="toggle-password" type="button"
                            onclick="toggle('password', this)">Mostrar</button>
                </div>
                <div class="strength-bar"><div class="strength-fill" id="strength-fill"></div></div>
                <div class="strength-label" id="strength-label"></div>
            </div>

            <div class="form-group">
                <label for="confirm">Confirmar contraseña</label>
                <div class="input-wrapper">
                    <input type="password" id="confirm" name="confirm"
                           placeholder="Repite la contraseña"
                           autocomplete="new-password"
                           oninput="validarCoincidencia()">
                    <button class="toggle-password" type="button"
                            onclick="toggle('confirm', this)">Mostrar</button>
                </div>
                <p class="strength-label" id="match-label" style="min-height:16px;"></p>
            </div>

            <button type="submit" id="btn-guardar">Guardar contraseña</button>
            <p class="mensaje" id="mensaje"></p>
        </form>

    <% } else { %>
        <!-- Sin token en la URL -->
        <div class="error-box">
            Acceso no válido. Usa el enlace que recibiste por email.
        </div>
        <div class="link" style="text-align:center;margin-top:0;">
            <a href="<%= request.getContextPath() %>/api/forgot-password">
                ← Solicitar enlace de recuperación
            </a>
        </div>
    <% } %>
</div>

<script>
function toggle(id, btn) {
    var input = document.getElementById(id);
    if (input.type === 'password') { input.type = 'text';     btn.textContent = 'Ocultar'; }
    else                           { input.type = 'password'; btn.textContent = 'Mostrar'; }
}

function evaluarFortaleza() {
    var pw   = document.getElementById('password').value;
    var fill = document.getElementById('strength-fill');
    var lbl  = document.getElementById('strength-label');
    var score = 0;
    if (pw.length >= 8)  score++;
    if (/[A-Z]/.test(pw)) score++;
    if (/[0-9]/.test(pw)) score++;
    if (/[^A-Za-z0-9]/.test(pw)) score++;

    var info = [
        { w: '0%',   bg: 'transparent', txt: '' },
        { w: '25%',  bg: '#e94560',     txt: 'Débil' },
        { w: '50%',  bg: '#f0a500',     txt: 'Regular' },
        { w: '75%',  bg: '#4fc3f7',     txt: 'Buena' },
        { w: '100%', bg: '#4caf50',     txt: 'Fuerte' }
    ][score];

    fill.style.width      = info.w;
    fill.style.background = info.bg;
    lbl.textContent       = info.txt;
    lbl.style.color       = info.bg;
}

function validarCoincidencia() {
    var pw  = document.getElementById('password').value;
    var cf  = document.getElementById('confirm').value;
    var lbl = document.getElementById('match-label');
    if (!cf) { lbl.textContent = ''; return; }
    if (pw === cf) {
        lbl.textContent = '✓ Las contraseñas coinciden';
        lbl.style.color = '#4caf50';
    } else {
        lbl.textContent = '✗ Las contraseñas no coinciden';
        lbl.style.color = '#e94560';
    }
}

function validarFormulario() {
    var pw  = document.getElementById('password').value;
    var cf  = document.getElementById('confirm').value;
    var msg = document.getElementById('mensaje');

    if (pw.length < 8) {
        msg.className = 'mensaje error';
        msg.textContent = 'La contraseña debe tener al menos 8 caracteres.';
        return false;
    }
    if (pw !== cf) {
        msg.className = 'mensaje error';
        msg.textContent = 'Las contraseñas no coinciden.';
        return false;
    }
    document.getElementById('btn-guardar').disabled = true;
    document.getElementById('btn-guardar').textContent = 'Guardando...';
    return true;
}
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
