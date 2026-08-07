<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    if (session.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp?redir=highlights.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Highlights</title>
    <link rel="stylesheet" href="css/base.css">
    <link rel="stylesheet" href="css/navbar.css">
    <link rel="stylesheet" href="css/highlights.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<div class="highlights-header">
    <h1>Highlights</h1>
    <p>Los mejores goles y resúmenes del fútbol mundial</p>
    <div class="highlights-busqueda">
        <input type="text" id="input-busqueda" placeholder="Buscar: 'goles Real Madrid', 'highlights Premier League'..."
               onkeydown="if(event.key==='Enter') buscarHighlights()">
        <button class="btn-buscar-hl" onclick="buscarHighlights()">Buscar</button>
    </div>
    <div class="quick-tags">
        <span class="quick-tag" onclick="buscarTag('Real Madrid Barcelona highlights goles')">Real Madrid vs Barça</span>
        <span class="quick-tag" onclick="buscarTag('Champions League highlights goles semana')">Champions League</span>
        <span class="quick-tag" onclick="buscarTag('Premier League highlights mejores goles')">Premier League</span>
        <span class="quick-tag" onclick="buscarTag('La Liga highlights resumen jornada')">La Liga</span>
        <span class="quick-tag" onclick="buscarTag('mejores goles semana futbol world')">Mejores goles</span>
        <span class="quick-tag" onclick="buscarTag('Mbappe Haaland Vinicius goles highlights')">Estrellas</span>
        <span class="quick-tag" onclick="buscarTag('Serie A highlights resumen goles')">Serie A</span>
    </div>
</div>

<div id="highlights-grid">
    <div class="estado-loading">Cargando highlights...</div>
</div>

<!-- Modal de reproducción -->
<div class="modal-overlay" id="modal" onclick="cerrarModal(event)">
    <div class="modal-content">
        <button class="modal-close" onclick="cerrarModal()">&#10005;</button>
        <div class="modal-iframe-wrap">
            <iframe id="modal-iframe" src="" allow="autoplay; encrypted-media" allowfullscreen></iframe>
        </div>
    </div>
</div>

<script>
function tiempoRelativo(fechaStr) {
    var diff = (Date.now() - new Date(fechaStr).getTime()) / 1000;
    if (diff < 3600)   return 'Hace ' + Math.floor(diff/60) + ' min';
    if (diff < 86400)  return 'Hace ' + Math.floor(diff/3600) + 'h';
    if (diff < 172800) return 'Ayer';
    return new Date(fechaStr).toLocaleDateString('es-CO', { day: '2-digit', month: 'short' });
}

function buscarTag(termino) {
    document.getElementById('input-busqueda').value = termino;
    buscarHighlights();
}

async function buscarHighlights() {
    var q = document.getElementById('input-busqueda').value.trim();
    if (!q) q = 'highlights futbol goles semana Real Madrid Barcelona';

    var grid = document.getElementById('highlights-grid');
    grid.innerHTML = '<div class="estado-loading">Buscando...</div>';

    try {
        var resp = await fetch('<%= request.getContextPath() %>/api/highlights?q=' + encodeURIComponent(q));
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var data = await resp.json();

        if (!data.items || data.items.length === 0) {
            grid.innerHTML = '<p class="estado-empty">No se encontraron videos para esa búsqueda</p>';
            return;
        }

        var html = '';
        for (var i = 0; i < data.items.length; i++) {
            var item    = data.items[i];
            var videoId = item.id && item.id.videoId ? item.id.videoId : null;
            if (!videoId) continue;
            var snippet = item.snippet;
            var thumb   = snippet.thumbnails && snippet.thumbnails.medium
                        ? snippet.thumbnails.medium.url
                        : (snippet.thumbnails && snippet.thumbnails.default ? snippet.thumbnails.default.url : '');
            var titulo   = snippet.title || '';
            var canal    = snippet.channelTitle || '';
            var fecha    = snippet.publishedAt ? tiempoRelativo(snippet.publishedAt) : '';

            html += '<div class="video-card" onclick="abrirVideo(\'' + videoId + '\')">';
            html += '<div class="video-thumbnail-wrap">';
            if (thumb) html += '<img class="video-thumbnail" src="' + thumb + '" alt="" loading="lazy">';
            html += '<div class="play-overlay">&#9654;</div>';
            html += '</div>';
            html += '<div class="video-info">';
            html += '<div class="video-channel">' + canal + '</div>';
            html += '<div class="video-title">' + titulo + '</div>';
            html += '<div class="video-meta">' + fecha + '</div>';
            html += '</div></div>';
        }
        grid.innerHTML = html;

    } catch (e) {
        grid.innerHTML = '<p class="estado-error">No se pudieron cargar los highlights: ' + e.message + '</p>';
    }
}

function abrirVideo(videoId) {
    document.getElementById('modal-iframe').src =
        'https://www.youtube.com/embed/' + videoId + '?autoplay=1&rel=0';
    document.getElementById('modal').classList.add('open');
    document.body.style.overflow = 'hidden';
}

function cerrarModal(event) {
    if (event && event.target !== document.getElementById('modal') &&
        !event.target.classList.contains('modal-close')) return;
    document.getElementById('modal-iframe').src = '';
    document.getElementById('modal').classList.remove('open');
    document.body.style.overflow = '';
}

// Cargar highlights populares al entrar
buscarHighlights();
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
