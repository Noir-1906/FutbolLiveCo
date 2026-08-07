package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.service.UsuarioService;
import com.mycompany.futbolliveco.service.UsuarioService.*;
import com.mycompany.futbolliveco.util.CsrfUtil;
import com.mycompany.futbolliveco.util.LoginRateLimiter;
import java.io.*;
import java.sql.SQLException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONObject;

@WebServlet("/api/login")
public class LoginServlet extends HttpServlet {

    private final UsuarioService usuarioService = new UsuarioService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JSONObject result = new JSONObject();

        // 1. Validar CSRF
        try {
            CsrfUtil.validate(req);
        } catch (CsrfUtil.CsrfException e) {
            resp.setStatus(403);
            resp.getWriter().write(new JSONObject().put("ok", false).put("mensaje", "Solicitud inválida").toString());
            return;
        }

        // 2. Rate limiting por IP
        String ip = req.getRemoteAddr();
        if (LoginRateLimiter.estaBloqueda(ip)) {
            resp.setStatus(429);
            result.put("ok", false).put("mensaje", "Demasiados intentos fallidos. Inténtalo en 15 minutos.");
            resp.getWriter().write(result.toString());
            return;
        }

        try {
            Usuario usuario = usuarioService.login(
                req.getParameter("email"),
                req.getParameter("password")
            );

            // Login exitoso: resetear contador
            LoginRateLimiter.resetear(ip);

            // FIX: session fixation — invalidar sesión anterior y crear una nueva
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) oldSession.invalidate();
            HttpSession session = req.getSession(true);

            session.setAttribute("usuarioId",     usuario.getId());
            session.setAttribute("usuarioNombre", usuario.getNombre());

            result.put("ok",      true);
            result.put("mensaje", "Login correcto");
            result.put("id",      usuario.getId());
            result.put("nombre",  usuario.getNombre());

        } catch (CampoObligatorioException e) {
            resp.setStatus(400);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (CredencialesInvalidasException e) {
            LoginRateLimiter.registrarFallo(ip);
            resp.setStatus(401);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (SQLException e) {
            resp.setStatus(500);
            result.put("ok", false).put("mensaje", "Error del servidor");
        }

        resp.getWriter().write(result.toString());
    }
}
