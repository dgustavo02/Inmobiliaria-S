<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>

<%
    if (!validarSesion(request, response, "Administrador")) {
        return;
    }

    String tituloPagina = "Auditoría";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>


<div class="d-flex justify-content-between align-items-center mb-4">

    <div>

        <h3 class="mb-1">

            <i class="bi bi-journal-text"></i>

            Auditoría

        </h3>

        <p class="text-muted mb-0">

            Últimas operaciones realizadas en el sistema.

        </p>

    </div>

</div>


<div class="card shadow-sm">

    <div class="card-body">

        <div class="table-responsive">

            <table class="table table-striped table-hover align-middle mb-0">

                <thead class="table-dark">

                    <tr>

                        <th>Fecha</th>

                        <th>Usuario</th>

                        <th>Acción</th>

                        <th>Tabla</th>

                        <th>Registro</th>

                        <th>User-Agent</th>

                    </tr>

                </thead>


                <tbody>

                <%

                    try {

                        con = abrirConexion();

                        ps = con.prepareStatement(

                            "SELECT " +
                            "a.fecha_hora, " +
                            "a.accion, " +
                            "a.tabla_afectada, " +
                            "a.registro_id, " +
                            "a.user_agent, " +
                            "CONCAT(" +
                            "COALESCE(p.nombres, ''), " +
                            "' ', " +
                            "COALESCE(p.apellidos, '')" +
                            ") AS usuario " +
                            "FROM auditoria a " +
                            "LEFT JOIN perfil p " +
                            "ON p.id_usuario = a.id_usuario " +
                            "ORDER BY a.fecha_hora DESC " +
                            "LIMIT 100"

                        );

                        rs = ps.executeQuery();

                        boolean hay = false;


                        while (rs.next()) {

                            hay = true;

                            String usuario =
                                rs.getString("usuario");

                            String userAgent =
                                rs.getString("user_agent");

                %>

                    <tr>

                        <td class="text-nowrap">

                            <%= rs.getTimestamp("fecha_hora") %>

                        </td>


                        <td>

                            <%= esc(
                                usuario != null &&
                                !usuario.trim().isEmpty()
                                    ? usuario.trim()
                                    : "(sistema)"
                            ) %>

                        </td>


                        <td>

                            <span class="badge bg-secondary">

                                <%= esc(rs.getString("accion")) %>

                            </span>

                        </td>


                        <td>

                            <%= esc(
                                rs.getString("tabla_afectada")
                            ) %>

                        </td>


                        <td>

                            <% if (rs.getObject("registro_id") != null) { %>

                                #<%= rs.getInt("registro_id") %>

                            <% } else { %>

                                -

                            <% } %>

                        </td>


                        <td>

                            <small class="text-muted">

                                <%= esc(
                                    userAgent != null
                                        ? userAgent
                                        : "-"
                                ) %>

                            </small>

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

                            <i class="bi bi-journal-x fs-3 d-block mb-2"></i>

                            Sin registros de auditoría todavía.

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

                            Error al consultar auditoría:

                            <%= esc(e.getMessage()) %>

                        </td>

                    </tr>

                <%
                    } finally {

                        cerrar(rs, ps, con);

                    }
                %>

                </tbody>

            </table>

        </div>

    </div>

</div>


<%@ include file="/WEB-INF/jspf/pie.jspf" %>