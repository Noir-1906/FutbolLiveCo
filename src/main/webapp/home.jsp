<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FutbolLiveCo - Noticias</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/base.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/navbar.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/noticias.css">
</head>
<body>

<%@ include file="navbar.jsp" %>

<main>
    <h1 class="page-title">Noticias de Fútbol</h1>
    <p class="page-subtitle">Las últimas noticias del fútbol mundial</p>

    <div id="noticias-container">
        <div class="estado-loading">Cargando noticias...</div>
    </div>
</main>

<script>
function tiempoRelativo(fechaStr) {
    var diff = (Date.now() - new Date(fechaStr).getTime()) / 1000;
    if (diff < 3600)   return 'Hace ' + Math.floor(diff/60) + ' min';
    if (diff < 86400)  return 'Hace ' + Math.floor(diff/3600) + 'h';
    if (diff < 172800) return 'Ayer';
    return new Date(fechaStr).toLocaleDateString('es-CO', { day: '2-digit', month: 'short' });
}

async function cargarNoticias() {
    var container = document.getElementById('noticias-container');
    try {
        var resp = await fetch('<%= request.getContextPath() %>/api/noticias');
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var data = await resp.json();

        if (!data.articles || data.articles.length === 0) {
            container.innerHTML = '<p class="estado-empty">No hay noticias disponibles</p>';
            return;
        }

        var html = '<div class="noticias-grid">';
        var count = 0;
        for (var i = 0; i < data.articles.length; i++) {
            var n = data.articles[i];
            if (!n.title || n.title === '[Removed]') continue;

            html += '<a class="noticia-card" href="' + (n.url || '#') + '" target="_blank" rel="noopener">';
            if (n.urlToImage) {
                html += '<img class="noticia-img" src="' + n.urlToImage + '" alt="" loading="lazy">';
            } else {
                html += '<div class="noticia-img-placeholder"></div>';
            }
            html += '<div class="noticia-body">';
            html += '<div class="noticia-fuente">' + (n.source && n.source.name ? n.source.name : 'Desconocido') + '</div>';
            html += '<div class="noticia-titulo">' + n.title + '</div>';
            html += '<div class="noticia-fecha">' + tiempoRelativo(n.publishedAt) + '</div>';
            html += '</div></a>';
            count++;
        }
        html += '</div>';
        if (count === 0) {
            container.innerHTML = '<p class="estado-empty">No hay noticias disponibles</p>';
            return;
        }
        container.innerHTML = html;

    } catch (e) {
        container.innerHTML = '<p class="estado-error">No se pudieron cargar las noticias: ' + e.message + '</p>';
    }
}

cargarNoticias();
</script>
<%@ include file="/footer.jsp" %>

</body>
</html>
