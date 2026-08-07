package com.mycompany.futbolliveco.service;

import com.mycompany.futbolliveco.dao.UsuarioDAO;
import com.mycompany.futbolliveco.model.Usuario;
import org.mindrot.jbcrypt.BCrypt;

import java.io.*;
import java.nio.file.*;
import java.sql.SQLException;
import java.util.regex.Pattern;

public class UsuarioService {

    private final UsuarioDAO dao;

    /** Directorio base donde se guardan las fotos de perfil (configurable). */
    private static final String FOTOS_DIR_PROPERTY = "fotos.dir";
    private static final String FOTOS_DIR_DEFAULT  = System.getProperty("user.home") + "/futbolliveco-fotos";

    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    public UsuarioService() {
        this.dao = new UsuarioDAO();
    }

    public UsuarioService(UsuarioDAO dao) {
        this.dao = dao;
    }

    // ── Autenticación ─────────────────────────────────────────

    public Usuario login(String email, String password)
            throws CredencialesInvalidasException, CampoObligatorioException, SQLException {

        validarEmail(email);
        validarNoVacio(password, "Contraseña");

        Usuario usuario = dao.buscarPorEmail(email);

        if (usuario == null || !BCrypt.checkpw(password, usuario.getPassword())) {
            throw new CredencialesInvalidasException("Email o contraseña incorrectos");
        }

        return usuario;
    }

    // ── Registro ──────────────────────────────────────────────

    public void registrar(String nombre, String email, String password)
            throws CampoObligatorioException, EmailEnUsoException, PasswordInseguroException, SQLException {

        validarNoVacio(nombre,   "Nombre");
        validarEmail(email);
        validarPassword(password);

        if (dao.emailEnUso(email, 0)) {
            throw new EmailEnUsoException("El email ya está registrado");
        }

        String hash = BCrypt.hashpw(password, BCrypt.gensalt());
        dao.registrar(nombre, email, hash);
    }

    // ── Consultas ─────────────────────────────────────────────

    public Usuario obtenerPorId(int id)
            throws UsuarioNoEncontradoException, SQLException {

        Usuario usuario = dao.buscarPorId(id);
        if (usuario == null) {
            throw new UsuarioNoEncontradoException("Usuario no encontrado");
        }
        return usuario;
    }

    // ── Actualización de perfil ───────────────────────────────

    public void actualizarDatos(int userId, String nombre, String email)
            throws CampoObligatorioException, EmailEnUsoException, SQLException {

        validarNoVacio(nombre, "Nombre");
        validarEmail(email);

        if (dao.emailEnUso(email, userId)) {
            throw new EmailEnUsoException("Ese email ya está en uso");
        }

        dao.actualizarDatos(userId, nombre, email);
    }

    public void cambiarPassword(int userId, String actual, String nueva)
            throws CampoObligatorioException, PasswordInseguroException,
                   CredencialesInvalidasException, UsuarioNoEncontradoException, SQLException {

        validarNoVacio(actual, "Contraseña actual");
        validarPassword(nueva);

        Usuario usuario = dao.buscarPorId(userId);
        if (usuario == null) {
            throw new UsuarioNoEncontradoException("Usuario no encontrado");
        }

        if (!BCrypt.checkpw(actual, usuario.getPassword())) {
            throw new CredencialesInvalidasException("La contraseña actual es incorrecta");
        }

        dao.actualizarPassword(userId, BCrypt.hashpw(nueva, BCrypt.gensalt()));
    }

    /**
     * Guarda la imagen en disco y almacena la ruta relativa en la BD.
     * Esto reemplaza el enfoque anterior de Base64 en columna de texto.
     *
     * @param userId      ID del usuario
     * @param contentType MIME type del archivo (debe empezar con "image/")
     * @param imageBytes  Bytes del archivo
     * @param fotosDir    Directorio absoluto donde guardar (se inyecta desde el servlet)
     * @return Ruta URL pública relativa al contexto, e.g. "/fotos/42.jpg"
     */
    public String actualizarFoto(int userId, String contentType, byte[] imageBytes, String fotosDir)
            throws TipoArchivoInvalidoException, CampoObligatorioException, IOException, SQLException {

        if (imageBytes == null || imageBytes.length == 0) {
            throw new CampoObligatorioException("No se recibió ninguna imagen");
        }

        if (contentType == null || !contentType.startsWith("image/")) {
            throw new TipoArchivoInvalidoException("El archivo debe ser una imagen");
        }

        // Determinar extensión
        String ext = "jpg";
        if (contentType.contains("png"))  ext = "png";
        else if (contentType.contains("gif"))  ext = "gif";
        else if (contentType.contains("webp")) ext = "webp";

        // Crear directorio si no existe
        Path dir = Paths.get(fotosDir);
        Files.createDirectories(dir);

        // Nombre de archivo basado en userId (sobreescribe la anterior)
        String nombreArchivo = userId + "." + ext;
        Path destino = dir.resolve(nombreArchivo);
        Files.write(destino, imageBytes);

        // La ruta que se guarda en BD y se devuelve al cliente
        String rutaRelativa = "/fotos/" + nombreArchivo;
        dao.actualizarFotoRuta(userId, rutaRelativa);
        return rutaRelativa;
    }

    /**
     * Elimina la foto de perfil del usuario: borra el archivo en disco (si existe)
     * y limpia la ruta almacenada en la base de datos.
     *
     * @param userId   ID del usuario
     * @param fotosDir Directorio absoluto donde se guardan las fotos (se inyecta desde el servlet)
     */
    public void eliminarFoto(int userId, String fotosDir) throws SQLException, IOException {
        Path dir = Paths.get(fotosDir);
        if (Files.exists(dir)) {
            // Borra cualquier archivo que empiece con "<userId>." sin importar la extensión
            try (var stream = Files.list(dir)) {
                stream.filter(p -> p.getFileName().toString().startsWith(userId + "."))
                      .forEach(p -> {
                          try {
                              Files.deleteIfExists(p);
                          } catch (IOException ignored) {
                              // Si no se puede borrar el archivo físico, igual limpiamos la BD
                          }
                      });
            }
        }
        dao.actualizarFotoRuta(userId, null);
    }

    // ── Helpers internos ──────────────────────────────────────

    private void validarNoVacio(String valor, String campo) throws CampoObligatorioException {
        if (valor == null || valor.trim().isEmpty()) {
            throw new CampoObligatorioException(campo + " es obligatorio");
        }
    }

    private void validarEmail(String email) throws CampoObligatorioException {
        validarNoVacio(email, "Email");
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            throw new CampoObligatorioException("El email no tiene un formato válido");
        }
    }

    private void validarPassword(String password) throws CampoObligatorioException, PasswordInseguroException {
        validarNoVacio(password, "Contraseña");
        if (password.length() < 8) {
            throw new PasswordInseguroException("La contraseña debe tener al menos 8 caracteres");
        }
    }

    // ── Excepciones de dominio ────────────────────────────────

    public static class CampoObligatorioException extends Exception {
        public CampoObligatorioException(String msg) { super(msg); }
    }

    public static class CredencialesInvalidasException extends Exception {
        public CredencialesInvalidasException(String msg) { super(msg); }
    }

    public static class EmailEnUsoException extends Exception {
        public EmailEnUsoException(String msg) { super(msg); }
    }

    public static class UsuarioNoEncontradoException extends Exception {
        public UsuarioNoEncontradoException(String msg) { super(msg); }
    }

    public static class PasswordInseguroException extends Exception {
        public PasswordInseguroException(String msg) { super(msg); }
    }

    public static class TipoArchivoInvalidoException extends Exception {
        public TipoArchivoInvalidoException(String msg) { super(msg); }
    }
}
