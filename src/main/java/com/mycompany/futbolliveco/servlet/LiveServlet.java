package com.mycompany.futbolliveco.servlet;

import com.mycompany.futbolliveco.util.ConfigManager;
import java.io.*;
import java.net.*;
import java.util.Set;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/api/live")
public class LiveServlet extends HttpServlet {

    private static final String API_KEY = ConfigManager.get("api.live.key");
    private static final String API_URL = "https://v3.football.api-sports.io/fixtures?live=39-140-78-135-61-2-3-848-239";

    // Caché compartida: 1 sola llamada a la API cada 60 segundos para TODOS los usuarios
    private static final long CACHE_DURACION_MS = 60_000; // 60 segundos
    private static String cacheJson       = null;
    private static long   cacheTimestamp  = 0;
    private static final Object LOCK      = new Object();

    // Lista blanca de orígenes permitidos
    private static final Set<String> ORIGENES_PERMITIDOS = Set.of(
        "http://localhost:8080",
        "https://futbolliveco.co"
    );

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // CORS seguro: solo orígenes en lista blanca
        String origin = req.getHeader("Origin");
        if (origin != null && ORIGENES_PERMITIDOS.contains(origin)) {
            resp.setHeader("Access-Control-Allow-Origin", origin);
            resp.setHeader("Vary", "Origin");
        }

        String resultado;

        synchronized (LOCK) {
            long ahora = System.currentTimeMillis();
            boolean cacheVigente = cacheJson != null && (ahora - cacheTimestamp) < CACHE_DURACION_MS;

            if (cacheVigente) {
                // Devolver caché — no se consume ningún punto de la API
                resultado = cacheJson;
            } else {
                // Caché expirada o vacía — llamar a la API (1 punto)
                resultado = llamarApi();
                cacheJson      = resultado;
                cacheTimestamp = ahora;
            }
        }

        resp.setStatus(200);
        resp.getWriter().write(resultado);
    }

    private String llamarApi() throws IOException {
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("x-apisports-key", API_KEY);
        conn.setConnectTimeout(10_000);
        conn.setReadTimeout(15_000);

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
            ? conn.getInputStream()
            : conn.getErrorStream();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }
}
