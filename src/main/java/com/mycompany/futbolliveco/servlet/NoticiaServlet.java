package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.util.ConfigManager;
import java.io.*;
import java.net.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/api/noticias")
public class NoticiaServlet extends HttpServlet {

    private static final String API_KEY = ConfigManager.get("api.noticias.key");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String desde = LocalDate.now().minusDays(7)
            .format(DateTimeFormatter.ISO_LOCAL_DATE);

        // Query específica: fútbol europeo + selección Colombia + liga colombiana
        String query = "(\"Champions League\" OR \"Premier League\" OR \"La Liga\" OR \"Serie A\" OR \"Bundesliga\""
                     + " OR \"seleccion colombia\" OR \"liga colombiana\" OR \"Falcao\" OR \"James Rodriguez\""
                     + " OR \"goles futbol\" OR \"transfer futbol\" OR \"fichajes\")";

        String apiUrl = "https://newsapi.org/v2/everything"
            + "?q=" + URLEncoder.encode(query, "UTF-8")
            + "&language=es"
            + "&sortBy=publishedAt"
            + "&pageSize=40"
            + "&from=" + desde
            + "&apiKey=" + API_KEY;

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(8000);

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
