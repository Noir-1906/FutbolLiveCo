package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.service.PasswordResetService;
import com.mycompany.futbolliveco.service.UsuarioService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet para restablecer la contraseña a partir del token recibido por email.
 *
 * GET  /api/reset-password?token=XXX → valida el token, muestra el formulario
 * POST /api/reset-password           → aplica la nueva contraseña
 */
@WebServlet("/api/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private final PasswordResetService resetService = new PasswordResetService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");

        if (token == null || token.trim().isEmpty()) {
            req.setAttribute("tokenError", "Enlace inválido. Por favor solicita uno nuevo.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        try {
            Usuario usuario = resetService.validarToken(token);
            if (usuario == null) {
                req.setAttribute("tokenError",
                    "Este enlace ha expirado o ya fue utilizado. Solicita uno nuevo.");
            } else {
                req.setAttribute("tokenValido", true);
                req.setAttribute("token", token);
            }
        } catch (SQLException e) {
            req.setAttribute("tokenError", "Error interno. Inténtalo más tarde.");
        }

        req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String token    = req.getParameter("token");
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirm");

        // Validación del lado servidor: las dos contraseñas deben coincidir
        if (password == null || !password.equals(confirm)) {
            req.setAttribute("tokenValido", true);
            req.setAttribute("token", token);
            req.setAttribute("formError", "Las contraseñas no coinciden.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        try {
            resetService.resetearPassword(token, password);
            // Redirigir al login con mensaje de éxito
            resp.sendRedirect(req.getContextPath() +
                "/login.jsp?msg=" + encode("¡Contraseña actualizada! Ya puedes iniciar sesión."));

        } catch (PasswordResetService.TokenInvalidoException e) {
            req.setAttribute("tokenError", e.getMessage());
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);

        } catch (UsuarioService.CampoObligatorioException |
                 UsuarioService.PasswordInseguroException e) {
            req.setAttribute("tokenValido", true);
            req.setAttribute("token", token);
            req.setAttribute("formError", e.getMessage());
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("tokenValido", true);
            req.setAttribute("token", token);
            req.setAttribute("formError", "Error interno. Inténtalo más tarde.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        }
    }

    private String encode(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (Exception e) { return s; }
    }
}
