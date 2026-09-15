<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Inmobiliaria")) { return; } %>
<%
    String tituloPagina = "Mis propiedades";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3><i class="bi bi-building"></i> Mis propiedades</h3>
    <a href="<%= ctx %>/agente/propiedad_form.jsp" class="btn btn-primary"><i class="bi bi-plus-circle"></i> Nueva propiedad</a>
</div>
<% if ("1".equals(request.getParameter("ok"))) { %><div class="alert alert-success py-2">Guardado correctamente.</div><% } %>

<div class="table-responsive">
<table class="table table-striped bg-white align-middle">
    <thead class="table-dark"><tr><th>Matrícula</th><th>Título</th><th>Ciudad</th><th>Precio</th><th>Estado</th><th></th></tr></thead>
    <tbody>
    <%
        try {
            con = abrirConexion();
            ps = con.prepareStatement(
                "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.precio_venta, p.precio_arriendo, " +
                "       p.estado_propiedad, c.nombre AS ciudad " +
                "FROM propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
                "WHERE i.id_usuario = ? ORDER BY p.fecha_publicacion DESC");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            boolean hay = false;
            while (rs.next()) {
                hay = true;
    %>
        <tr>
            <td><%= esc(rs.getString("matricula_inmobiliaria")) %></td>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td><%= esc(rs.getString("ciudad")) %></td>
            <td>
                <% if (rs.getObject("precio_venta") != null) { %><%= moneda(rs.getDouble("precio_venta")) %>
                <% } else if (rs.getObject("precio_arriendo") != null) { %><%= moneda(rs.getDouble("precio_arriendo")) %>/mes<% } %>
            </td>
            <td><span class="badge bg-<%= colorEstado(rs.getString("estado_propiedad")) %>"><%= esc(rs.getString("estado_propiedad")) %></span></td>
            <td>
                <a class="btn btn-sm btn-outline-primary" href="<%= ctx %>/agente/propiedad_form.jsp?id=<%= rs.getInt("id_propiedad") %>">
                    <i class="bi bi-pencil"></i> Editar
                </a>
                <a class="btn btn-sm btn-outline-secondary" href="<%= ctx %>/propiedad.jsp?id=<%= rs.getInt("id_propiedad") %>" target="_blank">
                    <i class="bi bi-eye"></i>
                </a>
                <% if (!"INACTIVA".equals(rs.getString("estado_propiedad"))) { %>
                <form action="<%= ctx %>/agente/guardar_propiedad.jsp" method="post" class="d-inline"
                      onsubmit="return confirm('¿Dar de baja esta propiedad?');">
                    <input type="hidden" name="accion" value="dar_de_baja">
                    <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
                    <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-slash-circle"></i></button>
                </form>
                <% } %>
            </td>
        </tr>
    <%
            }
            if (!hay) {
    %>
        <tr><td colspan="6" class="text-center text-muted py-4">Aún no has publicado propiedades.</td></tr>
    <%
            }
        } catch (SQLException e) {
    %>
        <tr><td colspan="6" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
    <%
        } finally { cerrar(rs, ps, con); }
    %>
    </tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
