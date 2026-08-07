package com.mycompany.futbolliveco.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Optimización de rendimiento: indica al navegador que puede guardar en
 * caché los archivos estáticos (CSS, JS, imágenes, fuentes) durante 7 días,
 * en vez de volver a descargarlos en cada visita a la página.
 *
 * Esto reduce el número de peticiones al servidor y acelera la carga
 * en visitas repetidas del mismo usuario.
 */
@WebFilter(urlPatterns = {"/css/*", "/js/*", "/img/*", "/images/*", "/fotos/*"})
public class CacheControlFilter implements Filter {

    private static final long SEVEN_DAYS_SECONDS = 60L * 60 * 24 * 7;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (response instanceof HttpServletResponse httpResp
                && request instanceof HttpServletRequest) {
            httpResp.setHeader("Cache-Control", "public, max-age=" + SEVEN_DAYS_SECONDS);
        }
        chain.doFilter(request, response);
    }
}
