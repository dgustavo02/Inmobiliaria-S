<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% if (!validarSesion(request, response, "Cliente")) { return; } %>
<%
    String ctx = request.getContextPath();
    int idUsuario = (Integer) session.getAttribute("idUsuario");

    Connection con = null;
    PreparedStatement ps = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "UPDATE perfil SET nombres = ?, apellidos = ?, telefono = ?, direccion = ? WHERE id_usuario = ?");
        ps.setString(1, request.getParameter("nombres").trim());
        ps.setString(2, request.getParameter("apellidos").trim());
        ps.setString(3, request.getParameter("telefono").trim());
        ps.setString(4, request.getParameter("direccion").trim());
        ps.setInt(5, idUsuario);
        ps.executeUpdate();

        session.setAttribute("nombreCompleto",
            request.getParameter("nombres").trim() + " " + request.getParameter("apellidos").trim());

        response.sendRedirect(ctx + "/cliente/perfil.jsp?ok=1");
    } catch (SQLException e) {
        response.sendRedirect(ctx + "/cliente/perfil.jsp");
    } finally {
        cerrar(ps, con);
    }
%>
