package com.mycompany.futbolliveco.dao;

import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.util.DBConnection;
import java.sql.*;

/**
 * DAO para la entidad Usuario.
 * Centraliza todas las operaciones SQL relacionadas con usuarios.
 */
public class UsuarioDAO {

    // ── Consultas ────────────────────────────────────────────

    /**
     * buscarPorEmail incluye foto para que el login también tenga acceso a ella.
     */
    public Usuario buscarPorEmail(String email) throws SQLException {
        String sql = "SELECT id, nombre, email, password, foto_ruta FROM usuarios WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public Usuario buscarPorId(int id) throws SQLException {
        String sql = "SELECT id, nombre, email, password, foto_ruta FROM usuarios WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    /**
     * Verifica si un email ya está en uso.
     * @param excluirId pasar 0 en registro, pasar userId en actualización de perfil
     */
    public boolean emailEnUso(String email, int excluirId) throws SQLException {
        String sql = excluirId == 0
            ? "SELECT id FROM usuarios WHERE email = ?"
            : "SELECT id FROM usuarios WHERE email = ? AND id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            if (excluirId != 0) ps.setInt(2, excluirId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ── Escritura ────────────────────────────────────────────

    public void registrar(String nombre, String email, String passwordHasheado) throws SQLException {
        String sql = "INSERT INTO usuarios (nombre, email, password) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, passwordHasheado);
            ps.executeUpdate();
        }
    }

    public void actualizarDatos(int id, String nombre, String email) throws SQLException {
        String sql = "UPDATE usuarios SET nombre = ?, email = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }

    public void actualizarPassword(int id, String passwordHasheado) throws SQLException {
        String sql = "UPDATE usuarios SET password = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHasheado);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /**
     * Guarda la ruta relativa de la foto (ej: "fotos/42.jpg"), NO el contenido binario.
     */
    public void actualizarFotoRuta(int id, String ruta) throws SQLException {
        String sql = "UPDATE usuarios SET foto_ruta = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ruta);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    // ── Mapeo ────────────────────────────────────────────────

    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setId(rs.getInt("id"));
        u.setNombre(rs.getString("nombre"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setFoto(rs.getString("foto_ruta"));   // puede ser null -> ok
        return u;
    }
}
