<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String ctx = request.getContextPath();

    String nombres = request.getParameter("nombres");
    String apellidos = request.getParameter("apellidos");
    String tipoDocumento = request.getParameter("tipo_documento");
    String numeroDocumento = request.getParameter("numero_documento");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    int idCiudad = aEntero(request.getParameter("id_ciudad"), 0);
    String correo = request.getParameter("correo");
    String clave = request.getParameter("clave");

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        ps = con.prepareStatement(
            "INSERT INTO usuario (correo, clave_hash) VALUES (?, ?)",
            Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, correo.trim());
        ps.setString(2, cifrar(clave));
        ps.executeUpdate();

        ResultSet claves = ps.getGeneratedKeys();
        int idUsuarioNuevo = 0;
        if (claves.next()) idUsuarioNuevo = claves.getInt(1);
        cerrar(claves, ps);

        ps = con.prepareStatement(
            "INSERT INTO perfil (id_usuario, nombres, apellidos, tipo_documento, numero_documento, telefono, direccion, id_ciudad) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        ps.setInt(1, idUsuarioNuevo);
        ps.setString(2, nombres.trim());
        ps.setString(3, apellidos.trim());
        ps.setString(4, tipoDocumento);
        ps.setString(5, numeroDocumento.trim());
        ps.setString(6, telefono.trim());
        ps.setString(7, direccion.trim());
        if (idCiudad > 0) ps.setInt(8, idCiudad); else ps.setNull(8, Types.INTEGER);
        ps.executeUpdate();
        cerrar(ps);

        ps = con.prepareStatement(
            "INSERT INTO usuario_rol (id_usuario, id_rol) " +
            "VALUES (?, (SELECT id_rol FROM rol WHERE nombre = 'Cliente'))");
        ps.setInt(1, idUsuarioNuevo);
        ps.executeUpdate();
        cerrar(ps);

        con.commit();
        response.sendRedirect(ctx + "/login.jsp?registro=1");

    } catch (SQLIntegrityConstraintViolationException e) {
        deshacer(con);
        String mensaje = e.getMessage() == null ? "" : e.getMessage();
        String destino;
        if (mensaje.contains("usuario.correo") || mensaje.contains("uk_") && mensaje.contains("correo")) {
            destino = "correo";
        } else if (mensaje.contains("numero_documento")) {
            destino = "documento";
        } else {
            destino = "general";
        }
        response.sendRedirect(ctx + "/registro.jsp?error=" + destino);

    } catch (Exception e) {
        deshacer(con);
        response.sendRedirect(ctx + "/registro.jsp?error=general");

    } finally {
        cerrar(rs, ps, con);
    }
%>
