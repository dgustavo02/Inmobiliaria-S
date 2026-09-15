<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Inmobiliaria")) { return; } %>
<%
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");
    String accion = request.getParameter("accion");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        // Resolver el id_inmobiliaria del agente en sesión (se usa en crear/actualizar)
        Integer idInmobiliaria = null;
        if ("crear".equals(accion) || "actualizar".equals(accion)) {
            ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();
            if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
            cerrar(rs, ps);
            if (idInmobiliaria == null) {
                deshacer(con);
                response.sendRedirect(ctx + "/panel.jsp?error=sin_permiso");
                return;
            }
        }

        if ("crear".equals(accion) || "actualizar".equals(accion)) {
            String matricula = request.getParameter("matricula_inmobiliaria").trim();
            String titulo = request.getParameter("titulo").trim();
            String descripcion = request.getParameter("descripcion").trim();
            String direccion = request.getParameter("direccion").trim();
            String barrio = request.getParameter("barrio").trim();
            String estrato = request.getParameter("estrato");
            if (estrato != null && estrato.trim().isEmpty()) estrato = null;
            int idTipo = aEntero(request.getParameter("id_tipo"), 0);
            int idCiudad = aEntero(request.getParameter("id_ciudad"), 0);

            String precioVentaParam = request.getParameter("precio_venta");
            String precioArriendoParam = request.getParameter("precio_arriendo");
            Double precioVenta = (precioVentaParam != null && !precioVentaParam.trim().isEmpty()) ? aDoble(precioVentaParam, 0) : null;
            Double precioArriendo = (precioArriendoParam != null && !precioArriendoParam.trim().isEmpty()) ? aDoble(precioArriendoParam, 0) : null;

            double areaConstruida = aDoble(request.getParameter("area_construida"), 0);
            double areaTerreno = aDoble(request.getParameter("area_terreno"), 0);
            int habitaciones = aEntero(request.getParameter("habitaciones"), 0);
            int banos = aEntero(request.getParameter("banos"), 0);
            boolean parqueadero = "on".equals(request.getParameter("parqueadero"));

            if (precioVenta == null && precioArriendo == null) {
                deshacer(con);
                response.sendRedirect(ctx + "/agente/propiedad_form.jsp?error=precio" +
                    ("actualizar".equals(accion) ? "&id=" + request.getParameter("id_propiedad") : ""));
                return;
            }

            if ("crear".equals(accion)) {
                ps = con.prepareStatement(
                    "INSERT INTO propiedad (id_inmobiliaria, id_tipo, id_ciudad, matricula_inmobiliaria, titulo, " +
                    "descripcion, direccion, barrio, estrato, precio_venta, precio_arriendo, area_construida, " +
                    "area_terreno, habitaciones, banos, parqueadero) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, idInmobiliaria);
                ps.setInt(2, idTipo);
                ps.setInt(3, idCiudad);
                ps.setString(4, matricula);
                ps.setString(5, titulo);
                ps.setString(6, descripcion);
                ps.setString(7, direccion);
                ps.setString(8, barrio);
                ps.setString(9, estrato);
                if (precioVenta != null) ps.setDouble(10, precioVenta); else ps.setNull(10, Types.DECIMAL);
                if (precioArriendo != null) ps.setDouble(11, precioArriendo); else ps.setNull(11, Types.DECIMAL);
                ps.setDouble(12, areaConstruida);
                ps.setDouble(13, areaTerreno);
                ps.setInt(14, habitaciones);
                ps.setInt(15, banos);
                ps.setBoolean(16, parqueadero);
                ps.executeUpdate();

                ResultSet claves = ps.getGeneratedKeys();
                int idNueva = 0;
                if (claves.next()) idNueva = claves.getInt(1);
                cerrar(claves, ps);

                con.commit();
                response.sendRedirect(ctx + "/agente/propiedad_form.jsp?id=" + idNueva + "&ok=1");
                return;

            } else {
                int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
                ps = con.prepareStatement(
                    "UPDATE propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                    "SET p.id_tipo = ?, p.id_ciudad = ?, p.matricula_inmobiliaria = ?, p.titulo = ?, p.descripcion = ?, " +
                    "    p.direccion = ?, p.barrio = ?, p.estrato = ?, p.precio_venta = ?, p.precio_arriendo = ?, " +
                    "    p.area_construida = ?, p.area_terreno = ?, p.habitaciones = ?, p.banos = ?, p.parqueadero = ? " +
                    "WHERE p.id_propiedad = ? AND i.id_usuario = ?");
                ps.setInt(1, idTipo);
                ps.setInt(2, idCiudad);
                ps.setString(3, matricula);
                ps.setString(4, titulo);
                ps.setString(5, descripcion);
                ps.setString(6, direccion);
                ps.setString(7, barrio);
                ps.setString(8, estrato);
                if (precioVenta != null) ps.setDouble(9, precioVenta); else ps.setNull(9, Types.DECIMAL);
                if (precioArriendo != null) ps.setDouble(10, precioArriendo); else ps.setNull(10, Types.DECIMAL);
                ps.setDouble(11, areaConstruida);
                ps.setDouble(12, areaTerreno);
                ps.setInt(13, habitaciones);
                ps.setInt(14, banos);
                ps.setBoolean(15, parqueadero);
                ps.setInt(16, idPropiedad);
                ps.setInt(17, idUsuario);
                ps.executeUpdate();

                con.commit();
                response.sendRedirect(ctx + "/agente/propiedad_form.jsp?id=" + idPropiedad + "&ok=1");
                return;
            }

        } else if ("dar_de_baja".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            ps = con.prepareStatement(
                "UPDATE propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
                "SET p.estado_propiedad = 'INACTIVA' WHERE p.id_propiedad = ? AND i.id_usuario = ?");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/agente/propiedades.jsp?ok=1");
            return;

        } else if ("agregar_imagen".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            String ruta = request.getParameter("ruta").trim();

            if (!propiedadEsDelAgente(con, idPropiedad, idUsuario)) {
                deshacer(con);
                response.sendRedirect(ctx + "/agente/propiedades.jsp?error=sin_permiso");
                return;
            }

            ps = con.prepareStatement(
                "INSERT INTO imagen_propiedad (id_propiedad, ruta, nombre_original) VALUES (?, ?, ?)");
            ps.setInt(1, idPropiedad);
            ps.setString(2, ruta);
            ps.setString(3, ruta.substring(ruta.lastIndexOf('/') + 1));
            ps.executeUpdate();

            con.commit();
            response.sendRedirect(ctx + "/agente/propiedad_form.jsp?id=" + idPropiedad + "&ok=1");
            return;

        } else if ("quitar_imagen".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            int idImagen = aEntero(request.getParameter("id_imagen"), 0);

            if (!propiedadEsDelAgente(con, idPropiedad, idUsuario)) {
                deshacer(con);
                response.sendRedirect(ctx + "/agente/propiedades.jsp?error=sin_permiso");
                return;
            }

            ps = con.prepareStatement("DELETE FROM imagen_propiedad WHERE id_imagen = ? AND id_propiedad = ?");
            ps.setInt(1, idImagen);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();

            con.commit();
            response.sendRedirect(ctx + "/agente/propiedad_form.jsp?id=" + idPropiedad + "&ok=1");
            return;

        } else if ("guardar_caracteristicas".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            String[] seleccionadas = request.getParameterValues("caracteristicas");

            if (!propiedadEsDelAgente(con, idPropiedad, idUsuario)) {
                deshacer(con);
                response.sendRedirect(ctx + "/agente/propiedades.jsp?error=sin_permiso");
                return;
            }

            ps = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);

            if (seleccionadas != null) {
                ps = con.prepareStatement(
                    "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica) VALUES (?, ?)");
                for (String idCar : seleccionadas) {
                    ps.setInt(1, idPropiedad);
                    ps.setInt(2, aEntero(idCar, 0));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            con.commit();
            response.sendRedirect(ctx + "/agente/propiedad_form.jsp?id=" + idPropiedad + "&ok=1");
            return;

        } else {
            deshacer(con);
            response.sendRedirect(ctx + "/agente/propiedades.jsp");
            return;
        }

    } catch (SQLIntegrityConstraintViolationException e) {
        deshacer(con);
        String idParam = request.getParameter("id_propiedad");
        response.sendRedirect(ctx + "/agente/propiedad_form.jsp?error=matricula" + (idParam != null ? "&id=" + idParam : ""));

    } catch (Exception e) {
        deshacer(con);
        response.setContentType("text/html;charset=UTF-8");
%>
    <div class="alert alert-danger m-4">
        Ocurrió un error al guardar: <%= esc(e.getMessage()) %>
        <br><a href="<%= ctx %>/agente/propiedades.jsp">Volver</a>
    </div>
<%
    } finally {
        cerrar(rs, ps, con);
    }
%>
<%!
    // Verifica que la propiedad pertenezca a la inmobiliaria del usuario en sesión,
    // para que un agente no pueda editar imágenes/características de otro.
    private boolean propiedadEsDelAgente(Connection con, int idPropiedad, int idUsuario) throws SQLException {
        PreparedStatement ps = con.prepareStatement(
            "SELECT 1 FROM propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria " +
            "WHERE p.id_propiedad = ? AND i.id_usuario = ?");
        ps.setInt(1, idPropiedad);
        ps.setInt(2, idUsuario);
        ResultSet rs = ps.executeQuery();
        boolean existe = rs.next();
        rs.close();
        ps.close();
        return existe;
    }
%>
