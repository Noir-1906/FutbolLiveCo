<%@page contentType="text/html" pageEncoding="UTF-8" isELIgnored="true"%>
<%
    String footerCtx = request.getContextPath();
    int footerYear = java.time.Year.now().getValue();
%>
<footer class="site-footer">
    <div class="site-footer-inner">
        <div class="site-footer-links">
            <a href="<%= footerCtx %>/legal/terminos.jsp">Términos y Condiciones</a>
            <a href="<%= footerCtx %>/legal/privacidad.jsp">Política de Privacidad</a>
            <a href="<%= footerCtx %>/legal/derechos-autor.jsp">Derechos de Autor</a>
            <a href="<%= footerCtx %>/legal/contacto.jsp">Contacto</a>
        </div>
        <div class="site-footer-copy">
            &copy; <%= footerYear %> FutbolLiveCo. Todos los derechos reservados.
        </div>
    </div>
</footer>
