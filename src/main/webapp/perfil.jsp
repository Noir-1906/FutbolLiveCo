<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%@ page import="com.mycompany.futbolliveco.util.CsrfUtil" %>
<%
    if (session.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String nombreUsuario = (String) session.getAttribute("usuarioNombre");
    String csrfToken = CsrfUtil.getToken(request);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Mi Perfil</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <style>
        .perfil-container { max-width: 600px; margin: 40px auto; padding: 0 20px 40px; }
        .perfil-header { display: flex; flex-direction: column; align-items: center; margin-bottom: 30px; }
        .foto-wrapper { position: relative; width: 100px; height: 100px; margin-bottom: 12px; }
        .foto-perfil {
            width: 100px; height: 100px; border-radius: 50%;
            object-fit: cover; border: 3px solid #e94560; background-color: #16213e;
        }
        .foto-placeholder {
            width: 100px; height: 100px; border-radius: 50%;
            background-color: #16213e; border: 3px solid #e94560;
            display: flex; align-items: center; justify-content: center; font-size: 2.5rem;
        }
        .btn-foto {
            position: absolute; bottom: 0; right: 0;
            width: 30px; height: 30px; border-radius: 50%;
            background-color: #e94560; border: 2px solid #16213e; cursor: pointer;
            font-size: 0.8rem; display: flex; align-items: center;
            justify-content: center; padding: 0; margin: 0;
        }
        .btn-quitar-foto {
            position: absolute; top: 0; right: 0;
            width: 24px; height: 24px; border-radius: 50%;
            background-color: #555b6e; border: 2px solid #16213e; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            padding: 0; margin: 0;
        }
        .btn-quitar-foto:hover { background-color: #6c7086; }
        .perfil-nombre { font-size: 1.3rem; font-weight: bold; color: #eeeeee; }
        .seccion-perfil {
            background-color: #16213e; border: 1px solid #0f3460;
            border-radius: 12px; padding: 24px; margin-bottom: 20px;
        }
        .seccion-perfil h3 {
            font-size: 1rem; color: #e94560; margin-bottom: 18px;
            border-bottom: 1px solid #0f3460; padding-bottom: 10px;
        }
        input[type="file"] { display: none; }
        button:disabled { opacity: 0.7; cursor: not-allowed; }
    </style>
</head>
<body>
<%@ include file="navbar.jsp" %>

    <div class="perfil-container">

        <div class="perfil-header">
            <div class="foto-wrapper">
                <div class="foto-placeholder" id="foto-placeholder">
                    <svg viewBox="0 0 24 24" width="44" height="44" fill="none" stroke="#e94560" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="8" r="4"></circle>
                        <path d="M4 20c0-4.4 3.6-7 8-7s8 2.6 8 7"></path>
                    </svg>
                </div>
                <img class="foto-perfil" id="foto-img" style="display:none" src="" alt="Foto de perfil">
                <button class="btn-foto" onclick="document.getElementById('input-foto').click()" title="Cambiar foto">
                    <svg viewBox="0 0 24 24" width="15" height="15" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M4 8h3l1.5-2h7L17 8h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1z"></path>
                        <circle cx="12" cy="14" r="3.2"></circle>
                    </svg>
                </button>
                <button class="btn-quitar-foto" id="btn-quitar-foto" onclick="quitarFoto()" title="Eliminar foto" style="display:none">
                    <svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="#ffffff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M6 6l12 12M18 6L6 18"></path>
                    </svg>
                </button>
                <input type="file" id="input-foto" accept="image/*" onchange="subirFoto(this)">
            </div>
            <div class="perfil-nombre" id="perfil-nombre"><%= nombreUsuario %></div>
        </div>

        <div class="seccion-perfil">
            <h3>Datos personales</h3>
            <div class="form-group">
                <label>Nombre</label>
                <input type="text" id="nombre" placeholder="Tu nombre">
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" id="email" placeholder="tucorreo@email.com">
            </div>
            <button id="btn-datos" onclick="actualizarDatos()">Guardar cambios</button>
            <p class="mensaje" id="mensaje-datos"></p>
        </div>

        <div class="seccion-perfil">
            <h3>Cambiar contraseña</h3>
            <div class="form-group">
                <label>Contraseña actual</label>
                <input type="password" id="pass-actual" placeholder="••••••••">
            </div>
            <div class="form-group">
                <label>Nueva contraseña (mínimo 8 caracteres)</label>
                <input type="password" id="pass-nueva" placeholder="••••••••">
            </div>
            <div class="form-group">
                <label>Confirmar nueva contraseña</label>
                <input type="password" id="pass-confirmar" placeholder="••••••••">
            </div>
            <button id="btn-pass" onclick="cambiarPassword()">Cambiar contraseña</button>
            <p class="mensaje" id="mensaje-pass"></p>
        </div>

    </div>

    <script>
        var CSRF_TOKEN = '<%= csrfToken %>';

        async function cargarPerfil() {
            try {
                var resp = await fetch('<%= request.getContextPath() %>/api/perfil');
                var data = await resp.json();
                if (data.ok) {
                    document.getElementById('nombre').value = data.nombre;
                    document.getElementById('email').value  = data.email;
                    document.getElementById('perfil-nombre').textContent = data.nombre;
                    if (data.foto) {
                        mostrarFoto('/futbolliveco' + data.foto);
                    }
                }
            } catch (e) {
                console.error('Error cargando perfil:', e);
            }
        }

        function mostrarFoto(src) {
            document.getElementById('foto-placeholder').style.display = 'none';
            var img = document.getElementById('foto-img');
            img.src = src;
            img.style.display = 'block';
            document.getElementById('btn-quitar-foto').style.display = 'flex';
        }

        function mostrarPlaceholder() {
            document.getElementById('foto-img').style.display = 'none';
            document.getElementById('foto-img').src = '';
            document.getElementById('foto-placeholder').style.display = 'flex';
            document.getElementById('btn-quitar-foto').style.display = 'none';
        }

        async function actualizarDatos() {
            var nombre  = document.getElementById('nombre').value.trim();
            var email   = document.getElementById('email').value.trim();
            var mensaje = document.getElementById('mensaje-datos');
            var btn     = document.getElementById('btn-datos');

            if (!nombre || !email) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Nombre y email son obligatorios';
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Guardando...';

            try {
                var body = 'accion=datos&nombre=' + encodeURIComponent(nombre)
                         + '&email=' + encodeURIComponent(email)
                         + '&_csrf=' + encodeURIComponent(CSRF_TOKEN);
                var resp = await fetch('<%= request.getContextPath() %>/api/perfil', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: body
                });
                var data = await resp.json();
                mensaje.className = 'mensaje ' + (data.ok ? 'ok' : 'error');
                mensaje.textContent = data.mensaje;
                if (data.ok) {
                    document.getElementById('perfil-nombre').textContent = data.nombre;
                }
            } catch (e) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Error al conectar con el servidor';
            }
            btn.disabled = false;
            btn.textContent = 'Guardar cambios';
        }

        async function cambiarPassword() {
            var actual    = document.getElementById('pass-actual').value.trim();
            var nueva     = document.getElementById('pass-nueva').value.trim();
            var confirmar = document.getElementById('pass-confirmar').value.trim();
            var mensaje   = document.getElementById('mensaje-pass');
            var btn       = document.getElementById('btn-pass');

            if (!actual || !nueva || !confirmar) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Todos los campos son obligatorios';
                return;
            }
            if (nueva.length < 8) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'La nueva contraseña debe tener al menos 8 caracteres';
                return;
            }
            if (nueva !== confirmar) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Las contraseñas no coinciden';
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Cambiando...';

            try {
                var body = 'accion=password&actual=' + encodeURIComponent(actual)
                         + '&nueva=' + encodeURIComponent(nueva)
                         + '&_csrf=' + encodeURIComponent(CSRF_TOKEN);
                var resp = await fetch('<%= request.getContextPath() %>/api/perfil', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: body
                });
                var data = await resp.json();
                mensaje.className = 'mensaje ' + (data.ok ? 'ok' : 'error');
                mensaje.textContent = data.mensaje;
                if (data.ok) {
                    document.getElementById('pass-actual').value    = '';
                    document.getElementById('pass-nueva').value     = '';
                    document.getElementById('pass-confirmar').value = '';
                }
            } catch (e) {
                mensaje.className = 'mensaje error';
                mensaje.textContent = 'Error al conectar con el servidor';
            }
            btn.disabled = false;
            btn.textContent = 'Cambiar contraseña';
        }

        async function subirFoto(input) {
            if (!input.files || !input.files[0]) return;
            var formData = new FormData();
            formData.append('accion', 'foto');
            formData.append('foto', input.files[0]);
            formData.append('_csrf', CSRF_TOKEN);

            try {
                var resp = await fetch('<%= request.getContextPath() %>/api/perfil', {
                    method: 'POST',
                    body: formData
                });
                var data = await resp.json();
                if (data.ok) {
                    // data.foto es una ruta como "/fotos/42.jpg"
                    mostrarFoto('/futbolliveco' + data.foto);
                } else {
                    alert(data.mensaje);
                }
            } catch (e) {
                alert('Error al subir la foto');
            }
        }

        async function quitarFoto() {
            if (!confirm('¿Seguro que quieres eliminar tu foto de perfil?')) return;

            try {
                var body = 'accion=eliminar-foto&_csrf=' + encodeURIComponent(CSRF_TOKEN);
                var resp = await fetch('<%= request.getContextPath() %>/api/perfil', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: body
                });
                var data = await resp.json();
                if (data.ok) {
                    mostrarPlaceholder();
                } else {
                    alert(data.mensaje);
                }
            } catch (e) {
                alert('Error al eliminar la foto');
            }
        }

        cargarPerfil();
    </script>
<%@ include file="/footer.jsp" %>

</body>
</html>
