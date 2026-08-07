package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.util.ConfigManager;
import java.io.*;
import java.net.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/api/clasificaciones")
public class ClasificacionesServlet extends HttpServlet {

    private static final String API_KEY = ConfigManager.get("api.programados.key");
    private static final String BASE_URL = "https://api.football-data.org/v4/competitions/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // Liga a consultar: PL, PD, BL1, SA, FL1, CL
        String liga = req.getParameter("liga");
        if (liga == null || liga.trim().isEmpty()) liga = "PL";

        // Sanitizar: solo letras
        liga = liga.replaceAll("[^a-zA-Z0-9]", "").toUpperCase();

        String apiUrl = BASE_URL + liga + "/standings";

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("X-Auth-Token", API_KEY);
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
