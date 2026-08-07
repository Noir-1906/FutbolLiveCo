<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    if (session.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp?redir=jugadores.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Jugadores</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/jugadores.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="jugadores-header">
    <h1>Buscar Jugador</h1>
    <p class="jugadores-sub">Busca cualquier jugador del mundo y ve su información</p>
    <div class="busqueda-wrap">
        <input type="text" id="input-nombre" class="ctrl-input"
               placeholder="Ej: Messi, Haaland, Vinicius, James Rodriguez..."
               onkeydown="if(event.key==='Enter') buscar()">
        <button class="btn-buscar-j" onclick="buscar()">Buscar</button>
    </div>

    <div class="quick-jugadores">
        <span class="quick-jug" onclick="buscarTag('Mbappe')">Mbappé</span>
        <span class="quick-jug" onclick="buscarTag('Haaland')">Haaland</span>
        <span class="quick-jug" onclick="buscarTag('Vinicius')">Vinicius Jr.</span>
        <span class="quick-jug" onclick="buscarTag('Bellingham')">Bellingham</span>
        <span class="quick-jug" onclick="buscarTag('Messi')">Messi</span>
        <span class="quick-jug" onclick="buscarTag('James Rodriguez')">James Rodríguez</span>
        <span class="quick-jug" onclick="buscarTag('Falcao')">Falcao</span>
    </div>
</div>

<div class="jugadores-tabla-wrap" id="jugadores-container">
    <p class="estado-empty">Busca un jugador para ver su información</p>
</div>

<script>
function buscarTag(nombre) {
    document.getElementById('input-nombre').value = nombre;
    buscar();
}

function renderJugadores(jugadores) {
    var container = document.getElementById('jugadores-container');

    if (!jugadores || jugadores.length === 0) {
        container.innerHTML = '<p class="estado-empty">No se encontró ningún jugador con ese nombre</p>';
        return;
    }

    var html = '<div class="jugadores-grid">';
    for (var i = 0; i < jugadores.length; i++) {
        var j = jugadores[i];
        var foto = j.strThumb || j.strCutout || null;
        var pos  = j.strPosition || '—';
        var nac  = j.strNationality || '—';
        var club = j.strTeam || '—';
        var desc = j.strDescriptionEN || j.strDescriptionES || null;
        var altura = j.strHeight || null;
        var peso   = j.strWeight || null;

        html += '<div class="jugador-card">';

        // Foto
        html += '<div class="jugador-card-foto">';
        if (foto) {
            html += '<img src="' + foto + '" alt="' + j.strPlayer + '" onerror="this.parentElement.innerHTML=\'<div class=jugador-foto-big></div>\'">';
        } else {
            html += '<div class="jugador-foto-big"></div>';
        }
        html += '</div>';

        // Info
        html += '<div class="jugador-card-info">';
        html += '<h2 class="jugador-card-nombre">' + (j.strPlayer || '—') + '</h2>';

        html += '<div class="jugador-card-tags">';
        html += '<span class="jugador-tag pos">' + pos + '</span>';
        html += '<span class="jugador-tag nac">' + nac + '</span>';
        if (j.strNationalityISO2) {
            html += '<span class="jugador-tag club">' + club + '</span>';
        } else {
            html += '<span class="jugador-tag club">' + club + '</span>';
        }
        html += '</div>';

        html += '<div class="jugador-card-datos">';
        if (altura) html += '<div class="jugador-dato"><span class="dato-label">Altura</span><span class="dato-val">' + altura + '</span></div>';
        if (peso)   html += '<div class="jugador-dato"><span class="dato-label">Peso</span><span class="dato-val">' + peso + '</span></div>';
        if (j.strBirthLocation) html += '<div class="jugador-dato"><span class="dato-label">Origen</span><span class="dato-val">' + j.strBirthLocation + '</span></div>';
        html += '</div>';

        if (desc) {
            var descCorta = desc.length > 300 ? desc.substring(0, 300) + '...' : desc;
            html += '<p class="jugador-card-desc">' + descCorta + '</p>';
        }
        html += '</div>';
        html += '</div>';
    }
    html += '</div>';
    container.innerHTML = html;
}

async function buscar() {
    var nombre    = document.getElementById('input-nombre').value.trim();
    var container = document.getElementById('jugadores-container');

    if (!nombre) {
        container.innerHTML = '<p class="estado-empty">Escribe el nombre de un jugador</p>';
        return;
    }

    container.innerHTML = '<div class="estado-loading">Buscando...</div>';

    try {
        var resp = await fetch('<%= request.getContextPath() %>/api/jugadores?nombre=' + encodeURIComponent(nombre));
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var data = await resp.json();
        renderJugadores(data.player);
    } catch(e) {
        container.innerHTML = '<p class="estado-error">No se pudo conectar: ' + e.message + '</p>';
    }
}
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
