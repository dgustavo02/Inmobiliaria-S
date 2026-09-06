<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>

<%-- Título dinámico para la cabecera --%>
<% request.setAttribute("tituloPagina", "Portal Inmobiliario - Inicio"); %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row mb-4">
    <div class="col-12 text-center">
        <h1 class="fw-bold">Propiedades Disponibles</h1>
        <p class="text-muted">Encuentra tu próximo hogar o inversión inmobiliaria</p>
    </div>
</div>

<div class="row g-4" id="inmuebles">
<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = abrirConexion();

        // Consulta que trae propiedades disponibles con su ciudad, tipo e imagen principal
        String sql = "SELECT p.id_propiedad, p.titulo, p.precio_venta, p.precio_arriendo, "
                   + "p.habitaciones, p.banos, p.area_construida, p.barrio, "
                   + "c.nombre AS ciudad, tp.nombre AS tipo, "
                   + "img.ruta AS imagen "
                   + "FROM propiedad p "
                   + "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad "
                   + "INNER JOIN tipo_propiedad tp ON p.id_tipo = tp.id_tipo "
                   + "LEFT JOIN imagen_propiedad img ON p.id_propiedad = img.id_propiedad AND img.es_principal = TRUE "
                   + "WHERE p.estado_propiedad = 'DISPONIBLE' "
                   + "ORDER BY p.fecha_publicacion DESC";

        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();

        boolean hayPropiedades = false;

        while (rs.next()) {
            hayPropiedades = true;
            String imagen = rs.getString("imagen");
            if (imagen == null || imagen.isEmpty()) {
                // Imagen por defecto si la propiedad no tiene foto cargada
                imagen = "https://via.placeholder.com/600x400?text=Sin+Imagen";
            }
%>
    <div class="col-md-6 col-lg-4">
        <div class="card h-100 shadow-sm border-0">
            <img src="<%= imagen %>" class="card-img-top" alt="<%= rs.getString("titulo") %>" style="height: 220px; object-fit: cover;">
            <div class="card-body">
                <span class="badge bg-danger mb-2"><%= rs.getString("tipo") %></span>
                <h5 class="card-title fw-bold text-dark"><%= rs.getString("titulo") %></h5>
                <p class="text-muted small mb-2">
                    <i class="fa-solid fa-location-dot text-secondary"></i> <%= rs.getString("barrio") %>, <%= rs.getString("ciudad") %>
                </p>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <% if (rs.getBigDecimal("precio_venta") != null) { %>
                        <span class="fw-bold fs-5 text-primary">
                            $<%= String.format("%,.0f", rs.getBigDecimal("precio_venta")) %>
                        </span>
                    <% } else if (rs.getBigDecimal("precio_arriendo") != null) { %>
                        <span class="fw-bold fs-5 text-success">
                            $<%= String.format("%,.0f", rs.getBigDecimal("precio_arriendo")) %>/mes
                        </span>
                    <% } %>
                </div>

                <div class="d-flex justify-content-around border-top pt-2 text-muted small">
                    <span><i class="fa-solid fa-bed"></i> <%= rs.getInt("habitaciones") %> Hab.</span>
                    <span><i class="fa-solid fa-bath"></i> <%= rs.getInt("banos") %> Baños</span>
                    <span><i class="fa-solid fa-ruler-combined"></i> <%= rs.getBigDecimal("area_construida") %> m²</span>
                </div>
            </div>
            <div class="card-footer bg-white border-0 pb-3">
                <a href="detalle_propiedad.jsp?id=<%= rs.getInt("id_propiedad") %>" class="btn btn-outline-danger w-100 fw-bold">
                    Ver Detalles
                </a>
            </div>
        </div>
    </div>
<%
        }

        if (!hayPropiedades) {
%>
    <div class="col-12 text-center py-5">
        <div class="alert alert-info border-0 shadow-sm">
            <h4 class="alert-heading">No hay propiedades disponibles</h4>
            <p class="mb-0">Aún no se han registrado inmuebles en el sistema o no hay publicados actualmente.</p>
        </div>
    </div>
<%
        }

    } catch (SQLException ex) {
%>
    <div class="col-12">
        <div class="alert alert-danger">
            <strong>Error al cargar el catálogo:</strong> <%= ex.getMessage() %>
        </div>
    </div>
<%
    } finally {
        cerrar(rs, ps, con);
    }
%>
</div>

</main>

<footer class="bg-dark text-white text-center py-3 mt-5">
    <div class="container">
        <small>&copy; 2026 Portal Inmobiliario. Todos los derechos reservados.</small>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>