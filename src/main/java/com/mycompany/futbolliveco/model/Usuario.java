package com.mycompany.futbolliveco.model;
 
public class Usuario {
 
    private int    id;
    private String nombre, email, password, foto;
 
    public Usuario() {}
 
    public int    getId()               { return id; }
    public void   setId(int id)         { this.id = id; }
 
    public String getNombre()           { return nombre; }
    public void   setNombre(String n)   { this.nombre = n; }
 
    public String getEmail()            { return email; }
    public void   setEmail(String e)    { this.email = e; }
 
    public String getPassword()         { return password; }
    public void   setPassword(String p) { this.password = p; }
 
    public String getFoto()             { return foto; }
    public void   setFoto(String f)     { this.foto = f; }
}
 