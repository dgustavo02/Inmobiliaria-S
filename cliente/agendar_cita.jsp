<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String tituloPagina = "Agendar visita";
    String ctx = request.getContextPath();
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-calendar-plus"></i> Agendar visita</h3>

<%
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.titulo, p.direccion, i.id_usuario AS id_agente " +
            "FROM propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "WHERE p.id_propiedad = ?");
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
            <p><strong>Propiedad:</strong> <%= esc(rs.getString("titulo")) %> — <%= esc(rs.getString("direccion")) %></p>
            <form action="<%= ctx %>/cliente/acciones.jsp" method="post">
                <input type="hidden" name="accion" value="agendar_cita">
                <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                <div class="mb-3">
                    <label class="form-label">Fecha y hora</label>
                    <input type="datetime-local" name="fecha_hora" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Comentario para el agente (opcional)</label>
                    <textarea name="comentario_cliente" class="form-control" rows="3"></textarea>
                </div>
                <div class="form-check mb-3">
                    <input type="checkbox" class="form-check-input" name="requiere_acompanante" id="acomp">
                    <label class="form-check-label" for="acomp">Iré acompañado</label>
                </div>
                <button type="submit" class="btn btn-primary"><i class="bi bi-calendar-check"></i> Solicitar visita</button>
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
