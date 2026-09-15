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

    String tabla =
        request.getParameter("tabla");

    String nombre =
        request.getParameter("nombre");


    if (nombre == null ||
        nombre.trim().isEmpty()) {

        response.sendRedirect(
            ctx + "/admin/catalogos.jsp?error=1"
        );

        return;
    }


    /*
     * Lista blanca.
     *
     * Nunca concatenamos directamente una tabla
     * enviada por el navegador sin comprobarla.
     */
    if (!"ciudad".equals(tabla) &&
        !"tipo_propiedad".equals(tabla) &&
        !"caracteristica".equals(tabla)) {

        response.sendRedirect(
            ctx + "/admin/catalogos.jsp?error=1"
        );

        return;
    }


    Connection con = null;
    PreparedStatement ps = null;


    try {

        con = abrirConexion();


        /* =========================================================
           CIUDAD
           ========================================================= */

        if ("ciudad".equals(tabla)) {

            String departamento =
                request.getParameter("departamento");


            if (departamento == null ||
                departamento.trim().isEmpty()) {

                response.sendRedirect(
                    ctx + "/admin/catalogos.jsp?error=1"
                );

                return;
            }


            ps = con.prepareStatement(

                "INSERT INTO ciudad " +
                "(nombre, departamento) " +
                "VALUES (?, ?)"

            );


            ps.setString(
                1,
                nombre.trim()
            );


            ps.setString(
                2,
                departamento.trim()
            );


        /* =========================================================
           TIPO DE PROPIEDAD
           ========================================================= */

        } else if ("tipo_propiedad".equals(tabla)) {


            ps = con.prepareStatement(

                "INSERT INTO tipo_propiedad " +
                "(nombre) " +
                "VALUES (?)"

            );


            ps.setString(
                1,
                nombre.trim()
            );


        /* =========================================================
           CARACTERÍSTICA
           ========================================================= */

        } else {


            ps = con.prepareStatement(

                "INSERT INTO caracteristica " +
                "(nombre) " +
                "VALUES (?)"

            );


            ps.setString(
                1,
                nombre.trim()
            );

        }


        ps.executeUpdate();


        response.sendRedirect(
            ctx + "/admin/catalogos.jsp?ok=1"
        );


    } catch (
        SQLIntegrityConstraintViolationException e
    ) {


        response.sendRedirect(
            ctx + "/admin/catalogos.jsp?error=1"
        );


    } catch (SQLException e) {


        response.sendRedirect(
            ctx + "/admin/catalogos.jsp?error=1"
        );


    } finally {

        cerrar(ps, con);

    }

%>