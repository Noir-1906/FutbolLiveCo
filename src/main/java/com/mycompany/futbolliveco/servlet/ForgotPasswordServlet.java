package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.service.PasswordResetService;
import com.mycompany.futbolliveco.service.UsuarioService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet para "Olvidé mi contraseña".
 *
 * GET  /api/forgot-password  → muestra el formulario
 * POST /api/forgot-password  → procesa la solicitud y redirige con mensaje
 */
@WebServlet("/api/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final PasswordResetService resetService = new PasswordResetService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Si ya está logueado, redirigir al home
        if (req.getSession(false) != null &&
            req.getSession(false).getAttribute("usuarioId") != null) {
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email = req.getParameter("email");

        // URL base para construir el enlace (scheme + host + context path)
        String baseUrl = req.getScheme() + "://" + req.getServerName() +
                         (req.getServerPort() == 80 || req.getServerPort() == 443
                             ? "" : ":" + req.getServerPort()) +
                         req.getContextPath();

        try {
            resetService.solicitarReset(email, baseUrl);
            // Siempre mostramos éxito (no revelar si el email existe)
            resp.sendRedirect(req.getContextPath() +
                "/api/forgot-password?status=enviado");

        } catch (UsuarioService.CampoObligatorioException e) {
            resp.sendRedirect(req.getContextPath() +
                "/api/forgot-password?error=" + encode(e.getMessage()));

        } catch (PasswordResetService.MailException e) {
            resp.sendRedirect(req.getContextPath() +
                "/api/forgot-password?error=" + encode("Error al enviar el correo. Inténtalo más tarde."));

        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() +
                "/api/forgot-password?error=" + encode("Error interno. Inténtalo más tarde."));
        }
    }

    private String encode(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (Exception e) { return s; }
    }
}
