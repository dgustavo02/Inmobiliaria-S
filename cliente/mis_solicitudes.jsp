<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String tituloPagina = "Mis solicitudes";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-inboxes"></i> Mis solicitudes</h3>
<% if ("1".equals(request.getParameter("ok"))) { %><div class="alert alert-success py-2">Listo.</div><% } %>

<div class="table-responsive">
<table class="table table-striped bg-white align-middle">
    <thead class="table-dark"><tr><th>Propiedad</th><th>Tipo</th><th>Monto</th><th>Estado</th><th>Documentos</th></tr></thead>
    <tbody>
    <%
        try {
            con = abrirConexion();
            ps = con.prepareStatement(
                "SELECT s.id_solicitud, s.tipo, s.monto_ofrecido, s.estado, p.titulo, " +
                "       (SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud = s.id_solicitud) AS num_docs, " +
                "       (SELECT d2.url_archivo FROM documento_solicitud d2 WHERE d2.id_solicitud = s.id_solicitud " +
                "        ORDER BY d2.fecha_subida DESC LIMIT 1) AS ultimo_doc " +
                "FROM solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                "WHERE s.id_cliente = ? ORDER BY s.fecha_radicacion DESC");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            boolean hay = false;
            while (rs.next()) {
                hay = true;
                int numDocs = rs.getInt("num_docs");
    %>
        <tr>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td><%= esc(rs.getString("tipo")) %></td>
            <td><%= moneda(rs.getDouble("monto_ofrecido")) %></td>
            <td><span class="badge bg-<%= colorEstado(rs.getString("estado")) %>"><%= esc(rs.getString("estado")) %></span></td>
            <td>
                <% if (numDocs > 0) { %>
                    <a href="<%= esc(rs.getString("ultimo_doc")) %>" target="_blank" rel="noopener">
                        <i class="bi bi-folder2-open"></i> Ver el más reciente
                    </a>
                    <span class="badge bg-secondary"><%= numDocs %></span>
                <% } %>
                <form action="<%= ctx %>/cliente/acciones.jsp" method="post" class="d-flex gap-1 mt-1">
                    <input type="hidden" name="accion" value="agregar_documento">
                    <input type="hidden" name="id_solicitud" value="<%= rs.getInt("id_solicitud") %>">
                    <input type="text" name="nombre_archivo" class="form-control form-control-sm" placeholder="Nombre" required>
                    <input type="url" name="url_documento" class="form-control form-control-sm" placeholder="Enlace" required>
                    <button type="submit" class="btn btn-sm btn-outline-primary">+</button>
                </form>
            </td>
        </tr>
    <%
            }
            if (!hay) {
    %>
        <tr><td colspan="5" class="text-center text-muted py-4">No has radicado solicitudes.</td></tr>
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
