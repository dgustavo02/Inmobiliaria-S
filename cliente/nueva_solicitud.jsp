<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String tituloPagina = "Radicar solicitud";
    String ctx = request.getContextPath();
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-file-earmark-plus"></i> Radicar solicitud</h3>

<%
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT titulo, precio_venta, precio_arriendo FROM propiedad WHERE id_propiedad = ?");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        if (!rs.next()) {
%>
    <div class="alert alert-danger">La propiedad no existe.</div>
<%
        } else {
%>
    <div class="card">
        <div class="card-body">
            <p><strong>Propiedad:</strong> <%= esc(rs.getString("titulo")) %></p>
            <form action="<%= ctx %>/cliente/acciones.jsp" method="post">
                <input type="hidden" name="accion" value="crear_solicitud">
                <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                <div class="mb-3">
                    <label class="form-label">Tipo</label>
                    <select name="tipo" class="form-select">
                        <% if (rs.getObject("precio_venta") != null) { %><option value="COMPRA">Compra</option><% } %>
                        <% if (rs.getObject("precio_arriendo") != null) { %><option value="ARRIENDO">Arriendo</option><% } %>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Monto ofrecido</label>
                    <input type="number" step="0.01" min="0" name="monto_ofrecido" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Comentario / condiciones</label>
                    <textarea name="comentario_cliente" class="form-control" rows="3" required></textarea>
                </div>
                <div class="mb-3">
                    <label class="form-label">Documento de soporte (opcional por ahora)</label>
                    <div class="row g-2">
                        <div class="col-md-5">
                            <input type="text" name="nombre_archivo" class="form-control" placeholder="Nombre (ej. Cédula.pdf)">
                        </div>
                        <div class="col-md-7">
                            <input type="url" name="url_documento" class="form-control" placeholder="https://drive.google.com/...">
                        </div>
                    </div>
                    <small class="text-muted">Puedes agregar más documentos después desde "Mis solicitudes".</small>
                </div>
                <button type="submit" class="btn btn-success"><i class="bi bi-send"></i> Radicar solicitud</button>
                <a href="<%= ctx %>/propiedad.jsp?id=<%= idPropiedad %>" class="btn btn-outline-secondary">Cancelar</a>
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
