<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%
    if (!validarSesion(request, response, "Administrador")) {
        return;
    }

    String tituloPagina = "Catálogos";
    String ctx = request.getContextPath();

    Connection con = null;
    Statement st = null;
    ResultSet rs = null;
%>

<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>


<div class="d-flex justify-content-between align-items-center mb-4">

    <div>
        <h3 class="mb-1">
            <i class="bi bi-tags"></i>
            Catálogos
        </h3>

        <p class="text-muted mb-0">
            Administración de ciudades, tipos de propiedad y características.
        </p>
    </div>

</div>


<% if ("1".equals(request.getParameter("ok"))) { %>

    <div class="alert alert-success alert-dismissible fade show" role="alert">

        <i class="bi bi-check-circle me-1"></i>

        El registro fue guardado correctamente.

        <button type="button"
                class="btn-close"
                data-bs-dismiss="alert"></button>

    </div>

<% } %>


<% if ("1".equals(request.getParameter("error"))) { %>

    <div class="alert alert-danger alert-dismissible fade show" role="alert">

        <i class="bi bi-exclamation-triangle me-1"></i>

        Ya existe un registro con ese nombre o no fue posible guardar la información.

        <button type="button"
                class="btn-close"
                data-bs-dismiss="alert"></button>

    </div>

<% } %>


<div class="row g-4">


    <!-- ============================================================
         CIUDADES
         ============================================================ -->

    <div class="col-md-4">

        <div class="card shadow-sm h-100">

            <div class="card-header bg-primary text-white">

                <i class="bi bi-geo-alt me-1"></i>

                Ciudades

            </div>

            <div class="card-body">

                <form
                    action="<%= ctx %>/admin/guardar_catalogo.jsp"
                    method="post"
                    class="row g-2 mb-3">

                    <input type="hidden"
                           name="tabla"
                           value="ciudad">


                    <div class="col-6">

                        <input
                            type="text"
                            name="nombre"
                            class="form-control form-control-sm"
                            placeholder="Ciudad"
                            maxlength="100"
                            required>

                    </div>


                    <div class="col-6">

                        <input
                            type="text"
                            name="departamento"
                            class="form-control form-control-sm"
                            placeholder="Departamento"
                            maxlength="100"
                            required>

                    </div>


                    <div class="col-12">

                        <button
                            type="submit"
                            class="btn btn-sm btn-primary w-100">

                            <i class="bi bi-plus-circle me-1"></i>

                            Agregar ciudad

                        </button>

                    </div>

                </form>


                <ul class="list-group list-group-flush">

                <%
                    try {

                        con = abrirConexion();

                        st = con.createStatement();

                        /*
                         * ciudad SÍ tiene columna estado.
                         */
                        rs = st.executeQuery(
                            "SELECT nombre, departamento " +
                            "FROM ciudad " +
                            "WHERE estado = 1 " +
                            "ORDER BY nombre"
                        );

                        while (rs.next()) {
                %>

                    <li class="list-group-item px-0 py-2">

                        <i class="bi bi-geo-alt text-primary me-1"></i>

                        <%= esc(rs.getString("nombre")) %>,

                        <span class="text-muted">
                            <%= esc(rs.getString("departamento")) %>
                        </span>

                    </li>

                <%
                        }

                    } catch (SQLException e) {
                %>

                    <li class="list-group-item text-danger">

                        Error al consultar ciudades:

                        <%= esc(e.getMessage()) %>

                    </li>

                <%
                    } finally {

                        cerrar(rs, st, con);

                        rs = null;
                        st = null;
                        con = null;
                    }
                %>

                </ul>

            </div>

        </div>

    </div>


    <!-- ============================================================
         TIPOS DE PROPIEDAD
         ============================================================ -->

    <div class="col-md-4">

        <div class="card shadow-sm h-100">

            <div class="card-header bg-primary text-white">

                <i class="bi bi-building me-1"></i>

                Tipos de propiedad

            </div>

            <div class="card-body">

                <form
                    action="<%= ctx %>/admin/guardar_catalogo.jsp"
                    method="post"
                    class="row g-2 mb-3">

                    <input type="hidden"
                           name="tabla"
                           value="tipo_propiedad">


                    <div class="col-9">

                        <input
                            type="text"
                            name="nombre"
                            class="form-control form-control-sm"
                            placeholder="Ej. Apartamento"
                            maxlength="50"
                            required>

                    </div>


                    <div class="col-3">

                        <button
                            type="submit"
                            class="btn btn-sm btn-primary w-100">

                            <i class="bi bi-plus-lg"></i>

                        </button>

                    </div>

                </form>


                <ul class="list-group list-group-flush">

                <%
                    try {

                        con = abrirConexion();

                        st = con.createStatement();

                        /*
                         * IMPORTANTE:
                         * tipo_propiedad NO tiene columna estado.
                         */
                        rs = st.executeQuery(
                            "SELECT nombre " +
                            "FROM tipo_propiedad " +
                            "ORDER BY nombre"
                        );

                        while (rs.next()) {
                %>

                    <li class="list-group-item px-0 py-2">

                        <i class="bi bi-house text-primary me-1"></i>

                        <%= esc(rs.getString("nombre")) %>

                    </li>

                <%
                        }

                    } catch (SQLException e) {
                %>

                    <li class="list-group-item text-danger">

                        Error al consultar tipos:

                        <%= esc(e.getMessage()) %>

                    </li>

                <%
                    } finally {

                        cerrar(rs, st, con);

                        rs = null;
                        st = null;
                        con = null;
                    }
                %>

                </ul>

            </div>

        </div>

    </div>


    <!-- ============================================================
         CARACTERÍSTICAS
         ============================================================ -->

    <div class="col-md-4">

        <div class="card shadow-sm h-100">

            <div class="card-header bg-primary text-white">

                <i class="bi bi-stars me-1"></i>

                Características

            </div>

            <div class="card-body">

                <form
                    action="<%= ctx %>/admin/guardar_catalogo.jsp"
                    method="post"
                    class="row g-2 mb-3">

                    <input type="hidden"
                           name="tabla"
                           value="caracteristica">


                    <div class="col-9">

                        <input
                            type="text"
                            name="nombre"
                            class="form-control form-control-sm"
                            placeholder="Ej. Piscina"
                            maxlength="100"
                            required>

                    </div>


                    <div class="col-3">

                        <button
                            type="submit"
                            class="btn btn-sm btn-primary w-100">

                            <i class="bi bi-plus-lg"></i>

                        </button>

                    </div>

                </form>


                <ul class="list-group list-group-flush">

                <%
                    try {

                        con = abrirConexion();

                        st = con.createStatement();

                        /*
                         * IMPORTANTE:
                         * caracteristica NO tiene columna estado.
                         */
                        rs = st.executeQuery(
                            "SELECT nombre " +
                            "FROM caracteristica " +
                            "ORDER BY nombre"
                        );

                        while (rs.next()) {
                %>

                    <li class="list-group-item px-0 py-2">

                        <i class="bi bi-check2-circle text-primary me-1"></i>

                        <%= esc(rs.getString("nombre")) %>

                    </li>

                <%
                        }

                    } catch (SQLException e) {
                %>

                    <li class="list-group-item text-danger">

                        Error al consultar características:

                        <%= esc(e.getMessage()) %>

                    </li>

                <%
                    } finally {

                        cerrar(rs, st, con);

                        rs = null;
                        st = null;
                        con = null;
                    }
                %>

                </ul>

            </div>

        </div>

    </div>

</div>


<%@ include file="/WEB-INF/jspf/pie.jspf" %>