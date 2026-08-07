package com.mycompany.futbolliveco.servlet;

import java.io.*;
import java.net.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/api/jugadores")
public class JugadoresServlet extends HttpServlet {

    // TheSportsDB — gratuita, sin API key, no requiere registro
    private static final String BASE_URL = "https://www.thesportsdb.com/api/v1/json/3/searchplayers.php";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String nombre = req.getParameter("nombre");
        if (nombre == null || nombre.trim().isEmpty()) {
            resp.getWriter().write("{\"player\":null,\"error\":\"Nombre requerido\"}");
            return;
        }

        String apiUrl = BASE_URL + "?p=" + URLEncoder.encode(nombre.trim(), "UTF-8");

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(10000);

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
            ? conn.getInputStream() : conn.getErrorStream();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            resp.setStatus(status);
            resp.getWriter().write(sb.toString());
        }
    }
}
