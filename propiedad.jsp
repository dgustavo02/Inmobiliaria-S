<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String ctx = request.getContextPath();
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    Object rolSesion = (session != null) ? session.getAttribute("rol") : null;
    Object idUsuarioSesion = (session != null) ? session.getAttribute("idUsuario") : null;

    String tituloPagina = "Detalle de propiedad";
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<% if ("1".equals(request.getParameter("ok"))) { %>
    <div class="alert alert-success py-2">Operación realizada correctamente.</div>
<% } %>
<% if (request.getParameter("err") != null) { %>
    <div class="alert alert-danger py-2"><%= esc(request.getParameter("err")) %></div>
<% } %>

<%
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.*, c.nombre AS ciudad, t.nombre AS tipo, " +
            "       i.razon_social, i.telefono AS tel_inmobiliaria, i.email AS email_inmobiliaria " +
            "FROM propiedad p JOIN ciudad c ON c.id_ciudad = p.id_ciudad " +
            "JOIN tipo_propiedad t ON t.id_tipo = p.id_tipo " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "WHERE p.id_propiedad = ?");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();

        if (!rs.next()) {
%>
    <div class="alert alert-danger">La propiedad no existe.</div>
<%
        } else {
            // Contador simple de visitas
            PreparedStatement psVisita = con.prepareStatement("UPDATE propiedad SET visitas = visitas + 1 WHERE id_propiedad = ?");
            psVisita.setInt(1, idPropiedad);
            psVisita.executeUpdate();
            cerrar(psVisita);
%>
    <div class="row g-4">
        <div class="col-md-7">
            <h3><%= esc(rs.getString("titulo")) %></h3>
            <p class="text-muted"><i class="bi bi-geo-alt"></i> <%= esc(rs.getString("direccion")) %>,
               <%= esc(rs.getString("barrio")) %>, <%= esc(rs.getString("ciudad")) %></p>

            <div class="d-flex gap-3 flex-wrap mb-3">
                <span class="badge bg-secondary"><%= esc(rs.getString("tipo")) %></span>
                <span class="badge bg-<%= colorEstado(rs.getString("estado_propiedad")) %>"><%= esc(rs.getString("estado_propiedad")) %></span>
                <% if (rs.getString("estrato") != null) { %><span class="badge bg-dark">Estrato <%= esc(rs.getString("estrato")) %></span><% } %>
            </div>

            <h5>Galería</h5>
            <div class="row g-2 mb-3">
            <%
                PreparedStatement psImg = con.prepareStatement(
                    "SELECT ruta FROM imagen_propiedad WHERE id_propiedad = ? ORDER BY es_principal DESC, orden");
                psImg.setInt(1, idPropiedad);
                ResultSet rsImg = psImg.executeQuery();
                boolean hayImg = false;
                while (rsImg.next()) {
                    hayImg = true;
            %>
                <div class="col-4"><img src="<%= esc(rsImg.getString("ruta")) %>" class="img-fluid rounded" alt="Foto de la propiedad"></div>
            <%
                }
                if (!hayImg) {
            %>
                <div class="col-12"><p class="text-muted">Esta propiedad todavía no tiene fotos.</p></div>
            <%
                }
                cerrar(rsImg, psImg);
            %>
            </div>

            <h5>Descripción</h5>
            <p><%= esc(rs.getString("descripcion")) %></p>

            <h5>Características</h5>
            <ul class="list-inline">
            <%
                PreparedStatement psCar = con.prepareStatement(
                    "SELECT ca.nombre, pc.cantidad FROM propiedad_caracteristica pc " +
                    "JOIN caracteristica ca ON ca.id_caracteristica = pc.id_caracteristica WHERE pc.id_propiedad = ?");
                psCar.setInt(1, idPropiedad);
                ResultSet rsCar = psCar.executeQuery();
                boolean hayCar = false;
                while (rsCar.next()) {
                    hayCar = true;
            %>
                <li class="list-inline-item badge bg-light text-dark border mb-1">
                    <i class="bi bi-check2-circle text-success"></i> <%= esc(rsCar.getString("nombre")) %>
                    <% if (rsCar.getInt("cantidad") > 1) { %>(x<%= rsCar.getInt("cantidad") %>)<% } %>
                </li>
            <%
                }
                if (!hayCar) { %><li class="text-muted">Sin características registradas.</li><% }
                cerrar(rsCar, psCar);
            %>
            </ul>
        </div>

        <div class="col-md-5">
            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <% if (rs.getObject("precio_venta") != null) { %>
                        <p class="fs-4 fw-bold text-primary mb-1">Venta: <%= moneda(rs.getDouble("precio_venta")) %></p>
                    <% } %>
                    <% if (rs.getObject("precio_arriendo") != null) { %>
                        <p class="fs-5 fw-bold text-primary">Arriendo: <%= moneda(rs.getDouble("precio_arriendo")) %>/mes</p>
                    <% } %>
                    <hr>
                    <p class="mb-1"><i class="bi bi-door-closed"></i> <%= rs.getInt("habitaciones") %> habitaciones</p>
                    <p class="mb-1"><i class="bi bi-droplet"></i> <%= rs.getInt("banos") %> baños</p>
                    <p class="mb-1"><i class="bi bi-rulers"></i> <%= rs.getDouble("area_construida") %> m² construidos</p>
                    <% if (rs.getBoolean("parqueadero")) { %><p class="mb-1"><i class="bi bi-p-square"></i> Con parqueadero</p><% } %>
                </div>
            </div>

            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6><i class="bi bi-buildings"></i> <%= esc(rs.getString("razon_social")) %></h6>
                    <% if (rolSesion != null) { %>
                        <p class="mb-1"><i class="bi bi-telephone"></i> <%= esc(rs.getString("tel_inmobiliaria")) %></p>
                        <p class="mb-0"><i class="bi bi-envelope"></i> <%= esc(rs.getString("email_inmobiliaria")) %></p>
                    <% } else { %>
                        <p class="text-muted small mb-0">
                            <a href="<%= ctx %>/login.jsp">Inicia sesión</a> para ver los datos de contacto completos.
                        </p>
                    <% } %>
                </div>
            </div>

            <% if ("Cliente".equalsIgnoreCase((String) rolSesion)) { %>
                <div class="d-grid gap-2">
                    <form action="<%= ctx %>/cliente/acciones.jsp" method="post">
                        <input type="hidden" name="accion" value="agregar_favorito">
                        <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                        <button type="submit" class="btn btn-outline-danger w-100"><i class="bi bi-heart"></i> Agregar a favoritos</button>
                    </form>
                    <a href="<%= ctx %>/cliente/agendar_cita.jsp?id_propiedad=<%= idPropiedad %>" class="btn btn-primary w-100">
                        <i class="bi bi-calendar-plus"></i> Agendar visita
                    </a>
                    <a href="<%= ctx %>/cliente/nueva_solicitud.jsp?id_propiedad=<%= idPropiedad %>" class="btn btn-success w-100">
                        <i class="bi bi-file-earmark-plus"></i> Radicar solicitud
                    </a>
                </div>
            <% } else if (rolSesion == null) { %>
                <div class="alert alert-info text-center">
                    <a href="<%= ctx %>/login.jsp">Inicia sesión</a> como cliente para agendar visitas o guardar favoritos.
                </div>
            <% } %>
        </div>
    </div>
<%
        }
    } catch (SQLException e) {
%>
    <div class="alert alert-danger">Error al cargar la propiedad: <%= esc(e.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
%>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
