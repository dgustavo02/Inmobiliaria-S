<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Inmobiliaria")) { return; } %>
<%
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    boolean esEdicion = idPropiedad > 0;
    String tituloPagina = esEdicion ? "Editar propiedad" : "Nueva propiedad";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-4"><i class="bi bi-building"></i> <%= tituloPagina %></h3>
<% if (request.getParameter("error") != null) { %>
    <div class="alert alert-danger py-2">
        <% if ("matricula".equals(request.getParameter("error"))) { %>
            Ya existe una propiedad con esa matrícula inmobiliaria.
        <% } else { %>
            No se pudo guardar la propiedad.
        <% } %>
    </div>
<% } %>

<%
    // Datos actuales si es edición
    String v_matricula = "", v_titulo = "", v_descripcion = "", v_direccion = "", v_barrio = "", v_estrato = "";
    Object v_precioVenta = null, v_precioArriendo = null;
    double v_areaConstruida = 0, v_areaTerreno = 0;
    int v_habitaciones = 0, v_banos = 0, v_idTipo = 0, v_idCiudad = 0;
    boolean v_parqueadero = false;

    if (esEdicion) {
        try {
            con = abrirConexion();
            ps = con.prepareStatement(
                "SELECT p.* FROM propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "WHERE p.id_propiedad = ? AND i.id_usuario = ?");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            rs = ps.executeQuery();
            if (rs.next()) {
                v_matricula = rs.getString("matricula_inmobiliaria");
                v_titulo = rs.getString("titulo");
                v_descripcion = rs.getString("descripcion");
                v_direccion = rs.getString("direccion");
                v_barrio = rs.getString("barrio");
                v_estrato = rs.getString("estrato");
                v_precioVenta = rs.getObject("precio_venta");
                v_precioArriendo = rs.getObject("precio_arriendo");
                v_areaConstruida = rs.getDouble("area_construida");
                v_areaTerreno = rs.getDouble("area_terreno");
                v_habitaciones = rs.getInt("habitaciones");
                v_banos = rs.getInt("banos");
                v_parqueadero = rs.getBoolean("parqueadero");
                v_idTipo = rs.getInt("id_tipo");
                v_idCiudad = rs.getInt("id_ciudad");
            } else {
%>
    <div class="alert alert-danger">Esa propiedad no existe o no te pertenece.</div>
<%
                cerrar(rs, ps, con);
%>
    <%@ include file="/WEB-INF/jspf/pie.jspf" %>
<%
                return;
            }
        } finally { cerrar(rs, ps); }
    } else {
        con = abrirConexion();
    }
%>

<div class="card mb-4">
    <div class="card-body">
        <form action="<%= ctx %>/agente/guardar_propiedad.jsp" method="post">
            <input type="hidden" name="accion" value="<%= esEdicion ? "actualizar" : "crear" %>">
            <% if (esEdicion) { %><input type="hidden" name="id_propiedad" value="<%= idPropiedad %>"><% } %>

            <div class="row g-2">
                <div class="col-md-4">
                    <label class="form-label">Matrícula inmobiliaria</label>
                    <input type="text" name="matricula_inmobiliaria" class="form-control" value="<%= esc(v_matricula) %>" required>
                </div>
                <div class="col-md-8">
                    <label class="form-label">Título</label>
                    <input type="text" name="titulo" class="form-control" value="<%= esc(v_titulo) %>" required>
                </div>
                <div class="col-12">
                    <label class="form-label">Descripción</label>
                    <textarea name="descripcion" class="form-control" rows="3" required><%= esc(v_descripcion) %></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tipo de propiedad</label>
                    <select name="id_tipo" class="form-select" required>
                        <%
                            Statement st1 = con.createStatement();
                            ResultSet rs1 = st1.executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad WHERE estado = 1 ORDER BY nombre");
                            while (rs1.next()) {
                                boolean sel = rs1.getInt("id_tipo") == v_idTipo;
                        %>
                            <option value="<%= rs1.getInt("id_tipo") %>" <%= sel ? "selected" : "" %>><%= esc(rs1.getString("nombre")) %></option>
                        <%
                            }
                            cerrar(rs1, st1);
                        %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Ciudad</label>
                    <select name="id_ciudad" class="form-select" required>
                        <%
                            Statement st2 = con.createStatement();
                            ResultSet rs2 = st2.executeQuery("SELECT id_ciudad, nombre FROM ciudad WHERE estado = 1 ORDER BY nombre");
                            while (rs2.next()) {
                                boolean sel = rs2.getInt("id_ciudad") == v_idCiudad;
                        %>
                            <option value="<%= rs2.getInt("id_ciudad") %>" <%= sel ? "selected" : "" %>><%= esc(rs2.getString("nombre")) %></option>
                        <%
                            }
                            cerrar(rs2, st2);
                        %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Estrato</label>
                    <select name="estrato" class="form-select">
                        <option value="">N/A</option>
                        <% for (int e = 1; e <= 6; e++) { %>
                            <option value="<%= e %>" <%= String.valueOf(e).equals(v_estrato) ? "selected" : "" %>><%= e %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label">Dirección</label>
                    <input type="text" name="direccion" class="form-control" value="<%= esc(v_direccion) %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Barrio</label>
                    <input type="text" name="barrio" class="form-control" value="<%= esc(v_barrio) %>" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Precio de venta</label>
                    <input type="number" step="0.01" min="0" name="precio_venta" class="form-control"
                           value="<%= v_precioVenta != null ? v_precioVenta : "" %>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Precio de arriendo</label>
                    <input type="number" step="0.01" min="0" name="precio_arriendo" class="form-control"
                           value="<%= v_precioArriendo != null ? v_precioArriendo : "" %>">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Área construida (m²)</label>
                    <input type="number" step="0.01" min="0" name="area_construida" class="form-control" value="<%= v_areaConstruida %>" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Área de terreno (m²)</label>
                    <input type="number" step="0.01" min="0" name="area_terreno" class="form-control" value="<%= v_areaTerreno %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Habitaciones</label>
                    <input type="number" min="0" name="habitaciones" class="form-control" value="<%= v_habitaciones %>">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Baños</label>
                    <input type="number" min="0" name="banos" class="form-control" value="<%= v_banos %>">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input" name="parqueadero" id="parq" <%= v_parqueadero ? "checked" : "" %>>
                        <label class="form-check-label" for="parq">Parqueadero</label>
                    </div>
                </div>
            </div>
            <button type="submit" class="btn btn-primary mt-3">
                <i class="bi bi-save"></i> <%= esEdicion ? "Guardar cambios" : "Publicar propiedad" %>
            </button>
            <a href="<%= ctx %>/agente/propiedades.jsp" class="btn btn-outline-secondary mt-3">Volver</a>
        </form>
    </div>
</div>

<% if (esEdicion) { %>
<div class="row g-4">
    <div class="col-md-6">
        <div class="card">
            <div class="card-header">Imágenes</div>
            <div class="card-body">
                <form action="<%= ctx %>/agente/guardar_propiedad.jsp" method="post" class="row g-2 mb-3">
                    <input type="hidden" name="accion" value="agregar_imagen">
                    <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                    <div class="col-9"><input type="url" name="ruta" class="form-control" placeholder="URL de la imagen" required></div>
                    <div class="col-3"><button class="btn btn-primary w-100">Agregar</button></div>
                </form>
                <div class="row g-2">
                <%
                    PreparedStatement psImg = con.prepareStatement(
                        "SELECT id_imagen, ruta FROM imagen_propiedad WHERE id_propiedad = ? ORDER BY orden");
                    psImg.setInt(1, idPropiedad);
                    ResultSet rsImg = psImg.executeQuery();
                    while (rsImg.next()) {
                %>
                    <div class="col-4 position-relative">
                        <img src="<%= esc(rsImg.getString("ruta")) %>" class="img-fluid rounded">
                        <form action="<%= ctx %>/agente/guardar_propiedad.jsp" method="post">
                            <input type="hidden" name="accion" value="quitar_imagen">
                            <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                            <input type="hidden" name="id_imagen" value="<%= rsImg.getInt("id_imagen") %>">
                            <button class="btn btn-sm btn-danger w-100 mt-1"><i class="bi bi-trash"></i></button>
                        </form>
                    </div>
                <%
                    }
                    cerrar(rsImg, psImg);
                %>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card">
            <div class="card-header">Características</div>
            <div class="card-body">
                <form action="<%= ctx %>/agente/guardar_propiedad.jsp" method="post">
                    <input type="hidden" name="accion" value="guardar_caracteristicas">
                    <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                    <%
                        PreparedStatement psCar = con.prepareStatement(
                            "SELECT ca.id_caracteristica, ca.nombre, " +
                            "  (SELECT COUNT(*) FROM propiedad_caracteristica pc " +
                            "   WHERE pc.id_propiedad = ? AND pc.id_caracteristica = ca.id_caracteristica) AS asignada " +
                            "FROM caracteristica ca WHERE ca.estado = 1 ORDER BY ca.nombre");
                        psCar.setInt(1, idPropiedad);
                        ResultSet rsCar = psCar.executeQuery();
                        while (rsCar.next()) {
                            boolean asignada = rsCar.getInt("asignada") > 0;
                    %>
                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" name="caracteristicas"
                                   value="<%= rsCar.getInt("id_caracteristica") %>" id="car<%= rsCar.getInt("id_caracteristica") %>"
                                   <%= asignada ? "checked" : "" %>>
                            <label class="form-check-label" for="car<%= rsCar.getInt("id_caracteristica") %>">
                                <%= esc(rsCar.getString("nombre")) %>
                            </label>
                        </div>
                    <%
                        }
                        cerrar(rsCar, psCar);
                    %>
                    <button type="submit" class="btn btn-primary mt-3">Guardar características</button>
                </form>
            </div>
        </div>
    </div>
</div>
<% } %>

<% cerrar(con); %>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>
