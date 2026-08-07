package com.mycompany.futbolliveco.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utilidad para protección CSRF con el patrón Synchronizer Token.
 *
 * Uso:
 *   JSP:     <input type="hidden" name="_csrf" value="<%= CsrfUtil.getToken(request) %>">
 *   Servlet: CsrfUtil.validate(request);  // lanza CsrfException si no es válido
 */
public class CsrfUtil {

    private static final String SESSION_KEY = "_csrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();

    /** Devuelve el token CSRF de la sesión (lo crea si no existe). */
    public static String getToken(HttpServletRequest req) {
        HttpSession session = req.getSession();
        String token = (String) session.getAttribute(SESSION_KEY);
        if (token == null) {
            byte[] bytes = new byte[32];
            RANDOM.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(SESSION_KEY, token);
        }
        return token;
    }

    /**
     * Valida el token recibido en el request.
     * @throws CsrfException si el token es inválido o no existe.
     */
    public static void validate(HttpServletRequest req) throws CsrfException {
        HttpSession session = req.getSession(false);
        if (session == null) throw new CsrfException("Sesión inválida");

        String expected = (String) session.getAttribute(SESSION_KEY);
        String received = req.getParameter("_csrf");

        if (expected == null || received == null || !expected.equals(received)) {
            throw new CsrfException("Token CSRF inválido");
        }
    }

    public static class CsrfException extends Exception {
        public CsrfException(String msg) { super(msg); }
    }

    private CsrfUtil() {}
}
