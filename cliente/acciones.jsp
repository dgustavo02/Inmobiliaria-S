<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
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

        if ("agregar_favorito".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            ps = con.prepareStatement(
                "INSERT IGNORE INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/propiedad.jsp?id=" + idPropiedad + "&ok=1");
            return;

        } else if ("quitar_favorito".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            ps = con.prepareStatement("DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/cliente/favoritos.jsp");
            return;

        } else if ("agendar_cita".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            String fechaHora = request.getParameter("fecha_hora"); // yyyy-MM-ddTHH:mm
            String comentario = request.getParameter("comentario_cliente");
            boolean acompanante = "on".equals(request.getParameter("requiere_acompanante"));

            ps = con.prepareStatement(
                "SELECT i.id_usuario AS id_agente FROM propiedad p " +
                "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria WHERE p.id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            rs = ps.executeQuery();
            if (!rs.next()) {
                deshacer(con);
                response.sendRedirect(ctx + "/catalogo.jsp");
                return;
            }
            int idAgente = rs.getInt("id_agente");
            cerrar(rs, ps);

            ps = con.prepareStatement(
                "INSERT INTO cita (id_propiedad, id_cliente, id_agente, fecha_hora, comentario_cliente, requiere_acompanante) " +
                "VALUES (?, ?, ?, ?, ?, ?)");
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            ps.setInt(3, idAgente);
            ps.setString(4, fechaHora.replace("T", " ") + ":00");
            ps.setString(5, comentario);
            ps.setBoolean(6, acompanante);
            ps.executeUpdate();

            con.commit();
            response.sendRedirect(ctx + "/cliente/mis_citas.jsp?ok=1");
            return;

        } else if ("cancelar_cita".equals(accion)) {
            int idCita = aEntero(request.getParameter("id_cita"), 0);
            ps = con.prepareStatement(
                "UPDATE cita SET estado = 'CANCELADA' WHERE id_cita = ? AND id_cliente = ? AND estado IN ('SOLICITADA','CONFIRMADA')");
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/cliente/mis_citas.jsp?ok=1");
            return;

        } else if ("crear_solicitud".equals(accion)) {
            int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
            String tipo = request.getParameter("tipo");
            double monto = aDoble(request.getParameter("monto_ofrecido"), 0);
            String comentario = request.getParameter("comentario_cliente");
            String nombreArchivo = request.getParameter("nombre_archivo");
            String urlDocumento = request.getParameter("url_documento");

            ps = con.prepareStatement(
                "SELECT i.id_usuario AS id_agente FROM propiedad p " +
                "JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria WHERE p.id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            rs = ps.executeQuery();
            if (!rs.next()) {
                deshacer(con);
                response.sendRedirect(ctx + "/catalogo.jsp");
                return;
            }
            int idAgente = rs.getInt("id_agente");
            cerrar(rs, ps);

            ps = con.prepareStatement(
                "INSERT INTO solicitud (id_propiedad, id_cliente, id_agente, tipo, monto_ofrecido, comentario_cliente) " +
                "VALUES (?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, idPropiedad);
            ps.setInt(2, idUsuario);
            ps.setInt(3, idAgente);
            ps.setString(4, tipo);
            ps.setDouble(5, monto);
            ps.setString(6, comentario);
            ps.executeUpdate();

            ResultSet claves = ps.getGeneratedKeys();
            int idSolicitudNueva = 0;
            if (claves.next()) idSolicitudNueva = claves.getInt(1);
            cerrar(claves, ps);

            if (urlDocumento != null && !urlDocumento.trim().isEmpty()
                    && nombreArchivo != null && !nombreArchivo.trim().isEmpty()) {
                ps = con.prepareStatement(
                    "INSERT INTO documento_solicitud (id_solicitud, nombre_archivo, url_archivo) VALUES (?, ?, ?)");
                ps.setInt(1, idSolicitudNueva);
                ps.setString(2, nombreArchivo.trim());
                ps.setString(3, urlDocumento.trim());
                ps.executeUpdate();
                cerrar(ps);
            }

            con.commit();
            response.sendRedirect(ctx + "/cliente/mis_solicitudes.jsp?ok=1");
            return;

        } else if ("agregar_documento".equals(accion)) {
            int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
            String nombreArchivo = request.getParameter("nombre_archivo");
            String urlDocumento = request.getParameter("url_documento");

            // Verifica que la solicitud sea del cliente en sesión
            ps = con.prepareStatement("SELECT id_cliente FROM solicitud WHERE id_solicitud = ?");
            ps.setInt(1, idSolicitud);
            rs = ps.executeQuery();
            if (!rs.next() || rs.getInt("id_cliente") != idUsuario) {
                deshacer(con);
                response.sendRedirect(ctx + "/cliente/mis_solicitudes.jsp");
                return;
            }
            cerrar(rs, ps);

            // documento_solicitud es 1:N: cada envío agrega un documento nuevo, no reemplaza el anterior
            ps = con.prepareStatement(
                "INSERT INTO documento_solicitud (id_solicitud, nombre_archivo, url_archivo) VALUES (?, ?, ?)");
            ps.setInt(1, idSolicitud);
            ps.setString(2, nombreArchivo.trim());
            ps.setString(3, urlDocumento.trim());
            ps.executeUpdate();

            con.commit();
            response.sendRedirect(ctx + "/cliente/mis_solicitudes.jsp?ok=1");
            return;

        } else {
            deshacer(con);
            response.sendRedirect(ctx + "/panel.jsp");
            return;
        }

    } catch (Exception e) {
        deshacer(con);
        response.setContentType("text/html;charset=UTF-8");
%>
    <div class="alert alert-danger m-4">
        Ocurrió un error al procesar la acción: <%= esc(e.getMessage()) %>
        <br><a href="<%= ctx %>/panel.jsp">Volver</a>
    </div>
<%
    } finally {
        cerrar(rs, ps, con);
    }
%>
