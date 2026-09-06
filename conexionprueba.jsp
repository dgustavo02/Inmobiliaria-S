<%--
    prueba_conexion.jsp - Pagina de verificacion de la base de datos inmobiliaria_db
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prueba de Conexion - inmobiliaria_db</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background-color: #f4f6f9; color: #333; }
        .card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .exito { color: #155724; background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 6px; }
        .error { color: #721c24; background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 6px; }
        ul { list-style-type: none; padding-left: 0; }
        li { padding: 6px 0; border-bottom: 1px solid #eee; }
        .badge { background: #007bff; color: white; padding: 3px 8px; border-radius: 4px; font-size: 0.85em; }
    </style>
</head>
<body>

    <div class="card">
        <h2>Estado de Conexion - Base de Datos: <code>inmobiliaria_db</code></h2>

<%
    Connection con = null; 
    Statement st = null; 
    ResultSet rs = null;

    try {
        con = abrirConexion();
        st = con.createStatement();
%>
        <div class="exito">
            <strong>Conexion establecida con exito.</strong><br>
            <small><strong>Motor MySQL:</strong> <%= con.getMetaData().getDatabaseProductVersion() %></small> | 
            <small><strong>Base de datos activa:</strong> <%= con.getCatalog() %></small>
        </div>

        <h3 style="margin-top: 20px;">Resumen de Registros en el Sistema</h3>
        <ul>
<%
            // 1. Conteo de propiedades
            rs = st.executeQuery("SELECT COUNT(*) AS total FROM propiedad");
            if (rs.next()) {
%>
                <li><strong>Propiedades registradas:</strong> <span class="badge"><%= rs.getInt("total") %></span></li>
<%
            }
            rs.close();

            // 2. Conteo de usuarios
            rs = st.executeQuery("SELECT COUNT(*) AS total FROM usuario");
            if (rs.next()) {
%>
                <li><strong>Usuarios en el sistema:</strong> <span class="badge"><%= rs.getInt("total") %></span></li>
<%
            }
            rs.close();

            // 3. Conteo de ciudades
            rs = st.executeQuery("SELECT COUNT(*) AS total FROM ciudad");
            if (rs.next()) {
%>
                <li><strong>Ciudades parametrizadas:</strong> <span class="badge"><%= rs.getInt("total") %></span></li>
<%
            }
            rs.close();

            // 4. Conteo de tipos de propiedad
            rs = st.executeQuery("SELECT COUNT(*) AS total FROM tipo_propiedad");
            if (rs.next()) {
%>
                <li><strong>Tipos de inmueble:</strong> <span class="badge"><%= rs.getInt("total") %></span></li>
<%
            }
            rs.close();
%>
        </ul>

<%
    } catch (SQLException ex) {
%>
        <div class="error">
            <strong>Error al conectar con la base de datos:</strong><br>
            <code><%= ex.getMessage() %></code>
        </div>
<%
    } finally { 
        cerrar(rs, st, con); 
    }
%>
    </div>

</body>
</html>