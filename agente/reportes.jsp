<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Inmobiliaria")) { return; } %>
<%
    String tituloPagina = "Reportes";
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-graph-up"></i> Reportes</h3>

<div class="row g-4">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">Propiedades por estado</div>
            <div class="card-body">
                <table class="table table-sm mb-0">
                    <thead><tr><th>Estado</th><th class="text-end">Cantidad</th></tr></thead>
                    <tbody>
                    <%
                        try {
                            con = abrirConexion();
                            ps = con.prepareStatement(
                                "SELECT p.estado_propiedad, COUNT(*) AS cantidad " +
                                "FROM propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                                "WHERE i.id_usuario = ? GROUP BY p.estado_propiedad ORDER BY cantidad DESC");
                            ps.setInt(1, idUsuario);
                            rs = ps.executeQuery();
                            while (rs.next()) {
                    %>
                        <tr><td><%= esc(rs.getString("estado_propiedad")) %></td><td class="text-end"><%= rs.getInt("cantidad") %></td></tr>
                    <%
                            }
                        } catch (SQLException e) { %>
                        <tr><td colspan="2" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
                    <% } finally { cerrar(rs, ps); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header">Propiedades más visitadas (más de 0 visitas)</div>
            <div class="card-body">
                <table class="table table-sm mb-0">
                    <thead><tr><th>Propiedad</th><th class="text-end">Visitas</th></tr></thead>
                    <tbody>
                    <%
                        try {
                            ps = con.prepareStatement(
                                "SELECT p.titulo, p.visitas FROM propiedad p " +
                                "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                                "WHERE i.id_usuario = ? GROUP BY p.id_propiedad HAVING p.visitas > 0 " +
                                "ORDER BY p.visitas DESC LIMIT 10");
                            ps.setInt(1, idUsuario);
                            rs = ps.executeQuery();
                            boolean hay = false;
                            while (rs.next()) {
                                hay = true;
                    %>
                        <tr><td><%= esc(rs.getString("titulo")) %></td><td class="text-end"><%= rs.getInt("visitas") %></td></tr>
                    <%
                            }
                            if (!hay) { %><tr><td colspan="2" class="text-muted">Sin visitas registradas todavía.</td></tr><% }
                        } catch (SQLException e) { %>
                        <tr><td colspan="2" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
                    <% } finally { cerrar(rs, ps); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header">Citas por estado</div>
            <div class="card-body">
                <table class="table table-sm mb-0">
                    <thead><tr><th>Estado</th><th class="text-end">Cantidad</th></tr></thead>
                    <tbody>
                    <%
                        try {
                            ps = con.prepareStatement(
                                "SELECT estado, COUNT(*) AS cantidad FROM cita WHERE id_agente = ? " +
                                "GROUP BY estado ORDER BY cantidad DESC");
                            ps.setInt(1, idUsuario);
                            rs = ps.executeQuery();
                            while (rs.next()) {
                    %>
                        <tr><td><%= esc(rs.getString("estado")) %></td><td class="text-end"><%= rs.getInt("cantidad") %></td></tr>
                    <%
                            }
                        } catch (SQLException e) { %>
                        <tr><td colspan="2" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
                    <% } finally { cerrar(rs, ps); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header">Características más usadas en tus propiedades (2 o más veces)</div>
            <div class="card-body">
                <table class="table table-sm mb-0">
                    <thead><tr><th>Característica</th><th class="text-end">Propiedades</th></tr></thead>
                    <tbody>
                    <%
                        try {
                            ps = con.prepareStatement(
                                "SELECT ca.nombre, COUNT(*) AS veces " +
                                "FROM propiedad_caracteristica pc " +
                                "JOIN propiedad p ON p.id_propiedad = pc.id_propiedad " +
                                "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                                "JOIN caracteristica ca ON ca.id_caracteristica = pc.id_caracteristica " +
                                "WHERE i.id_usuario = ? GROUP BY ca.id_caracteristica HAVING COUNT(*) >= 2 " +
                                "ORDER BY veces DESC");
                            ps.setInt(1, idUsuario);
                            rs = ps.executeQuery();
                            boolean hay = false;
                            while (rs.next()) {
                                hay = true;
                    %>
                        <tr><td><%= esc(rs.getString("nombre")) %></td><td class="text-end"><%= rs.getInt("veces") %></td></tr>
                    <%
                            }
                            if (!hay) { %><tr><td colspan="2" class="text-muted">Aún no hay suficientes datos.</td></tr><% }
                        } catch (SQLException e) { %>
                        <tr><td colspan="2" class="text-danger">Error: <%= esc(e.getMessage()) %></td></tr>
                    <% } finally { cerrar(rs, ps, con); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
