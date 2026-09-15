<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Crear cuenta";
    Connection con = null; Statement st = null; ResultSet rs = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-7">
        <div class="card shadow-sm">
            <div class="card-body p-4">
                <h3 class="mb-4"><i class="bi bi-person-plus"></i> Crear cuenta de cliente</h3>

                <% String error = request.getParameter("error");
                   if (error != null) { %>
                    <div class="alert alert-danger py-2">
                        <% if ("correo".equals(error)) { %>
                            Ya existe una cuenta con ese correo.
                        <% } else if ("documento".equals(error)) { %>
                            Ya existe un usuario con ese número de documento.
                        <% } else { %>
                            No se pudo crear la cuenta. Intenta de nuevo.
                        <% } %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/registrar.jsp" method="post">
                    <div class="row g-2">
                        <div class="col-md-6">
                            <label class="form-label">Nombres</label>
                            <input type="text" name="nombres" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Apellidos</label>
                            <input type="text" name="apellidos" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Tipo de documento</label>
                            <select name="tipo_documento" class="form-select">
                                <option value="CC">Cédula de ciudadanía</option>
                                <option value="CE">Cédula de extranjería</option>
                                <option value="PASAPORTE">Pasaporte</option>
                            </select>
                        </div>
                        <div class="col-md-8">
                            <label class="form-label">Número de documento</label>
                            <input type="text" name="numero_documento" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Teléfono</label>
                            <input type="text" name="telefono" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Ciudad</label>
                            <select name="id_ciudad" class="form-select">
                                <%
                                    try {
                                        con = abrirConexion();
                                        st = con.createStatement();
                                        rs = st.executeQuery("SELECT id_ciudad, nombre, departamento FROM ciudad WHERE estado = 1 ORDER BY nombre");
                                        while (rs.next()) {
                                %>
                                    <option value="<%= rs.getInt("id_ciudad") %>">
                                        <%= esc(rs.getString("nombre")) %> (<%= esc(rs.getString("departamento")) %>)
                                    </option>
                                <%
                                        }
                                    } finally { cerrar(rs, st, con); }
                                %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Dirección</label>
                            <input type="text" name="direccion" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Correo</label>
                            <input type="email" name="correo" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Contraseña</label>
                            <input type="password" name="clave" class="form-control" minlength="6" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 mt-3">
                        <i class="bi bi-check-circle"></i> Crear cuenta
                    </button>
                </form>
                <p class="text-center mt-3 mb-0">
                    ¿Ya tienes cuenta? <a href="<%= request.getContextPath() %>/login.jsp">Inicia sesión</a>
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
