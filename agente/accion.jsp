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

    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        if ("confirmar_cita".equals(accion)) {
            int idCita = aEntero(request.getParameter("id_cita"), 0);
            ps = con.prepareStatement(
                "UPDATE cita SET estado = 'CONFIRMADA', fecha_confirmacion = NOW() " +
                "WHERE id_cita = ? AND id_agente = ? AND estado = 'SOLICITADA'");
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/agente/citas.jsp?ok=1");
            return;

        } else if ("realizar_cita".equals(accion)) {
            int idCita = aEntero(request.getParameter("id_cita"), 0);
            ps = con.prepareStatement(
                "UPDATE cita SET estado = 'REALIZADA' WHERE id_cita = ? AND id_agente = ? AND estado IN ('SOLICITADA','CONFIRMADA')");
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/agente/citas.jsp?ok=1");
            return;

        } else if ("cancelar_cita".equals(accion)) {
            int idCita = aEntero(request.getParameter("id_cita"), 0);
            ps = con.prepareStatement(
                "UPDATE cita SET estado = 'CANCELADA' WHERE id_cita = ? AND id_agente = ? AND estado IN ('SOLICITADA','CONFIRMADA')");
            ps.setInt(1, idCita);
            ps.setInt(2, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/agente/citas.jsp?ok=1");
            return;

        } else if ("aprobar_solicitud".equals(accion)) {
            int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
            ps = con.prepareStatement(
                "UPDATE solicitud SET estado = 'APROBADA', fecha_resolucion = NOW(), resuelto_por = ? " +
                "WHERE id_solicitud = ? AND id_agente = ? AND estado IN ('RADICADA','EN_REVISION')");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idSolicitud);
            ps.setInt(3, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/agente/solicitudes.jsp?ok=1");
            return;

        } else if ("rechazar_solicitud".equals(accion)) {
            int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
            ps = con.prepareStatement(
                "UPDATE solicitud SET estado = 'RECHAZADA', fecha_resolucion = NOW(), resuelto_por = ? " +
                "WHERE id_solicitud = ? AND id_agente = ? AND estado IN ('RADICADA','EN_REVISION')");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idSolicitud);
            ps.setInt(3, idUsuario);
            ps.executeUpdate();
            con.commit();
            response.sendRedirect(ctx + "/agente/solicitudes.jsp?ok=1");
            return;

        } else if ("firmar_contrato".equals(accion)) {
            int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
            String numeroContrato = request.getParameter("numero_contrato").trim();

            ps = con.prepareStatement(
                "UPDATE solicitud SET estado = 'CONTRATO_FIRMADO', numero_contrato = ?, " +
                "valor_acordado = monto_ofrecido, fecha_firma = NOW() " +
                "WHERE id_solicitud = ? AND id_agente = ? AND estado = 'APROBADA'");
            ps.setString(1, numeroContrato);
            ps.setInt(2, idSolicitud);
            ps.setInt(3, idUsuario);
            ps.executeUpdate();

            // Al firmarse el contrato, la propiedad pasa a vendida o arrendada según el tipo de solicitud
            ps.close();
            ps = con.prepareStatement(
                "UPDATE propiedad p JOIN solicitud s ON s.id_propiedad = p.id_propiedad " +
                "SET p.estado_propiedad = IF(s.tipo = 'COMPRA', 'VENDIDA', 'ARRENDADA') " +
                "WHERE s.id_solicitud = ?");
            ps.setInt(1, idSolicitud);
            ps.executeUpdate();

            con.commit();
            response.sendRedirect(ctx + "/agente/solicitudes.jsp?ok=1");
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
        cerrar(ps, con);
    }
%>
