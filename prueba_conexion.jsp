<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Administrador")) { return; } %>
<%
    String tituloPagina = "Diagnóstico de conexión";
    boolean ok = false;
    String detalle = "";
    Connection con = null; Statement st = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT VERSION() AS version");
        if (rs.next()) {
            ok = true;
            detalle = "Conectado correctamente a MySQL. Versión del servidor: " + rs.getString("version");
        }
    } catch (SQLException e) {
        ok = false;
        detalle = e.getMessage();
    } finally { cerrar(rs, st, con); }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-plug"></i> Diagnóstico de conexión</h3>

<% if (ok) { %>
    <div class="alert alert-success"><i class="bi bi-check-circle"></i> <%= esc(detalle) %></div>
    <% if (!detalle.matches(".*8\\.[1-9].*|.*8\\.0\\.(1[6-9]|[2-9][0-9]).*")) { %>
        <div class="alert alert-warning">
            <i class="bi bi-exclamation-triangle"></i> Recuerda: los <code>CHECK</code> del esquema solo se validan en
            MySQL 8.0.16 o superior. Verifica la versión mostrada arriba.
        </div>
    <% } %>
<% } else { %>
    <div class="alert alert-danger">
        <i class="bi bi-x-circle"></i> No se pudo conectar a la base de datos.<br>
        <small><%= esc(detalle) %></small>
    </div>
    <p class="text-muted">Verifica que MySQL esté encendido, que exista la base <code>inmobiliaria_db</code>
       y que <code>mysql-connector-j-x.x.x.jar</code> esté en <code>WEB-INF/lib</code>.</p>
<% } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
