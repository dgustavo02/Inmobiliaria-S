<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Inmobiliaria")) { return; } %>
<%
    String tituloPagina = "Solicitudes";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-inboxes"></i> Solicitudes de compra/arriendo</h3>
<% if ("1".equals(request.getParameter("ok"))) { %><div class="alert alert-success py-2">Actualizado.</div><% } %>

<div class="table-responsive">
<table class="table table-striped bg-white align-middle">
    <thead class="table-dark"><tr><th>Propiedad</th><th>Cliente</th><th>Tipo</th><th>Monto</th><th>Estado</th><th>Documentos</th><th></th></tr></thead>
    <tbody>
    <%
        try {
            con = abrirConexion();
            ps = con.prepareStatement(
                "SELECT s.id_solicitud, s.tipo, s.monto_ofrecido, s.estado, p.titulo, " +
                "       CONCAT(pf.nombres,' ',pf.apellidos) AS cliente, " +
                "       (SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud = s.id_solicitud) AS num_docs, " +
                "       (SELECT d2.url_archivo FROM documento_solicitud d2 WHERE d2.id_solicitud = s.id_solicitud " +
                "        ORDER BY d2.fecha_subida DESC LIMIT 1) AS ultimo_doc " +
                "FROM solicitud s JOIN propiedad p ON p.id_propiedad = s.id_propiedad " +
                "JOIN perfil pf ON pf.id_usuario = s.id_cliente " +
                "WHERE s.id_agente = ? ORDER BY s.fecha_radicacion DESC");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            boolean hay = false;
            while (rs.next()) {
                hay = true;
                String estado = rs.getString("estado");
                int numDocs = rs.getInt("num_docs");
    %>
        <tr>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td><%= esc(rs.getString("cliente")) %></td>
            <td><%= esc(rs.getString("tipo")) %></td>
            <td><%= moneda(rs.getDouble("monto_ofrecido")) %></td>
            <td><span class="badge bg-<%= colorEstado(estado) %>"><%= esc(estado) %></span></td>
            <td>
                <% if (numDocs > 0) { %>
                    <a href="<%= esc(rs.getString("ultimo_doc")) %>" target="_blank" rel="noopener"><i class="bi bi-folder2-open"></i></a>
                    <span class="badge bg-secondary"><%= numDocs %></span>
                <% } else { %>
                    <span class="text-muted small">Sin adjuntar</span>
                <% } %>
            </td>
            <td class="d-flex gap-1 flex-wrap">
                <% if ("RADICADA".equals(estado) || "EN_REVISION".equals(estado)) { %>
                    <form action="<%= ctx %>/agente/accion.jsp" method="post">
                        <input type="hidden" name="accion" value="aprobar_solicitud">
                        <input type="hidden" name="id_solicitud" value="<%= rs.getInt("id_solicitud") %>">
                        <button class="btn btn-sm btn-success">Aprobar</button>
                    </form>
                    <form action="<%= ctx %>/agente/accion.jsp" method="post">
                        <input type="hidden" name="accion" value="rechazar_solicitud">
                        <input type="hidden" name="id_solicitud" value="<%= rs.getInt("id_solicitud") %>">
                        <button class="btn btn-sm btn-outline-danger">Rechazar</button>
                    </form>
                <% } else if ("APROBADA".equals(estado)) { %>
                    <form action="<%= ctx %>/agente/accion.jsp" method="post" class="row g-1">
                        <input type="hidden" name="accion" value="firmar_contrato">
                        <input type="hidden" name="id_solicitud" value="<%= rs.getInt("id_solicitud") %>">
                        <div class="col-6"><input type="text" name="numero_contrato" class="form-control form-control-sm" placeholder="N° contrato" required></div>
                        <div class="col-6"><button class="btn btn-sm btn-primary w-100">Firmar</button></div>
                    </form>
                <% } %>
            </td>
        </tr>
    <%
            }
            if (!hay) {
    %>
        <tr><td colspan="7" class="text-center text-muted py-4">No tienes solicitudes por atender.</td></tr>
    <%
            }
        } catch (SQLException e) {
    %>
        <tr><td colspan="7" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
    <%
        } finally { cerrar(rs, ps, con); }
    %>
    </tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
