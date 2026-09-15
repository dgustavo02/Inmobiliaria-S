<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%
    if (!validarSesion(request, response, "Administrador")) {
        return;
    }

    String tituloPagina = "Usuarios y roles";
    String ctx = request.getContextPath();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    PreparedStatement psRoles = null;
    ResultSet rsRoles = null;
%>

<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>


<div class="d-flex justify-content-between align-items-center mb-4">

    <div>

        <h3 class="mb-1">

            <i class="bi bi-people"></i>

            Usuarios y roles

        </h3>

        <p class="text-muted mb-0">

            Administración de cuentas, estados y roles.

        </p>

    </div>

</div>


<% if ("1".equals(request.getParameter("ok"))) { %>

    <div class="alert alert-success alert-dismissible fade show">

        <i class="bi bi-check-circle me-1"></i>

        Usuario actualizado correctamente.

        <button
            type="button"
            class="btn-close"
            data-bs-dismiss="alert">
        </button>

    </div>

<% } %>


<% if ("1".equals(request.getParameter("error"))) { %>

    <div class="alert alert-danger alert-dismissible fade show">

        <i class="bi bi-exclamation-triangle me-1"></i>

        No fue posible completar la operación.

        <button
            type="button"
            class="btn-close"
            data-bs-dismiss="alert">
        </button>

    </div>

<% } %>


<div class="card shadow-sm">

    <div class="card-body">

        <div class="table-responsive">

            <table class="table table-striped table-hover align-middle">

                <thead class="table-dark">

                    <tr>

                        <th>Nombre</th>

                        <th>Correo</th>

                        <th>Roles</th>

                        <th>Estado</th>

                        <th>Asignar rol</th>

                        <th>Acción</th>

                    </tr>

                </thead>


                <tbody>

                <%

                    try {

                        con = abrirConexion();


                        /* =================================================
                           OBTENER ROLES
                           ================================================= */

                        psRoles = con.prepareStatement(

                            "SELECT id_rol, nombre " +
                            "FROM rol " +
                            "ORDER BY nombre"

                        );


                        rsRoles =
                            psRoles.executeQuery();


                        /*
                         * Guardamos los roles en memoria para poder
                         * reutilizarlos en cada fila.
                         */
                        java.util.List<Integer> idsRoles =
                            new java.util.ArrayList<Integer>();

                        java.util.List<String> nombresRoles =
                            new java.util.ArrayList<String>();


                        while (rsRoles.next()) {

                            idsRoles.add(
                                rsRoles.getInt("id_rol")
                            );

                            nombresRoles.add(
                                rsRoles.getString("nombre")
                            );

                        }


                        cerrar(rsRoles, psRoles);

                        rsRoles = null;
                        psRoles = null;


                        /* =================================================
                           OBTENER USUARIOS
                           ================================================= */

                        ps = con.prepareStatement(

                            "SELECT " +
                            "u.id_usuario, " +
                            "u.correo, " +
                            "u.estado_cuenta, " +
                            "CONCAT(" +
                            "COALESCE(p.nombres, ''), " +
                            "' ', " +
                            "COALESCE(p.apellidos, '')" +
                            ") AS nombre, " +
                            "GROUP_CONCAT(" +
                            "r.nombre " +
                            "SEPARATOR ', '" +
                            ") AS roles " +

                            "FROM usuario u " +

                            "LEFT JOIN perfil p " +
                            "ON p.id_usuario = u.id_usuario " +

                            "LEFT JOIN usuario_rol ur " +
                            "ON ur.id_usuario = u.id_usuario " +
                            "AND ur.estado = 'ACTIVO' " +

                            "LEFT JOIN rol r " +
                            "ON r.id_rol = ur.id_rol " +

                            "GROUP BY " +
                            "u.id_usuario, " +
                            "u.correo, " +
                            "u.estado_cuenta, " +
                            "p.nombres, " +
                            "p.apellidos " +

                            "ORDER BY u.id_usuario"

                        );


                        rs = ps.executeQuery();


                        boolean hay = false;


                        while (rs.next()) {

                            hay = true;


                            int idUsuario =
                                rs.getInt("id_usuario");


                            String estado =
                                rs.getString("estado_cuenta");


                            String nombre =
                                rs.getString("nombre");


                            String roles =
                                rs.getString("roles");

                %>

                    <tr>

                        <!-- NOMBRE -->

                        <td>

                            <%= esc(
                                nombre != null &&
                                !nombre.trim().isEmpty()
                                    ? nombre.trim()
                                    : "(sin perfil)"
                            ) %>

                        </td>


                        <!-- CORREO -->

                        <td>

                            <%= esc(
                                rs.getString("correo")
                            ) %>

                        </td>


                        <!-- ROLES -->

                        <td>

                            <% if (roles != null &&
                                   !roles.trim().isEmpty()) { %>

                                <span class="badge bg-secondary">

                                    <%= esc(roles) %>

                                </span>

                            <% } else { %>

                                <span class="text-muted">

                                    Sin rol

                                </span>

                            <% } %>

                        </td>


                        <!-- ESTADO -->

                        <td>

                            <span
                                class="badge bg-<%= colorEstado(estado) %>">

                                <%= esc(estado) %>

                            </span>

                        </td>


                        <!-- ASIGNAR ROL -->

                        <td>

                            <form
                                action="<%= ctx %>/admin/accion_usuario.jsp"
                                method="post"
                                class="d-flex gap-1">

                                <input
                                    type="hidden"
                                    name="accion"
                                    value="asignar_rol">


                                <input
                                    type="hidden"
                                    name="id_usuario"
                                    value="<%= idUsuario %>">


                                <select
                                    name="id_rol"
                                    class="form-select form-select-sm"
                                    required>

                                    <option value="">
                                        Seleccionar...
                                    </option>

                                    <%
                                        for (
                                            int i = 0;
                                            i < idsRoles.size();
                                            i++
                                        ) {
                                    %>

                                        <option
                                            value="<%= idsRoles.get(i) %>">

                                            <%= esc(
                                                nombresRoles.get(i)
                                            ) %>

                                        </option>

                                    <%
                                        }
                                    %>

                                </select>


                                <button
                                    type="submit"
                                    class="btn btn-sm btn-outline-primary">

                                    <i class="bi bi-person-check"></i>

                                    Asignar

                                </button>

                            </form>

                        </td>


                        <!-- ACTIVAR / INACTIVAR -->

                        <td>

                            <% if (!"INACTIVA".equals(estado)) { %>

                                <form
                                    action="<%= ctx %>/admin/accion_usuario.jsp"
                                    method="post">

                                    <input
                                        type="hidden"
                                        name="accion"
                                        value="inactivar">


                                    <input
                                        type="hidden"
                                        name="id_usuario"
                                        value="<%= idUsuario %>">


                                    <button
                                        type="submit"
                                        class="btn btn-sm btn-outline-danger">

                                        <i class="bi bi-person-x"></i>

                                        Inactivar

                                    </button>

                                </form>

                            <% } else { %>

                                <form
                                    action="<%= ctx %>/admin/accion_usuario.jsp"
                                    method="post">

                                    <input
                                        type="hidden"
                                        name="accion"
                                        value="activar">


                                    <input
                                        type="hidden"
                                        name="id_usuario"
                                        value="<%= idUsuario %>">


                                    <button
                                        type="submit"
                                        class="btn btn-sm btn-outline-success">

                                        <i class="bi bi-person-check"></i>

                                        Activar

                                    </button>

                                </form>

                            <% } %>

                        </td>

                    </tr>

                <%
                        }


                        if (!hay) {
                %>

                    <tr>

                        <td
                            colspan="6"
                            class="text-center text-muted py-5">

                            <i class="bi bi-people fs-3 d-block mb-2"></i>

                            No hay usuarios registrados.

                        </td>

                    </tr>

                <%
                        }

                    } catch (SQLException e) {
                %>

                    <tr>

                        <td
                            colspan="6"
                            class="text-danger py-3">

                            <i class="bi bi-exclamation-triangle me-1"></i>

                            Error:

                            <%= esc(e.getMessage()) %>

                        </td>

                    </tr>

                <%
                    } finally {

                        cerrar(
                            rs,
                            ps,
                            rsRoles,
                            psRoles,
                            con
                        );

                    }
                %>

                </tbody>

            </table>

        </div>

    </div>

</div>


<div class="alert alert-info mt-3">

    <i class="bi bi-info-circle me-1"></i>

    Los roles disponibles se cargan directamente desde la tabla
    <code>rol</code>. De esta forma no dependemos de que tengan
    IDs consecutivos o de que hayan sido insertados en un orden
    determinado.

</div>


<%@ include file="/WEB-INF/jspf/pie.jspf" %>