package com.mycompany.futbolliveco.service;

import com.mycompany.futbolliveco.dao.PasswordResetDAO;
import com.mycompany.futbolliveco.dao.UsuarioDAO;
import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.util.ConfigManager;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Properties;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * Lógica de negocio para recuperación de contraseña por email.
 *
 * Flujo:
 *  1. solicitarReset(email, baseUrl) → genera token, lo guarda en BD, envía correo
 *  2. validarToken(token)            → comprueba que existe y no expiró
 *  3. resetearPassword(token, nueva) → aplica nueva contraseña e invalida el token
 */
public class PasswordResetService {

    /** Tiempo de vida del enlace de reset (en horas). */
    private static final int TOKEN_HORAS = 1;

    private final PasswordResetDAO resetDAO;
    private final UsuarioDAO       usuarioDAO;

    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    public PasswordResetService() {
        this.resetDAO   = new PasswordResetDAO();
        this.usuarioDAO = new UsuarioDAO();
    }

    // ── API pública ──────────────────────────────────────────

    /**
     * Genera un token de reset y envía el correo al usuario.
     *
     * Para no revelar qué emails existen en el sistema, siempre responde
     * de la misma manera (sin lanzar excepción si el email no existe).
     *
     * @param email   Email del usuario
     * @param baseUrl URL base de la app, ej: "https://futbolliveco.com/futbolliveco"
     */
    public void solicitarReset(String email, String baseUrl)
            throws UsuarioService.CampoObligatorioException, SQLException, MailException {

        if (email == null || email.trim().isEmpty()) {
            throw new UsuarioService.CampoObligatorioException("El email es obligatorio");
        }
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            throw new UsuarioService.CampoObligatorioException("El formato del email no es válido");
        }

        // Generar token seguro (UUID sin guiones = 32 hex chars, usamos dos = 64)
        String token = UUID.randomUUID().toString().replace("-", "")
                     + UUID.randomUUID().toString().replace("-", "");

        Timestamp expiry = Timestamp.from(Instant.now().plus(TOKEN_HORAS, ChronoUnit.HOURS));

        // Si el email no existe, guardarToken devuelve false → no hacemos nada visible
        boolean guardado = resetDAO.guardarToken(email.trim(), token, expiry);

        if (guardado) {
            String enlace = baseUrl + "/api/reset-password?token=" + token;
            enviarCorreo(email.trim(), enlace);
        }
        // Si el email no existe no lanzamos excepción (anti-enumeración de usuarios)
    }

    /**
     * Comprueba si el token es válido y no ha expirado.
     * @return Usuario asociado al token, o null si inválido/expirado.
     */
    public Usuario validarToken(String token) throws SQLException {
        if (token == null || token.trim().isEmpty()) return null;
        return resetDAO.buscarPorToken(token.trim());
    }

    /**
     * Cambia la contraseña usando el token y lo invalida.
     */
    public void resetearPassword(String token, String nuevaPassword)
            throws UsuarioService.CampoObligatorioException,
                   UsuarioService.PasswordInseguroException,
                   TokenInvalidoException,
                   SQLException {

        if (token == null || token.trim().isEmpty()) {
            throw new TokenInvalidoException("Token inválido o expirado");
        }

        validarPassword(nuevaPassword);

        Usuario usuario = resetDAO.buscarPorToken(token.trim());
        if (usuario == null) {
            throw new TokenInvalidoException("El enlace ha expirado o ya fue usado");
        }

        String hash = BCrypt.hashpw(nuevaPassword, BCrypt.gensalt());
        usuarioDAO.actualizarPassword(usuario.getId(), hash);
        resetDAO.invalidarToken(usuario.getId());
    }

    // ── Email ────────────────────────────────────────────────

    private void enviarCorreo(String destinatario, String enlace) throws MailException {
        String host   = ConfigManager.get("mail.smtp.host",     "smtp.gmail.com");
        String port   = ConfigManager.get("mail.smtp.port",     "587");
        String user   = ConfigManager.get("mail.smtp.user",     "");
        String pass   = ConfigManager.get("mail.smtp.password", "");
        String from   = ConfigManager.get("mail.from",          user);

        if (user.isEmpty() || pass.isEmpty()) {
            throw new MailException("El servidor de correo no está configurado. " +
                                    "Revisa mail.smtp.user y mail.smtp.password en config.properties");
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            host);
        props.put("mail.smtp.port",            port);
        props.put("mail.smtp.ssl.protocols",   "TLSv1.2 TLSv1.3");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(from, "FutbolLiveCo"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            msg.setSubject("⚽ Recupera tu contraseña – FutbolLiveCo");

            String cuerpo = construirCuerpoEmail(enlace);
            msg.setContent(cuerpo, "text/html; charset=UTF-8");

            Transport.send(msg);

        } catch (Exception e) {
            throw new MailException("No se pudo enviar el correo: " + e.getMessage());
        }
    }

    private String construirCuerpoEmail(String enlace) {
        return "<!DOCTYPE html><html lang='es'><body style='" +
               "margin:0;padding:0;background:#0f1117;font-family:Arial,sans-serif;'>" +
               "<div style='max-width:520px;margin:40px auto;background:#1a1d27;" +
               "border-radius:12px;overflow:hidden;border:1px solid #2a2d3e;'>" +
               "<div style='background:linear-gradient(90deg,#e94560,#0f3460);" +
               "padding:24px;text-align:center;'>" +
               "<h1 style='color:#fff;margin:0;font-size:1.6rem;'>⚽ FutbolLiveCo</h1></div>" +
               "<div style='padding:36px 32px;'>" +
               "<h2 style='color:#ffffff;font-size:1.2rem;margin-top:0;'>" +
               "Recupera tu contraseña</h2>" +
               "<p style='color:#aaaaaa;font-size:0.95rem;line-height:1.6;'>" +
               "Recibimos una solicitud para restablecer la contraseña de tu cuenta. " +
               "Haz clic en el botón de abajo para crear una nueva contraseña.</p>" +
               "<p style='color:#888;font-size:0.85rem;'>" +
               "Este enlace es válido por <strong style='color:#e94560;'>1 hora</strong>.</p>" +
               "<div style='text-align:center;margin:32px 0;'>" +
               "<a href='" + enlace + "' style='background:#e94560;color:#fff;" +
               "padding:14px 36px;border-radius:8px;text-decoration:none;" +
               "font-weight:700;font-size:1rem;display:inline-block;'>" +
               "Restablecer contraseña</a></div>" +
               "<p style='color:#666;font-size:0.8rem;word-break:break-all;'>" +
               "Si el botón no funciona, copia este enlace en tu navegador:<br>" +
               "<span style='color:#aaa;'>" + enlace + "</span></p>" +
               "<hr style='border:none;border-top:1px solid #2a2d3e;margin:28px 0;'>" +
               "<p style='color:#555;font-size:0.78rem;text-align:center;'>" +
               "Si no solicitaste esto, ignora este correo. Tu cuenta sigue segura.</p>" +
               "</div></div></body></html>";
    }

    // ── Validaciones ─────────────────────────────────────────

    private void validarPassword(String password)
            throws UsuarioService.CampoObligatorioException, UsuarioService.PasswordInseguroException {
        if (password == null || password.trim().isEmpty()) {
            throw new UsuarioService.CampoObligatorioException("La contraseña es obligatoria");
        }
        if (password.length() < 8) {
            throw new UsuarioService.PasswordInseguroException(
                "La contraseña debe tener al menos 8 caracteres");
        }
    }

    // ── Excepciones ──────────────────────────────────────────

    public static class TokenInvalidoException extends Exception {
        public TokenInvalidoException(String msg) { super(msg); }
    }

    public static class MailException extends Exception {
        public MailException(String msg) { super(msg); }
    }
}
