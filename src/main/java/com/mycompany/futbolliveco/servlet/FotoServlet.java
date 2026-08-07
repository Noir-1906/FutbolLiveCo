package com.mycompany.futbolliveco.servlet;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

/**
 * Sirve las fotos de perfil almacenadas en disco fuera del WAR.
 * URL: /fotos/{userId}.{ext}
 */
@WebServlet("/fotos/*")
public class FotoServlet extends HttpServlet {

    private String fotosDir;

    @Override
    public void init() throws ServletException {
        String param = getServletContext().getInitParameter("fotos.dir");
        fotosDir = (param != null && !param.isEmpty())
            ? param
            : System.getProperty("user.home") + "/futbolliveco-fotos";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo(); // ej: /42.jpg
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Sanitizar: evitar path traversal
        String fileName = Paths.get(pathInfo).getFileName().toString();
        Path filePath = Paths.get(fotosDir, fileName);

        if (!Files.exists(filePath) || !Files.isRegularFile(filePath)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(fileName);
        if (contentType == null) contentType = "application/octet-stream";

        resp.setContentType(contentType);
        resp.setHeader("Cache-Control", "public, max-age=86400");
        Files.copy(filePath, resp.getOutputStream());
    }
}
