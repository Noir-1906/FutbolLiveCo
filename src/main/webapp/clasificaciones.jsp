<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    if (session.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp?redir=clasificaciones.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Clasificaciones</title>
    <link rel="stylesheet" href="css/base.css">
    <link rel="stylesheet" href="css/navbar.css">
    <link rel="stylesheet" href="css/clasificaciones.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="clasificaciones-header">
    <h1>Clasificaciones</h1>
</div>

<div class="liga-tabs">
    <button class="liga-tab active" data-liga="PL"  onclick="cambiarLiga('PL', this)">Premier League</button>
    <button class="liga-tab"        data-liga="PD"  onclick="cambiarLiga('PD', this)">La Liga</button>
    <button class="liga-tab"        data-liga="BL1" onclick="cambiarLiga('BL1', this)">Bundesliga</button>
    <button class="liga-tab"        data-liga="SA"  onclick="cambiarLiga('SA', this)">Serie A</button>
    <button class="liga-tab"        data-liga="FL1" onclick="cambiarLiga('FL1', this)">Ligue 1</button>
    <button class="liga-tab"        data-liga="CL"  onclick="cambiarLiga('CL', this)">Champions League</button>
</div>

<div class="tabla-wrap">
    <div id="tabla-container">
        <div class="estado-loading">Cargando clasificación...</div>
    </div>
</div>

<script>
var ligaActual = 'PL';

// Zonas de clasificación según liga
var ZONAS = {
    PL:  { champions: [1,2,3,4], europa: [5,6], relegacion: [18,19,20] },
    PD:  { champions: [1,2,3,4], europa: [5,6,7], relegacion: [18,19,20] },
    BL1: { champions: [1,2,3,4], europa: [5,6], relegacion: [16,17,18] },
    SA:  { champions: [1,2,3,4], europa: [5,6,7], relegacion: [18,19,20] },
    FL1: { champions: [1,2,3,4], europa: [5,6,7], relegacion: [16,17,18] },
    CL:  { champions: [1,2,3,4,5,6,7,8], europa: [9,10,11,12,13,14,15,16], relegacion: [17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36] }
};

function getZona(pos, liga) {
    var z = ZONAS[liga] || ZONAS['PL'];
    if (z.champions.indexOf(pos) !== -1) return 'zona-champions';
    if (z.europa.indexOf(pos) !== -1)    return 'zona-europa';
    if (z.relegacion.indexOf(pos) !== -1)return 'zona-relegacion';
    return '';
}

function renderForma(forma) {
    if (!forma) return '';
    var html = '<div class="td-forma">';
    for (var i = 0; i < forma.length; i++) {
        var r = forma[i];
        html += '<span class="forma-' + r + '">' + r + '</span>';
    }
    html += '</div>';
    return html;
}

function renderTabla(data) {
    var container = document.getElementById('tabla-container');

    if (!data.standings || data.standings.length === 0) {
        container.innerHTML = '<p class="estado-empty">No hay datos disponibles para esta liga</p>';
        return;
    }

    // football-data.org devuelve standings[0] para la tabla principal
    var tabla = data.standings[0].table;
    var liga  = ligaActual;

    var html = '<table class="tabla-clasificacion">';
    html += '<thead><tr>';
    html += '<th>#</th>';
    html += '<th class="col-equipo">Equipo</th>';
    html += '<th>PJ</th>';
    html += '<th class="col-hide">G</th>';
    html += '<th class="col-hide">E</th>';
    html += '<th class="col-hide">P</th>';
    html += '<th class="col-hide">GF</th>';
    html += '<th class="col-hide">GC</th>';
    html += '<th>DG</th>';
    html += '<th>Pts</th>';
    html += '<th class="col-hide">Forma</th>';
    html += '</tr></thead><tbody>';

    for (var i = 0; i < tabla.length; i++) {
        var eq   = tabla[i];
        var zona = getZona(eq.position, liga);
        html += '<tr class="' + zona + '">';
        html += '<td class="posicion-num">' + eq.position + '</td>';
        html += '<td class="col-equipo"><div class="equipo-cell">';
        if (eq.team.crest) {
            html += '<img class="equipo-escudo" src="' + eq.team.crest + '" alt="" onerror="this.style.display=\'none\'">';
        }
        html += '<span class="equipo-nombre">' + eq.team.name + '</span>';
        html += '</div></td>';
        html += '<td>' + eq.playedGames + '</td>';
        html += '<td class="col-hide">' + eq.won + '</td>';
        html += '<td class="col-hide">' + eq.draw + '</td>';
        html += '<td class="col-hide">' + eq.lost + '</td>';
        html += '<td class="col-hide">' + eq.goalsFor + '</td>';
        html += '<td class="col-hide">' + eq.goalsAgainst + '</td>';
        var dg = eq.goalDifference > 0 ? '+' + eq.goalDifference : eq.goalDifference;
        html += '<td>' + dg + '</td>';
        html += '<td class="td-pts">' + eq.points + '</td>';
        html += '<td class="col-hide">' + renderForma(eq.form) + '</td>';
        html += '</tr>';
    }

    html += '</tbody></table>';

    // Leyenda
    html += '<div class="tabla-leyenda">';
    html += '<div class="leyenda-item"><div class="leyenda-dot" style="background:#4fc3f7"></div> Champions League</div>';
    if (liga !== 'CL') {
        html += '<div class="leyenda-item"><div class="leyenda-dot" style="background:#81c784"></div> Europa League</div>';
        html += '<div class="leyenda-item"><div class="leyenda-dot" style="background:#e94560"></div> Descenso</div>';
    } else {
        html += '<div class="leyenda-item"><div class="leyenda-dot" style="background:#81c784"></div> Playoff</div>';
        html += '<div class="leyenda-item"><div class="leyenda-dot" style="background:#e94560"></div> Eliminado</div>';
    }
    html += '</div>';

    container.innerHTML = html;
}

async function cargarClasificacion(liga) {
    var container = document.getElementById('tabla-container');
    container.innerHTML = '<div class="estado-loading">Cargando...</div>';
    try {
        var resp = await fetch('<%= request.getContextPath() %>/api/clasificaciones?liga=' + liga);
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var data = await resp.json();
        if (data.errorCode || data.message) {
            container.innerHTML = '<p class="estado-error">No se pudo cargar la clasificación: ' + (data.message || 'Error desconocido') + '</p>';
            return;
        }
        renderTabla(data);
    } catch (e) {
        container.innerHTML = '<p class="estado-error">Error al conectar: ' + e.message + '</p>';
    }
}

function cambiarLiga(liga, btn) {
    ligaActual = liga;
    document.querySelectorAll('.liga-tab').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    cargarClasificacion(liga);
}

cargarClasificacion('PL');
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
