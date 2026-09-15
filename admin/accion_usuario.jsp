<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%
    if (!validarSesion(request, response, "Administrador")) {
        return;
    }

    String ctx = request.getContextPath();

    Integer idAdminObj =
        (Integer) session.getAttribute("idUsuario");

    if (idAdminObj == null) {
        response.sendRedirect(ctx + "/login.jsp");
        return;
    }

    int idAdmin = idAdminObj;

    String accion = request.getParameter("accion");

    int idUsuarioObjetivo =
        aEntero(
            request.getParameter("id_usuario"),
            0
        );


    if (idUsuarioObjetivo <= 0) {

        response.sendRedirect(
            ctx + "/admin/usuarios.jsp?error=1"
        );

        return;
    }


    Connection con = null;
    PreparedStatement ps = null;


    try {

        con = abrirConexion();

        con.setAutoCommit(false);


        String nombreAccion;


        /* =========================================================
           ASIGNAR ROL
           ========================================================= */

        if ("asignar_rol".equals(accion)) {

            int idRol =
                aEntero(
                    request.getParameter("id_rol"),
                    0
                );


            if (idRol <= 0) {

                throw new SQLException(
                    "Debe seleccionar un rol válido."
                );

            }


            /*
             * usuario_rol tiene:
             * id_usuario
             * id_rol
             * fecha_asignacion
             * asignado_por
             * estado
             *
             * No tiene columna ip.
             */
            ps = con.prepareStatement(

                "INSERT INTO usuario_rol " +
                "(id_usuario, id_rol, asignado_por, estado) " +
                "VALUES (?, ?, ?, 'ACTIVO') " +
                "ON DUPLICATE KEY UPDATE " +
                "estado = 'ACTIVO', " +
                "asignado_por = VALUES(asignado_por), " +
                "fecha_asignacion = NOW()"

            );


            ps.setInt(1, idUsuarioObjetivo);
            ps.setInt(2, idRol);
            ps.setInt(3, idAdmin);

            ps.executeUpdate();

            cerrar(ps);

            ps = null;

            nombreAccion = "ASIGNAR_ROL";


        /* =========================================================
           ACTIVAR
           ========================================================= */

        } else if ("activar".equals(accion)) {


            ps = con.prepareStatement(

                "UPDATE usuario " +
                "SET estado_cuenta = 'ACTIVA', " +
                "intentos_fallidos = 0, " +
                "fecha_bloqueo = NULL " +
                "WHERE id_usuario = ?"

            );


            ps.setInt(1, idUsuarioObjetivo);

            ps.executeUpdate();

            cerrar(ps);

            ps = null;

            nombreAccion = "ACTIVAR_CUENTA";


        /* =========================================================
           INACTIVAR
           ========================================================= */

        } else if ("inactivar".equals(accion)) {


            ps = con.prepareStatement(

                "UPDATE usuario " +
                "SET estado_cuenta = 'INACTIVA' " +
                "WHERE id_usuario = ?"

            );


            ps.setInt(1, idUsuarioObjetivo);

            ps.executeUpdate();

            cerrar(ps);

            ps = null;

            nombreAccion = "INACTIVAR_CUENTA";


        } else {


            deshacer(con);

            response.sendRedirect(
                ctx + "/admin/usuarios.jsp?error=1"
            );

            return;
        }


        /* =========================================================
           AUDITORÍA
           ========================================================= */

        String userAgent =
            request.getHeader("User-Agent");


        if (userAgent == null ||
            userAgent.trim().isEmpty()) {

            userAgent = "desconocido";

        }


        if (userAgent.length() > 255) {

            userAgent =
                userAgent.substring(0, 255);

        }


        /*
         * La tabla auditoria NO tiene columna ip.
         * Sí tiene user_agent y detalle_despues.
         */
        ps = con.prepareStatement(

            "INSERT INTO auditoria " +
            "(id_usuario, user_agent, accion, " +
            "tabla_afectada, registro_id, detalle_despues) " +
            "VALUES (?, ?, ?, 'usuario', ?, ?)"

        );


        ps.setInt(1, idAdmin);

        ps.setString(2, userAgent);

        ps.setString(3, nombreAccion);

        ps.setInt(4, idUsuarioObjetivo);


        String detalle =
            "{\"accion\":\"" +
            nombreAccion +
            "\",\"usuario_objetivo\":" +
            idUsuarioObjetivo +
            "}";


        ps.setString(5, detalle);

        ps.executeUpdate();

        cerrar(ps);

        ps = null;


        con.commit();


        response.sendRedirect(
            ctx + "/admin/usuarios.jsp?ok=1"
        );


    } catch (Exception e) {


        deshacer(con);

        response.setContentType(
            "text/html;charset=UTF-8"
        );

%>

<!DOCTYPE html>

<html lang="es">

<head>

    <meta charset="UTF-8">

    <title>Error</title>

    <link
        href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.3/css/bootstrap.min.css"
        rel="stylesheet">

</head>

<body class="bg-light">

    <div class="container py-5">

        <div class="alert alert-danger">

            <h5 class="alert-heading">

                <i class="bi bi-exclamation-triangle me-1"></i>

                Ocurrió un error

            </h5>


            <p class="mb-2">

                <%= esc(e.getMessage()) %>

            </p>


            <a
                href="<%= ctx %>/admin/usuarios.jsp"
                class="btn btn-outline-danger">

                Volver a usuarios

            </a>

        </div>

    </div>

</body>

</html>

<%

    } finally {

        cerrar(ps, con);

    }

%>