package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.service.UsuarioService;
import com.mycompany.futbolliveco.service.UsuarioService.*;
import com.mycompany.futbolliveco.util.CsrfUtil;
import java.io.*;
import java.sql.SQLException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import org.json.JSONObject;

@WebServlet("/api/perfil")
@MultipartConfig(maxFileSize = 2 * 1024 * 1024)  // 2 MB máximo
public class PerfilServlet extends HttpServlet {

    private final UsuarioService usuarioService = new UsuarioService();

    /** Directorio donde se almacenan las fotos de perfil en disco. */
    private String fotosDir;

    @Override
    public void init() throws ServletException {
        // Configurable vía parámetro de contexto en web.xml; si no, usa home del sistema
        String param = getServletContext().getInitParameter("fotos.dir");
        fotosDir = (param != null && !param.isEmpty())
            ? param
            : System.getProperty("user.home") + "/futbolliveco-fotos";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Integer userId = getUsuarioId(req);
        if (userId == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"ok\":false,\"mensaje\":\"No autenticado\"}");
            return;
        }

        JSONObject result = new JSONObject();
        try {
            Usuario usuario = usuarioService.obtenerPorId(userId);

            result.put("ok",     true);
            result.put("id",     usuario.getId());
            result.put("nombre", usuario.getNombre());
            result.put("email",  usuario.getEmail());
            // foto_ruta es una ruta como "/fotos/42.jpg" o null
            result.put("foto",   usuario.getFoto() != null ? usuario.getFoto() : "");

        } catch (UsuarioNoEncontradoException e) {
            resp.setStatus(404);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (SQLException e) {
            resp.setStatus(500);
            result.put("ok", false).put("mensaje", "Error del servidor");
        }

        resp.getWriter().write(result.toString());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Integer userId = getUsuarioId(req);
        if (userId == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"ok\":false,\"mensaje\":\"No autenticado\"}");
            return;
        }

        // Validar CSRF (para multipart el token viene como parte del form)
        try {
            CsrfUtil.validate(req);
        } catch (CsrfUtil.CsrfException e) {
            resp.setStatus(403);
            resp.getWriter().write(new JSONObject().put("ok", false).put("mensaje", "Solicitud inválida").toString());
            return;
        }

        String accion = req.getParameter("accion");
        JSONObject result = new JSONObject();

        try {
            if ("datos".equals(accion)) {
                usuarioService.actualizarDatos(
                    userId,
                    req.getParameter("nombre"),
                    req.getParameter("email")
                );
                String nuevoNombre = req.getParameter("nombre");
                req.getSession().setAttribute("usuarioNombre", nuevoNombre);
                result.put("ok",      true)
                      .put("mensaje", "Datos actualizados correctamente")
                      .put("nombre",  nuevoNombre);

            } else if ("password".equals(accion)) {
                usuarioService.cambiarPassword(
                    userId,
                    req.getParameter("actual"),
                    req.getParameter("nueva")
                );
                result.put("ok", true).put("mensaje", "Contraseña actualizada correctamente");

            } else if ("foto".equals(accion)) {
                Part filePart   = req.getPart("foto");
                byte[] bytes    = filePart != null ? filePart.getInputStream().readAllBytes() : null;
                String mimeType = filePart != null ? filePart.getContentType() : null;

                String rutaFoto = usuarioService.actualizarFoto(userId, mimeType, bytes, fotosDir);
                result.put("ok",      true)
                      .put("mensaje", "Foto actualizada correctamente")
                      .put("foto",    rutaFoto);

            } else if ("eliminar-foto".equals(accion)) {
                usuarioService.eliminarFoto(userId, fotosDir);
                result.put("ok",      true)
                      .put("mensaje", "Foto eliminada correctamente")
                      .put("foto",    "");

            } else {
                resp.setStatus(400);
                result.put("ok", false).put("mensaje", "Acción no válida");
            }

        } catch (CampoObligatorioException e) {
            resp.setStatus(400);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (EmailEnUsoException e) {
            resp.setStatus(409);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (CredencialesInvalidasException e) {
            resp.setStatus(401);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (PasswordInseguroException e) {
            resp.setStatus(400);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (TipoArchivoInvalidoException e) {
            resp.setStatus(400);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (UsuarioNoEncontradoException e) {
            resp.setStatus(404);
            result.put("ok", false).put("mensaje", e.getMessage());
        } catch (SQLException e) {
            resp.setStatus(500);
            result.put("ok", false).put("mensaje", "Error del servidor");
        }

        resp.getWriter().write(result.toString());
    }

    private Integer getUsuarioId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (Integer) session.getAttribute("usuarioId");
    }
}
