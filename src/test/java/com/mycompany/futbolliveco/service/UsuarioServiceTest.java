package com.mycompany.futbolliveco.service;

import com.mycompany.futbolliveco.dao.UsuarioDAO;
import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.service.UsuarioService;
import com.mycompany.futbolliveco.service.UsuarioService.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UsuarioServiceTest {

    private UsuarioDAO dao;
    private UsuarioService service;

    @BeforeEach
    void setUp() {
        dao = Mockito.mock(UsuarioDAO.class);
        service = new UsuarioService(dao);
    }

    // ── Registro ──────────────────────────────────────────────

    @Test
    void registro_campoNombreVacio_lanzaExcepcion() {
        assertThrows(CampoObligatorioException.class,
            () -> service.registrar("", "a@b.com", "contraseña123"));
    }

    @Test
    void registro_emailInvalido_lanzaExcepcion() {
        assertThrows(CampoObligatorioException.class,
            () -> service.registrar("Juan", "no-es-un-email", "contraseña123"));
    }

    @Test
    void registro_passwordCorta_lanzaExcepcion() {
        assertThrows(PasswordInseguroException.class,
            () -> service.registrar("Juan", "a@b.com", "1234"));
    }

    @Test
    void registro_emailDuplicado_lanzaExcepcion() throws Exception {
        when(dao.emailEnUso("a@b.com", 0)).thenReturn(true);
        assertThrows(EmailEnUsoException.class,
            () -> service.registrar("Juan", "a@b.com", "contraseña123"));
    }

    @Test
    void registro_exitoso_llamaDao() throws Exception {
        when(dao.emailEnUso("a@b.com", 0)).thenReturn(false);
        service.registrar("Juan", "a@b.com", "contraseña123");
        verify(dao).registrar(eq("Juan"), eq("a@b.com"), anyString());
    }

    // ── Login ────────────────────────────────────────────────

    @Test
    void login_usuarioNoExiste_lanzaCredencialesInvalidas() throws Exception {
        when(dao.buscarPorEmail("x@x.com")).thenReturn(null);
        assertThrows(CredencialesInvalidasException.class,
            () -> service.login("x@x.com", "cualquier"));
    }

    @Test
    void login_passwordIncorrecta_lanzaCredencialesInvalidas() throws Exception {
        Usuario u = new Usuario();
        u.setId(1);
        u.setEmail("a@b.com");
        u.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw("correcta", org.mindrot.jbcrypt.BCrypt.gensalt()));
        when(dao.buscarPorEmail("a@b.com")).thenReturn(u);
        assertThrows(CredencialesInvalidasException.class,
            () -> service.login("a@b.com", "incorrecta"));
    }

    @Test
    void login_exitoso_devuelveUsuario() throws Exception {
        Usuario u = new Usuario();
        u.setId(1);
        u.setNombre("Juan");
        u.setEmail("a@b.com");
        u.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw("contraseña123", org.mindrot.jbcrypt.BCrypt.gensalt()));
        when(dao.buscarPorEmail("a@b.com")).thenReturn(u);
        Usuario resultado = service.login("a@b.com", "contraseña123");
        assertEquals("Juan", resultado.getNombre());
    }
}
