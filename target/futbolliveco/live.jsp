<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - En Vivo</title>
    <link rel="stylesheet" href="css/base.css">
    <link rel="stylesheet" href="css/navbar.css">
    <link rel="stylesheet" href="css/live.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="page-header">
    <div class="page-header-title">
        <span class="live-dot"></span>Partidos en Vivo
    </div>
</div>

<div id="matches">
    <div class="estado-loading">Cargando partidos...</div>
</div>

<script>
var partidos = [];

function renderTarjetas() {
    var container = document.getElementById('matches');

    if (!partidos || partidos.length === 0) {
        container.innerHTML = '<p class="estado-empty">No hay partidos en vivo en este momento</p>';
        return;
    }

    var html = '';
    for (var i = 0; i < partidos.length; i++) {
        var p = partidos[i];
        html += '<div class="match-card live" onclick="this.classList.toggle(\'open\')">';
        html += '<div class="match-header">';

        html += '<div class="team-block">';
        if (p.homeLogo) html += '<img class="team-logo" src="' + p.homeLogo + '" alt="" onerror="this.style.display=\'none\'">';
        html += '<span class="team-name">' + p.homeTeam + '</span></div>';

        html += '<div class="center-info">';
        html += '<div class="score">' + p.homeScore + ' - ' + p.awayScore + '</div>';
        html += '<div class="badge-live" data-idx="' + i + '">' + p.minute + '\'</div>';
        html += '</div>';

        html += '<div class="team-block">';
        if (p.awayLogo) html += '<img class="team-logo" src="' + p.awayLogo + '" alt="" onerror="this.style.display=\'none\'">';
        html += '<span class="team-name">' + p.awayTeam + '</span></div>';

        html += '</div>';

        html += '<div class="match-detail">';
        if (p.liga) {
            html += '<div class="liga-info">';
            if (p.ligaLogo) html += '<img class="liga-logo" src="' + p.ligaLogo + '" alt="">';
            html += p.liga + (p.ronda ? ' &mdash; ' + p.ronda : '') + '</div>';
        }
        if (p.estadio) {
            html += '<div class="estadio">' + p.estadio + (p.ciudad ? ', ' + p.ciudad : '') + '</div>';
        }
        if (p.eventos && p.eventos.length > 0) {
            html += '<ul class="eventos-lista">';
            for (var j = 0; j < p.eventos.length; j++) {
                var ev = p.eventos[j];
                var icono = ev.type === 'Goal' ? '' : ev.type === 'Card' ? '' : '&#8635;';
                html += '<li><span class="evento-min">' + ev.time.elapsed + '\'</span>' + icono + ' ' + (ev.player ? ev.player.name : '') + '</li>';
            }
            html += '</ul>';
        } else {
            html += '<p style="font-size:0.8rem;color:#666;">Sin eventos registrados</p>';
        }
        html += '</div>';
        html += '</div>';
    }
    container.innerHTML = html;
}

async function loadMatches() {
    try {
        var API_LIVE = '<%= request.getContextPath() %>/api/live';
        var resp = await fetch(API_LIVE);
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var data = await resp.json();

        if (!data.response) {
            document.getElementById('matches').innerHTML = '<p class="estado-error">Error al cargar partidos</p>';
            return;
        }

        partidos = [];
        for (var i = 0; i < data.response.length; i++) {
            var fixture = data.response[i];
            var ESTADOS_EN_VIVO = new Set(['1H','2H','HT','ET','BT','P','SUSP','INT','LIVE']);
            var s = fixture.fixture.status.short;
            
            if (!ESTADOS_EN_VIVO.has(s)) continue;

            var venue = fixture.fixture.venue;
            partidos.push({
                homeTeam:  fixture.teams.home.name,
                awayTeam:  fixture.teams.away.name,
                homeLogo:  fixture.teams.home.logo,
                awayLogo:  fixture.teams.away.logo,
                homeScore: fixture.goals.home !== null ? fixture.goals.home : 0,
                awayScore: fixture.goals.away !== null ? fixture.goals.away : 0,
                minute:    fixture.fixture.status.elapsed || 0,
                estadio:   venue && venue.name ? venue.name : null,
                ciudad:    venue && venue.city ? venue.city : null,
                liga:      fixture.league ? fixture.league.name : null,
                ligaLogo:  fixture.league ? fixture.league.logo : null,
                ronda:     fixture.league ? fixture.league.round : null,
                eventos:   fixture.events || []
            });
        }

        renderTarjetas();

    } catch (e) {
        document.getElementById('matches').innerHTML =
            '<p class="estado-error">No se pudo conectar: ' + e.message + '</p>';
    }
}

function actualizarMinutos() {
    for (var i = 0; i < partidos.length; i++) {
        if (partidos[i].minute > 0) partidos[i].minute += 1;
        var badge = document.querySelector('[data-idx="' + i + '"]');
        if (badge) badge.textContent = partidos[i].minute + '\'';
    }
}

loadMatches();
setInterval(loadMatches, 60000);
setInterval(actualizarMinutos, 1000);
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
