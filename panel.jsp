<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>

<%
    /*
     * ============================================================
     * COMPROBAR SESIÓN
     * ============================================================
     */

    HttpSession sesion =
        request.getSession(false);


    if (sesion == null
            || sesion.getAttribute("idUsuario") == null
            || sesion.getAttribute("rol") == null) {

        response.sendRedirect(
            response.encodeRedirectURL(
                request.getContextPath()
                + "/login.jsp?error=requiere_login"
            )
        );

        return;
    }


    String ctx =
        request.getContextPath();


    Integer idUsuarioObj =
        (Integer) sesion.getAttribute("idUsuario");


    String nombreCompleto =
        (String) sesion.getAttribute("nombreCompleto");


    String rolActual =
        (String) sesion.getAttribute("rol");


    if (idUsuarioObj == null) {

        sesion.invalidate();

        response.sendRedirect(
            ctx + "/login.jsp?error=requiere_login"
        );

        return;
    }


    int idUsuario =
        idUsuarioObj.intValue();


    if (nombreCompleto == null
            || nombreCompleto.trim().isEmpty()) {

        nombreCompleto = "Usuario";
    }


    if (rolActual == null
            || rolActual.trim().isEmpty()) {

        sesion.invalidate();

        response.sendRedirect(
            ctx + "/login.jsp?error=inactivo"
        );

        return;
    }


    String tituloPagina =
        "Mi panel";
%>


<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>


<!-- ============================================================
     ENCABEZADO
     ============================================================ -->

<div class="d-flex flex-column flex-md-row
            justify-content-between
            align-items-md-center mb-4">

    <div>

        <span class="badge bg-primary mb-2">

            <i class="bi bi-shield-check"></i>

            <%= esc(rolActual) %>

        </span>


        <h1 class="fw-bold mb-1">

            Bienvenido,
            <%= esc(nombreCompleto) %>

        </h1>


        <p class="text-muted mb-0">

            Este es tu panel de <%= esc(rolActual) %>.

        </p>

    </div>


    <div class="mt-3 mt-md-0">

        <a
            href="<%= response.encodeURL(ctx + "/logout.jsp") %>"
            class="btn btn-outline-danger">

            <i class="bi bi-box-arrow-right"></i>

            Cerrar sesión

        </a>

    </div>

</div>


<!-- ============================================================
     ERROR DE PERMISO
     ============================================================ -->

<% if ("sin_permiso".equals(request.getParameter("error"))) { %>

    <div class="alert alert-danger">

        <i class="bi bi-shield-exclamation"></i>

        <strong>Acceso denegado.</strong>

        No tienes permisos para acceder a esa sección.

    </div>

<% } %>


<!-- ============================================================
     INFORMACIÓN DE SESIÓN
     ============================================================ -->

<div class="card border-0 shadow-sm mb-4">

    <div class="card-body">

        <div class="row">

            <div class="col-md-4">

                <small class="text-muted">
                    Usuario
                </small>

                <div class="fw-bold">

                    #<%= idUsuario %>

                </div>

            </div>


            <div class="col-md-4">

                <small class="text-muted">
                    Nombre
                </small>

                <div class="fw-bold">

                    <%= esc(nombreCompleto) %>

                </div>

            </div>


            <div class="col-md-4">

                <small class="text-muted">
                    Rol
                </small>

                <div>

                    <span class="badge bg-primary">

                        <%= esc(rolActual) %>

                    </span>

                </div>

            </div>

        </div>

    </div>

</div>


<%
    /*
     * ============================================================
     * PANEL CLIENTE
     * ============================================================
     */

    if ("Cliente".equals(rolActual)) {
%>


<div class="mb-4">

    <h3 class="fw-bold">

        <i class="bi bi-person"></i>

        Panel del cliente

    </h3>

    <p class="text-muted">

        Busca propiedades, guarda favoritos,
        agenda visitas y consulta tus solicitudes.

    </p>

</div>


<div class="row g-4">


    <!-- CATÁLOGO -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-search fs-1 text-primary"></i>

                <h5 class="fw-bold mt-3">

                    Propiedades

                </h5>

                <p class="text-muted">

                    Busca y filtra los inmuebles disponibles.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/catalogo.jsp") %>"
                    class="btn btn-primary">

                    Ver catálogo

                </a>

            </div>

        </div>

    </div>


    <!-- FAVORITOS -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-heart fs-1 text-danger"></i>

                <h5 class="fw-bold mt-3">

                    Favoritos

                </h5>

                <p class="text-muted">

                    Consulta las propiedades que guardaste.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/cliente/favoritos.jsp") %>"
                    class="btn btn-outline-danger">

                    Mis favoritos

                </a>

            </div>

        </div>

    </div>


    <!-- CITAS -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-calendar-check fs-1 text-success"></i>

                <h5 class="fw-bold mt-3">

                    Mis citas

                </h5>

                <p class="text-muted">

                    Consulta tus visitas programadas.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/cliente/mis_citas.jsp") %>"
                    class="btn btn-outline-success">

                    Mis citas

                </a>

            </div>

        </div>

    </div>


    <!-- SOLICITUDES -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-file-earmark-text fs-1 text-warning"></i>

                <h5 class="fw-bold mt-3">

                    Solicitudes

                </h5>

                <p class="text-muted">

                    Consulta el estado de tus trámites.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/cliente/mis_solicitudes.jsp") %>"
                    class="btn btn-outline-warning">

                    Mis solicitudes

                </a>

            </div>

        </div>

    </div>

</div>


<%
    /*
     * ============================================================
     * PANEL INMOBILIARIA
     * ============================================================
     */

    } else if ("Inmobiliaria".equals(rolActual)) {
%>


<div class="mb-4">

    <h3 class="fw-bold">

        <i class="bi bi-building"></i>

        Panel de la inmobiliaria

    </h3>

    <p class="text-muted">

        Administra propiedades, citas, solicitudes y reportes.

    </p>

</div>


<div class="row g-4">


    <!-- NUEVA PROPIEDAD -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-plus-circle fs-1 text-primary"></i>

                <h5 class="fw-bold mt-3">

                    Nueva propiedad

                </h5>

                <p class="text-muted">

                    Registra un nuevo inmueble.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/agente/propiedad_form.jsp") %>"
                    class="btn btn-primary">

                    Crear propiedad

                </a>

            </div>

        </div>

    </div>


    <!-- PROPIEDADES -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-buildings fs-1 text-primary"></i>

                <h5 class="fw-bold mt-3">

                    Propiedades

                </h5>

                <p class="text-muted">

                    Administra tus inmuebles.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/agente/propiedades.jsp") %>"
                    class="btn btn-outline-primary">

                    Mis propiedades

                </a>

            </div>

        </div>

    </div>


    <!-- CITAS -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-calendar-week fs-1 text-warning"></i>

                <h5 class="fw-bold mt-3">

                    Agenda

                </h5>

                <p class="text-muted">

                    Atiende las citas de los clientes.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/agente/citas.jsp") %>"
                    class="btn btn-outline-warning">

                    Ver agenda

                </a>

            </div>

        </div>

    </div>


    <!-- REPORTES -->

    <div class="col-md-6 col-lg-3">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-graph-up fs-1 text-success"></i>

                <h5 class="fw-bold mt-3">

                    Reportes

                </h5>

                <p class="text-muted">

                    Consulta información consolidada.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/agente/reportes.jsp") %>"
                    class="btn btn-outline-success">

                    Ver reportes

                </a>

            </div>

        </div>

    </div>

</div>


<%
    /*
     * ============================================================
     * PANEL ADMINISTRADOR
     * ============================================================
     */

    } else if ("Administrador".equals(rolActual)) {
%>


<div class="mb-4">

    <h3 class="fw-bold">

        <i class="bi bi-shield-lock"></i>

        Panel del administrador

    </h3>

    <p class="text-muted">

        Administración general del sistema.

    </p>

</div>


<div class="row g-4">


    <!-- USUARIOS -->

    <div class="col-md-4">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-people fs-1 text-dark"></i>

                <h5 class="fw-bold mt-3">

                    Usuarios

                </h5>

                <p class="text-muted">

                    Gestiona cuentas y roles.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/admin/usuarios.jsp") %>"
                    class="btn btn-dark">

                    Administrar usuarios

                </a>

            </div>

        </div>

    </div>


    <!-- CATÁLOGOS -->

    <div class="col-md-4">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-tags fs-1 text-primary"></i>

                <h5 class="fw-bold mt-3">

                    Catálogos

                </h5>

                <p class="text-muted">

                    Administra los parámetros del sistema.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/admin/catalogos.jsp") %>"
                    class="btn btn-primary">

                    Administrar catálogos

                </a>

            </div>

        </div>

    </div>


    <!-- AUDITORÍA -->

    <div class="col-md-4">

        <div class="card border-0 shadow-sm h-100">

            <div class="card-body">

                <i class="bi bi-journal-text fs-1 text-success"></i>

                <h5 class="fw-bold mt-3">

                    Auditoría

                </h5>

                <p class="text-muted">

                    Consulta las actividades del sistema.

                </p>

                <a
                    href="<%= response.encodeURL(ctx + "/admin/auditoria.jsp") %>"
                    class="btn btn-outline-success">

                    Ver auditoría

                </a>

            </div>

        </div>

    </div>

</div>


<%
    } else {
%>


<!-- ============================================================
     ROL NO VÁLIDO
     ============================================================ -->

<div class="alert alert-danger">

    <i class="bi bi-exclamation-triangle"></i>

    <strong>Rol no válido.</strong>

    Tu cuenta está autenticada pero no tiene un rol
    reconocido por el sistema.

    <a
        href="<%= response.encodeURL(ctx + "/logout.jsp") %>"
        class="alert-link">

        Cerrar sesión

    </a>

</div>


<%
    }
%>


<!-- ============================================================
     ESTADO DE SESIÓN
     ============================================================ -->

<div class="card border-0 shadow-sm mt-5">

    <div class="card-body text-center">

        <i class="bi bi-shield-check fs-1 text-primary"></i>

        <h5 class="fw-bold mt-3">

            Sesión activa

        </h5>

        <p class="text-muted mb-0">

            Has iniciado sesión como

            <strong>
                <%= esc(rolActual) %>
            </strong>.

            Puedes navegar por el sistema sin volver
            a iniciar sesión mientras tu sesión permanezca activa.

        </p>

    </div>

</div>


<%@ include file="/WEB-INF/jspf/pie.jspf" %>