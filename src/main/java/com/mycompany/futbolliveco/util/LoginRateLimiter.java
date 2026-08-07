package com.mycompany.futbolliveco.util;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Rate limiter simple en memoria para el endpoint de login.
 * Bloquea una IP tras MAX_INTENTOS fallos en una ventana de VENTANA_MS.
 *
 * Nota: en un clúster multi-nodo esto debería externalizarse a Redis.
 */
public class LoginRateLimiter {

    private static final int  MAX_INTENTOS = 10;
    private static final long VENTANA_MS   = 15 * 60 * 1000L; // 15 minutos

    private static final ConcurrentHashMap<String, EntradaIP> mapa = new ConcurrentHashMap<>();

    public static boolean estaBloqueda(String ip) {
        EntradaIP entrada = mapa.get(ip);
        if (entrada == null) return false;
        if (System.currentTimeMillis() - entrada.inicio > VENTANA_MS) {
            mapa.remove(ip);
            return false;
        }
        return entrada.intentos.get() >= MAX_INTENTOS;
    }

    public static void registrarFallo(String ip) {
        mapa.compute(ip, (k, v) -> {
            if (v == null || System.currentTimeMillis() - v.inicio > VENTANA_MS) {
                return new EntradaIP();
            }
            v.intentos.incrementAndGet();
            return v;
        });
    }

    public static void resetear(String ip) {
        mapa.remove(ip);
    }

    private static class EntradaIP {
        final AtomicInteger intentos = new AtomicInteger(1);
        final long inicio = System.currentTimeMillis();
    }

    private LoginRateLimiter() {}
}
