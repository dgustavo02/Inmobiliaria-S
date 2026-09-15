<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String tituloPagina = "Mi perfil";
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-person-circle"></i> Mi perfil</h3>
<% if ("1".equals(request.getParameter("ok"))) { %><div class="alert alert-success py-2">Perfil actualizado.</div><% } %>

<%
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.nombres, p.apellidos, p.telefono, p.direccion, u.correo " +
            "FROM perfil p JOIN usuario u ON u.id_usuario = p.id_usuario WHERE p.id_usuario = ?");
        ps.setInt(1, idUsuario);
        rs = ps.executeQuery();
        if (rs.next()) {
%>
    <div class="card">
        <div class="card-body">
            <form action="<%= ctx %>/cliente/guardar_perfil.jsp" method="post">
                <div class="mb-3">
                    <label class="form-label">Correo (no editable)</label>
                    <input type="text" class="form-control" value="<%= esc(rs.getString("correo")) %>" disabled>
                </div>
                <div class="row g-2">
                    <div class="col-md-6">
                        <label class="form-label">Nombres</label>
                        <input type="text" name="nombres" class="form-control" value="<%= esc(rs.getString("nombres")) %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Apellidos</label>
                        <input type="text" name="apellidos" class="form-control" value="<%= esc(rs.getString("apellidos")) %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Teléfono</label>
                        <input type="text" name="telefono" class="form-control" value="<%= esc(rs.getString("telefono")) %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Dirección</label>
                        <input type="text" name="direccion" class="form-control" value="<%= esc(rs.getString("direccion")) %>" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary mt-3"><i class="bi bi-save"></i> Guardar cambios</button>
            </form>
        </div>
    </div>
<%
        }
    } catch (SQLException e) {
%>
    <div class="alert alert-danger">Error: <%= esc(e.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
%>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
