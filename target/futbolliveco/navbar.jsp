<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    boolean navLogueado = session.getAttribute("usuarioId") != null;
    String navNombre    = navLogueado ? (String) session.getAttribute("usuarioNombre") : null;
    String navPage      = request.getRequestURI();
    String ctx          = request.getContextPath();
%>

<header class="navbar">
    <a href="<%= ctx %>/home.jsp" class="navbar-brand">
        <span class="brand-text">FutbolLive<span class="brand-co">CO</span></span>
    </a>

    <nav class="navbar-links">
        <a href="<%= ctx %>/home.jsp"            class="nav-link <%= navPage.endsWith("home.jsp")            ? "active" : "" %>">Noticias</a>
        <a href="<%= ctx %>/live.jsp"            class="nav-link <%= navPage.endsWith("live.jsp")            ? "active" : "" %>">En Vivo</a>
        <a href="<%= ctx %>/programados.jsp"     class="nav-link <%= navPage.endsWith("programados.jsp")     ? "active" : "" %>">Programados</a>
        <a href="<%= ctx %>/clasificaciones.jsp" class="nav-link <%= navPage.endsWith("clasificaciones.jsp") ? "active" : "" %>">Clasificaciones</a>
        <a href="<%= ctx %>/jugadores.jsp"       class="nav-link <%= navPage.endsWith("jugadores.jsp")       ? "active" : "" %>">Jugadores</a>
        <a href="<%= ctx %>/highlights.jsp"      class="nav-link <%= navPage.endsWith("highlights.jsp")      ? "active" : "" %>">Highlights</a>
    </nav>

    <div class="navbar-user">
        <% if (navLogueado) { %>
            <a href="<%= ctx %>/perfil.jsp" class="nav-user-btn"><%= navNombre %></a>
            <a href="<%= ctx %>/api/logout" class="nav-logout-btn">Salir</a>
        <% } else { %>
            <a href="<%= ctx %>/login.jsp"    class="nav-auth-btn secondary">Iniciar sesión</a>
            <a href="<%= ctx %>/register.jsp" class="nav-auth-btn primary">Registrarse</a>
        <% } %>
    </div>

    <button class="navbar-toggle" onclick="toggleMenu()" aria-label="Menú">&#9776;</button>
</header>

<script>
function toggleMenu() {
    document.querySelector('.navbar-links').classList.toggle('open');
    document.querySelector('.navbar-user').classList.toggle('open');
}
</script>
