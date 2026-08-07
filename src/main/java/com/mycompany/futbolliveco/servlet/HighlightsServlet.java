package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.util.ConfigManager;
import java.io.*;
import java.net.*;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/api/highlights")
public class HighlightsServlet extends HttpServlet {

    private static final String API_KEY  = ConfigManager.get("api.highlights.key");
    private static final String BASE_URL = "https://www.googleapis.com/youtube/v3/search";

    // 5 queries variadas para la carga inicial — cubre las ligas principales
    private static final String[] DEFAULT_QUERIES = {
        "Premier League goals highlights 2025",
        "La Liga Champions League goals highlights 2025",
        "Bundesliga Serie A goals highlights 2025",
        "best goals football week 2025",
        "Mbappe Haaland Vinicius goals 2025"
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String q = req.getParameter("q");
        boolean esDefault = (q == null || q.trim().isEmpty());

        // 30 días atrás — más rango, más resultados
        String publishedAfter = Instant.now()
            .minus(30, ChronoUnit.DAYS)
            .toString();

        if (esDefault) {
            StringBuilder items = new StringBuilder();
            items.append("{\"items\":[");
            boolean primero = true;

            for (String query : DEFAULT_QUERIES) {
                String resultado = buscar(query, publishedAfter, 6);
                String extracted = extraerItems(resultado);
                if (!extracted.isEmpty()) {
                    if (!primero) items.append(",");
                    items.append(extracted);
                    primero = false;
                }
            }
            items.append("]}");
            resp.getWriter().write(items.toString());
        } else {
            String resultado = buscar(q.trim(), publishedAfter, 20);
            resp.getWriter().write(resultado);
        }
    }

    private String buscar(String q, String publishedAfter, int maxResults) throws IOException {
        String apiUrl = BASE_URL
            + "?part=snippet"
            + "&type=video"
            + "&order=relevance"
            + "&maxResults=" + maxResults
            + "&publishedAfter=" + URLEncoder.encode(publishedAfter, "UTF-8")
            + "&q=" + URLEncoder.encode(q, "UTF-8")
            + "&key=" + API_KEY;

        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(8000);
        conn.setReadTimeout(10000);

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
            ? conn.getInputStream() : conn.getErrorStream();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        return sb.toString();
    }

    private String extraerItems(String json) {
        int start = json.indexOf("\"items\":[");
        if (start == -1) return "";
        start = json.indexOf("[", start) + 1;
        int depth = 1;
        int i = start;
        while (i < json.length() && depth > 0) {
            char c = json.charAt(i);
            if (c == '[') depth++;
            else if (c == ']') depth--;
            i++;
        }
        String items = json.substring(start, i - 1).trim();
        return items;
    }
}
