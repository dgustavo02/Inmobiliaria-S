<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Inmobiliaria")) { return; } %>
<%
    String tituloPagina = "Mi agenda";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-calendar-week"></i> Mi agenda de visitas</h3>
<% if ("1".equals(request.getParameter("ok"))) { %><div class="alert alert-success py-2">Actualizado.</div><% } %>

<div class="table-responsive">
<table class="table table-striped bg-white align-middle">
    <thead class="table-dark"><tr><th>Propiedad</th><th>Cliente</th><th>Fecha</th><th>Estado</th><th>Comentario</th><th></th></tr></thead>
    <tbody>
    <%
        try {
            con = abrirConexion();
            ps = con.prepareStatement(
                "SELECT c.id_cita, c.fecha_hora, c.estado, c.comentario_cliente, p.titulo, " +
                "       CONCAT(pf.nombres,' ',pf.apellidos) AS cliente " +
                "FROM cita c JOIN propiedad p ON p.id_propiedad = c.id_propiedad " +
                "JOIN perfil pf ON pf.id_usuario = c.id_cliente " +
                "WHERE c.id_agente = ? ORDER BY c.fecha_hora");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            boolean hay = false;
            while (rs.next()) {
                hay = true;
                String estado = rs.getString("estado");
    %>
        <tr>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td><%= esc(rs.getString("cliente")) %></td>
            <td><%= rs.getTimestamp("fecha_hora") %></td>
            <td><span class="badge bg-<%= colorEstado(estado) %>"><%= esc(estado) %></span></td>
            <td><small><%= esc(rs.getString("comentario_cliente")) %></small></td>
            <td class="d-flex gap-1">
                <% if ("SOLICITADA".equals(estado)) { %>
                    <form action="<%= ctx %>/agente/accion.jsp" method="post">
                        <input type="hidden" name="accion" value="confirmar_cita">
                        <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
                        <button class="btn btn-sm btn-success"><i class="bi bi-check"></i></button>
                    </form>
                <% } %>
                <% if ("SOLICITADA".equals(estado) || "CONFIRMADA".equals(estado)) { %>
                    <form action="<%= ctx %>/agente/accion.jsp" method="post">
                        <input type="hidden" name="accion" value="realizar_cita">
                        <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
                        <button class="btn btn-sm btn-primary"><i class="bi bi-flag"></i> Realizada</button>
                    </form>
                    <form action="<%= ctx %>/agente/accion.jsp" method="post">
                        <input type="hidden" name="accion" value="cancelar_cita">
                        <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
                        <button class="btn btn-sm btn-outline-danger"><i class="bi bi-x"></i></button>
                    </form>
                <% } %>
            </td>
        </tr>
    <%
            }
            if (!hay) {
    %>
        <tr><td colspan="6" class="text-center text-muted py-4">No tienes citas registradas.</td></tr>
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
