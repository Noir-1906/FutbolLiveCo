package com.mycompany.futbolliveco.dao;

import com.mycompany.futbolliveco.model.Usuario;
import com.mycompany.futbolliveco.util.DBConnection;

import java.sql.*;

/**
 * Operaciones de base de datos relacionadas con el reset de contraseña.
 * Reutiliza la tabla "usuarios" añadiendo las columnas reset_token y reset_token_exp.
 */
public class PasswordResetDAO {

    /**
     * Guarda el token de reset y su fecha de expiración para el usuario con ese email.
     * Devuelve true si se encontró y actualizó el usuario, false si el email no existe.
     */
    public boolean guardarToken(String email, String token, Timestamp expiry) throws SQLException {
        String sql = "UPDATE usuarios SET reset_token = ?, reset_token_exp = ? WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setTimestamp(2, expiry);
            ps.setString(3, email);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Busca un usuario cuyo token coincida y que no haya expirado.
     * Devuelve null si el token no existe o ya expiró.
     */
    public Usuario buscarPorToken(String token) throws SQLException {
        String sql = "SELECT id, nombre, email, password, foto_ruta " +
                     "FROM usuarios " +
                     "WHERE reset_token = ? AND reset_token_exp > NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario();
                    u.setId(rs.getInt("id"));
                    u.setNombre(rs.getString("nombre"));
                    u.setEmail(rs.getString("email"));
                    u.setPassword(rs.getString("password"));
                    u.setFoto(rs.getString("foto_ruta"));
                    return u;
                }
            }
        }
        return null;
    }

    /**
     * Invalida el token después de usarlo (lo pone a NULL).
     */
    public void invalidarToken(int userId) throws SQLException {
        String sql = "UPDATE usuarios SET reset_token = NULL, reset_token_exp = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}
