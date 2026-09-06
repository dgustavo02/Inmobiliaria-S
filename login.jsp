<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>

<%
    String mensajeError = null;

    // Procesar el formulario cuando se envía por POST
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");

        if (correo != null && clave != null && !correo.trim().isEmpty() && !clave.trim().isEmpty()) {
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                con = abrirConexion();

                // Consulta que valida correo, estado activo y obtiene el rol del usuario
                String sql = "SELECT u.id_usuario, u.correo, u.clave_hash, u.estado_cuenta, "
                           + "p.nombres, p.apellidos, ur.id_rol, r.nombre AS nombre_rol "
                           + "FROM usuario u "
                           + "INNER JOIN perfil p ON u.id_usuario = p.id_usuario "
                           + "LEFT JOIN usuario_rol ur ON u.id_usuario = ur.id_usuario AND ur.estado = 'ACTIVO' "
                           + "LEFT JOIN rol r ON ur.id_rol = r.id_rol "
                           + "WHERE u.correo = ? AND u.clave_hash = ?";

                ps = con.prepareStatement(sql);
                ps.setString(1, correo.trim());
                ps.setString(2, clave.trim()); // En un entorno de producción se compara con hash/BCrypt

                rs = ps.executeQuery();

                if (rs.next()) {
                    String estadoCuenta = rs.getString("estado_cuenta");

                    if ("BLOQUEADA".equalsIgnoreCase(estadoCuenta) || "INACTIVA".equalsIgnoreCase(estadoCuenta)) {
                        mensajeError = "Su cuenta se encuentra " + estadoCuenta.toLowerCase() + ". Contacte al administrador.";
                    } else {
                        // Guardar variables de sesión
                        session.setAttribute("idUsuario", rs.getInt("id_usuario"));
                        session.setAttribute("correo", rs.getString("correo"));
                        session.setAttribute("nombreCompleto", rs.getString("nombres") + " " + rs.getString("apellidos"));
                        session.setAttribute("idRol", rs.getInt("id_rol"));
                        session.setAttribute("nombreRol", rs.getString("nombre_rol"));

                        // Redirigir al inicio o panel principal
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                        return;
                    }
                } else {
                    mensajeError = "Credenciales incorrectas. Verifique correo y contraseña.";
                }

            } catch (SQLException ex) {
                mensajeError = "Error en el servidor: " + ex.getMessage();
            } finally {
                cerrar(rs, ps, con);
            }
        } else {
            mensajeError = "Por favor diligencie todos los campos.";
        }
    }
%>

<% request.setAttribute("tituloPagina", "Iniciar Sesión - Portal Inmobiliario"); %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row justify-content-center my-5">
    <div class="col-md-6 col-lg-5">
        <div class="card shadow-sm border-0">
            <div class="card-body p-4">
                <h3 class="fw-bold text-center mb-1">Iniciar Sesión</h3>
                <p class="text-muted text-center small mb-4">Ingrese sus credenciales para acceder a la plataforma</p>

                <% if (mensajeError != null) { %>
                    <div class="alert alert-danger py-2 small" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-1"></i> <%= mensajeError %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/login.jsp" method="POST">
                    <div class="mb-3">
                        <label for="correo" class="form-label fw-semibold">Correo Electrónico</label>
                        <input type="email" class="form-control" id="correo" name="correo" required placeholder="ejemplo@correo.com">
                    </div>

                    <div class="mb-4">
                        <label for="clave" class="form-label fw-semibold">Contraseña</label>
                        <input type="password" class="form-control" id="clave" name="clave" required placeholder="••••••••">
                    </div>

                    <button type="submit" class="btn btn-danger w-100 fw-bold py-2">
                        Ingresar al Sistema
                    </button>
                </form>
            </div>
            <div class="card-footer bg-light text-center py-3 border-0">
                <small class="text-muted">¿No tiene una cuenta? Contacte con la administración de la inmobiliaria.</small>
            </div>
        </div>
    </div>
</div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>