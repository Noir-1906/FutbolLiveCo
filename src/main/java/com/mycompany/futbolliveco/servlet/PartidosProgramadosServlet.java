package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.util.ConfigManager;
import java.io.*;
import java.net.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/api/programados")
public class PartidosProgramadosServlet extends HttpServlet {

    private static final String API_KEY = ConfigManager.get("api.programados.key");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String league = req.getParameter("league");
        String date   = req.getParameter("date");

        if (league == null || date == null || league.isEmpty() || date.isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Faltan parametros league y date\"}");
            return;
        }

        String apiUrl = "https://api.football-data.org/v4/competitions/" +
                        URLEncoder.encode(league, "UTF-8") +
                        "/matches?dateFrom=" + date + "&dateTo=" + date;

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("X-Auth-Token", API_KEY);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
            ? conn.getInputStream()
            : conn.getErrorStream();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

        resp.setStatus(status);
        resp.getWriter().write(sb.toString());
    }
}