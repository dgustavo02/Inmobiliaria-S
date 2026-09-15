<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    String tituloPagina = "Iniciar sesión";
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="row justify-content-center">
    <div class="col-md-5 col-lg-4">
        <div class="card shadow-sm mt-4">
            <div class="card-body p-4">
                <h3 class="text-center mb-4"><i class="bi bi-houses-fill"></i> Inmobiliaria</h3>

                <% String error = request.getParameter("error");
                   if (error != null) { %>
                    <div class="alert alert-danger py-2">
                        <% if ("credenciales".equals(error)) { %>
                            Correo o contraseña incorrectos.
                        <% } else if ("bloqueado".equals(error)) { %>
                            Cuenta bloqueada temporalmente por intentos fallidos. Intenta más tarde.
                        <% } else if ("inactivo".equals(error)) { %>
                            Tu cuenta está inactiva. Contacta al administrador.
                        <% } else if ("requiere_login".equals(error)) { %>
                            Debes iniciar sesión para continuar.
                        <% } else { %>
                            Ocurrió un error al iniciar sesión.
                        <% } %>
                    </div>
                <% }
                   if ("1".equals(request.getParameter("salida"))) { %>
                    <div class="alert alert-success py-2">Sesión cerrada correctamente.</div>
                <% }
                   if ("1".equals(request.getParameter("registro"))) { %>
                    <div class="alert alert-success py-2">Cuenta creada. Ya puedes iniciar sesión.</div>
                <% } %>

                <form action="<%= request.getContextPath() %>/acceso.jsp" method="post">
                    <div class="mb-3">
                        <label class="form-label">Correo</label>
                        <input type="email" name="correo" class="form-control" required autofocus>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Contraseña</label>
                        <input type="password" name="clave" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-box-arrow-in-right"></i> Ingresar
                    </button>
                </form>
                <p class="text-center mt-3 mb-0">
                    ¿No tienes cuenta? <a href="<%= request.getContextPath() %>/registro.jsp">Regístrate</a>
                </p>
            </div>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
