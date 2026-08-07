package com.mycompany.futbolliveco.util;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class LoginRateLimiterTest {

    @BeforeEach
    void limpiar() {
        // Resetear la IP antes de cada prueba para que no se contaminen entre sí
        LoginRateLimiter.resetear("1.2.3.4");
    }

    // Prueba 1: una IP nueva no está bloqueada
    @Test
    void ipNueva_noEstaBloqueada() {
        assertFalse(LoginRateLimiter.estaBloqueda("1.2.3.4"));
    }

    // Prueba 2: con 9 fallos aún no se bloquea
    @Test
    void nueveFallos_noBloquea() {
        for (int i = 0; i < 9; i++) {
            LoginRateLimiter.registrarFallo("1.2.3.4");
        }
        assertFalse(LoginRateLimiter.estaBloqueda("1.2.3.4"));
    }

    // Prueba 3: al llegar a 10 fallos, se bloquea
    @Test
    void diezFallos_bloqueaIP() {
        for (int i = 0; i < 10; i++) {
            LoginRateLimiter.registrarFallo("1.2.3.4");
        }
        assertTrue(LoginRateLimiter.estaBloqueda("1.2.3.4"));
    }

    // Prueba 4: después de resetear, la IP vuelve a estar libre
    @Test
    void resetear_desbloqueaIP() {
        for (int i = 0; i < 10; i++) {
            LoginRateLimiter.registrarFallo("1.2.3.4");
        }
        LoginRateLimiter.resetear("1.2.3.4");
        assertFalse(LoginRateLimiter.estaBloqueda("1.2.3.4"));
    }

    // Prueba 5: IPs diferentes se cuentan por separado
    @Test
    void diferentesIPs_seCuentanPorSeparado() {
        LoginRateLimiter.resetear("9.9.9.9");
        for (int i = 0; i < 10; i++) {
            LoginRateLimiter.registrarFallo("1.2.3.4");
        }
        assertFalse(LoginRateLimiter.estaBloqueda("9.9.9.9"));
        LoginRateLimiter.resetear("9.9.9.9");
    }
}
