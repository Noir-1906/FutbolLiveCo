package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.service.UsuarioService;
import com.mycompany.futbolliveco.service.UsuarioService.*;
import com.mycompany.futbolliveco.util.CsrfUtil;
import java.io.*;
import java.sql.SQLException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.json.JSONObject;

@WebServlet("/api/register")
public class RegisterServlet extends HttpServlet {

    private final UsuarioService usuarioService = new UsuarioService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JSONObject result = new JSONObject();

        // Validar CSRF
        try {
            CsrfUtil.validate(req);
        } catch (CsrfUtil.CsrfException e) {
            resp.setStatus(403);
            resp.getWriter().write(new JSONObject().put("ok", false).put("mensaje", "Solicitud inválida").toString());
            return;
        }

        try {
            usuarioService.registrar(
                req.getParameter("nombre"),
                req.getParameter("email"),
                req.getParameter("password")
            );

            result.put("ok",      true);
            result.put("mensaje", "Usuario registrado correctamente");

        } catch (CampoObligatorioException e) {
            resp.setStatus(400);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (EmailEnUsoException e) {
            resp.setStatus(409);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (PasswordInseguroException e) {
            resp.setStatus(400);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (SQLException e) {
            resp.setStatus(500);
            result.put("ok", false).put("mensaje", "Error del servidor");
        }

        resp.getWriter().write(result.toString());
    }
}
