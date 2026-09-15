<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String tituloPagina = "Mis favoritos";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-heart-fill text-danger"></i> Mis favoritos</h3>

<div class="row g-3">
<%
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.titulo, p.precio_venta, p.precio_arriendo, c.nombre AS ciudad " +
            "FROM favorito f JOIN propiedad p ON p.id_propiedad = f.id_propiedad " +
            "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
            "WHERE f.id_usuario = ? ORDER BY f.fecha_agregado DESC");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        boolean hay = false;
        while (rs.next()) {
            hay = true;
%>
    <div class="col-md-4">
        <div class="card h-100">
            <div class="card-body">
                <h5><%= esc(rs.getString("titulo")) %></h5>
                <p class="text-muted"><i class="bi bi-geo-alt"></i> <%= esc(rs.getString("ciudad")) %></p>
                <p class="fw-bold text-primary">
                    <% if (rs.getObject("precio_venta") != null) { %><%= moneda(rs.getDouble("precio_venta")) %>
                    <% } else if (rs.getObject("precio_arriendo") != null) { %><%= moneda(rs.getDouble("precio_arriendo")) %>/mes<% } %>
                </p>
                <a href="<%= ctx %>/propiedad.jsp?id=<%= rs.getInt("id_propiedad") %>" class="btn btn-sm btn-outline-primary">Ver ficha</a>
                <form action="<%= ctx %>/cliente/acciones.jsp" method="post" class="d-inline">
                    <input type="hidden" name="accion" value="quitar_favorito">
                    <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
                    <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
                </form>
            </div>
        </div>
    </div>
<%
        }
        if (!hay) {
%>
    <div class="col-12"><p class="text-muted text-center py-4">Todavía no has guardado favoritos.
        <a href="<%= ctx %>/catalogo.jsp">Explora el catálogo</a>.</p></div>
<%
        }
    } catch (SQLException e) {
%>
    <div class="col-12"><div class="alert alert-danger">Error: <%= esc(e.getMessage()) %></div></div>
<%
    } finally { cerrar(rs, ps, con); }
%>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
