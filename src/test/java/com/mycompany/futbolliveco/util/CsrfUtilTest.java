package com.mycompany.futbolliveco.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CsrfUtilTest {

    // Prueba 1: se genera un token y se guarda en la sesión
    @Test
    void getToken_creaTokenSiNoExiste() {
        HttpSession session = mock(HttpSession.class);
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getSession()).thenReturn(session);
        when(session.getAttribute("_csrfToken")).thenReturn(null);

        String token = CsrfUtil.getToken(req);

        assertNotNull(token);
        assertFalse(token.isEmpty());
        verify(session).setAttribute(eq("_csrfToken"), anyString());
    }

    // Prueba 2: si ya hay token en sesión, lo reutiliza
    @Test
    void getToken_reutilizaTokenExistente() {
        HttpSession session = mock(HttpSession.class);
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getSession()).thenReturn(session);
        when(session.getAttribute("_csrfToken")).thenReturn("token-existente");

        String token = CsrfUtil.getToken(req);

        assertEquals("token-existente", token);
    }

    // Prueba 3: validate lanza excepción si no hay sesión
    @Test
    void validate_sinSesion_lanzaExcepcion() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getSession(false)).thenReturn(null);

        assertThrows(CsrfUtil.CsrfException.class, () -> CsrfUtil.validate(req));
    }

    // Prueba 4: validate lanza excepción si el token no coincide
    @Test
    void validate_tokenIncorrecto_lanzaExcepcion() {
        HttpSession session = mock(HttpSession.class);
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("_csrfToken")).thenReturn("token-correcto");
        when(req.getParameter("_csrf")).thenReturn("token-malo");

        assertThrows(CsrfUtil.CsrfException.class, () -> CsrfUtil.validate(req));
    }

    // Prueba 5: validate pasa si el token coincide exactamente
    @Test
    void validate_tokenCorrecto_noLanzaExcepcion() {
        HttpSession session = mock(HttpSession.class);
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("_csrfToken")).thenReturn("token-valido");
        when(req.getParameter("_csrf")).thenReturn("token-valido");

        assertDoesNotThrow(() -> CsrfUtil.validate(req));
    }
}
