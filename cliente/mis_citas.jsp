<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String tituloPagina = "Mis citas";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-calendar-week"></i> Mis citas</h3>
<% if ("1".equals(request.getParameter("ok"))) { %><div class="alert alert-success py-2">Listo.</div><% } %>

<div class="table-responsive">
<table class="table table-striped bg-white align-middle">
    <thead class="table-dark"><tr><th>Propiedad</th><th>Fecha</th><th>Estado</th><th>Agente</th><th></th></tr></thead>
    <tbody>
    <%
        try {
            con = abrirConexion();
            ps = con.prepareStatement(
                "SELECT c.id_cita, c.fecha_hora, c.estado, p.titulo, CONCAT(pf.nombres,' ',pf.apellidos) AS agente " +
                "FROM cita c JOIN propiedad p ON p.id_propiedad = c.id_propiedad " +
                "JOIN perfil pf ON pf.id_usuario = c.id_agente " +
                "WHERE c.id_cliente = ? ORDER BY c.fecha_hora DESC");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            boolean hay = false;
            while (rs.next()) {
                hay = true;
    %>
        <tr>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td><%= rs.getTimestamp("fecha_hora") %></td>
            <td><span class="badge bg-<%= colorEstado(rs.getString("estado")) %>"><%= esc(rs.getString("estado")) %></span></td>
            <td><%= esc(rs.getString("agente")) %></td>
            <td>
                <% if ("SOLICITADA".equals(rs.getString("estado")) || "CONFIRMADA".equals(rs.getString("estado"))) { %>
                <form action="<%= ctx %>/cliente/acciones.jsp" method="post"
                      onsubmit="return confirm('¿Cancelar esta cita?');">
                    <input type="hidden" name="accion" value="cancelar_cita">
                    <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
                    <button type="submit" class="btn btn-sm btn-outline-danger">Cancelar</button>
                </form>
                <% } %>
            </td>
        </tr>
    <%
            }
            if (!hay) {
    %>
        <tr><td colspan="5" class="text-center text-muted py-4">No tienes citas registradas.</td></tr>
    <%
            }
        } catch (SQLException e) {
    %>
        <tr><td colspan="5" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
    <%
        } finally { cerrar(rs, ps, con); }
    %>
    </tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
