<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    if (session.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp?redir=programados.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Partidos Programados</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/programados.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="programados-header">
    <h1>Partidos Programados</h1>
    <div class="filtros-programados">
        <div class="filtro-group">
            <label>Competición</label>
            <select id="select-liga" class="filtro-select">
                <option value="PL">Premier League</option>
                <option value="PD">La Liga</option>
                <option value="BL1">Bundesliga</option>
                <option value="SA">Serie A</option>
                <option value="FL1">Ligue 1</option>
                <option value="CL">Champions League</option>
            </select>
        </div>
        <div class="filtro-group">
            <label>Día</label>
            <select id="select-dia" class="filtro-select">
                <option value="0">Hoy</option>
                <option value="1">Mañana</option>
                <option value="2">Pasado mañana</option>
                <option value="-1">Ayer</option>
            </select>
        </div>
        <button class="btn-buscar" onclick="buscarProgramados()">Buscar</button>
    </div>
</div>

<div id="matches-programados">
    <div class="estado-loading">Selecciona una competición y haz clic en Buscar</div>
</div>

<script>
function renderTarjetas(partidos, containerId) {
    var container = document.getElementById(containerId);
    if (!partidos || partidos.length === 0) {
        container.innerHTML = '<p class="estado-empty">No hay partidos programados para ese día</p>';
        return;
    }

    var html = '';
    for (var i = 0; i < partidos.length; i++) {
        var p = partidos[i];
        var cardClass = 'match-card' + (p.status === 'LIVE' ? ' live' : '');
        html += '<div class="' + cardClass + '" onclick="this.classList.toggle(\'open\')">';
        html += '<div class="match-header">';

        html += '<div class="team-block">';
        if (p.homeLogo) html += '<img class="team-logo" src="' + p.homeLogo + '" alt="" onerror="this.style.display=\'none\'">';
        html += '<span class="team-name">' + p.homeTeam + '</span></div>';

        html += '<div class="center-info">';
        if (p.status === 'FINISHED') {
            html += '<div class="score">' + p.homeScore + ' - ' + p.awayScore + '</div>';
            html += '<div class="badge-finished">Final</div>';
        } else if (p.status === 'LIVE') {
            html += '<div class="score">' + p.homeScore + ' - ' + p.awayScore + '</div>';
            html += '<div class="badge-live">EN VIVO</div>';
        } else {
            html += '<div class="hora-partido">' + p.hora + '</div>';
            html += '<div class="badge-scheduled">Programado</div>';
        }
        html += '</div>';

        html += '<div class="team-block">';
        if (p.awayLogo) html += '<img class="team-logo" src="' + p.awayLogo + '" alt="" onerror="this.style.display=\'none\'">';
        html += '<span class="team-name">' + p.awayTeam + '</span></div>';

        html += '</div>';

        html += '<div class="match-detail">';
        if (p.liga) html += '<div class="liga-info">' + p.liga + (p.ronda ? ' — ' + p.ronda : '') + '</div>';
        html += '</div>';
        html += '</div>';
    }
    container.innerHTML = html;
}

async function buscarProgramados() {
    var liga = document.getElementById('select-liga').value;
    var dias = parseInt(document.getElementById('select-dia').value);
    var container = document.getElementById('matches-programados');

    var fecha = new Date();
    fecha.setDate(fecha.getDate() + dias);
    var yyyy = fecha.getFullYear();
    var mm   = String(fecha.getMonth() + 1).padStart(2, '0');
    var dd   = String(fecha.getDate()).padStart(2, '0');
    var fechaStr = yyyy + '-' + mm + '-' + dd;

    container.innerHTML = '<div class="estado-loading">Buscando partidos...</div>';

    try {
        var resp = await fetch('<%= request.getContextPath() %>/api/programados?league=' + liga + '&date=' + fechaStr);
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var data = await resp.json();

        if (data.error) {
            container.innerHTML = '<p class="estado-error">Error al cargar partidos</p>';
            return;
        }
        if (!data.matches || data.matches.length === 0) {
            container.innerHTML = '<p class="estado-empty">No hay partidos programados para ese día</p>';
            return;
        }

        var partidos = [];
        for (var i = 0; i < data.matches.length; i++) {
            var m = data.matches[i];
            var estado = 'SCHEDULED';
            if (m.status === 'IN_PLAY' || m.status === 'PAUSED' || m.status === 'HALFTIME') estado = 'LIVE';
            else if (m.status === 'FINISHED' || m.status === 'AWARDED') estado = 'FINISHED';
            var fecha2 = new Date(m.utcDate);
            var hora   = fecha2.toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit' });
            partidos.push({
                homeTeam:  m.homeTeam.name,
                awayTeam:  m.awayTeam.name,
                homeLogo:  m.homeTeam.crest || null,
                awayLogo:  m.awayTeam.crest || null,
                homeScore: m.score && m.score.fullTime && m.score.fullTime.home !== null ? m.score.fullTime.home : 0,
                awayScore: m.score && m.score.fullTime && m.score.fullTime.away !== null ? m.score.fullTime.away : 0,
                status:    estado,
                hora:      hora,
                liga:      m.competition ? m.competition.name : null,
                ronda:     m.matchday ? 'Jornada ' + m.matchday : null
            });
        }
        partidos.sort(function(a, b) { return a.hora.localeCompare(b.hora); });
        renderTarjetas(partidos, 'matches-programados');

    } catch (e) {
        container.innerHTML = '<p class="estado-error">No se pudo conectar: ' + e.message + '</p>';
    }
}

// Cargar hoy al entrar
buscarProgramados();
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
