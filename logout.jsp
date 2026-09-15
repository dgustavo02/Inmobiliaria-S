<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    /*
     * ============================================================
     * CERRAR SESIÓN
     * ============================================================
     */

    HttpSession sesion =
        request.getSession(false);


    if (sesion != null) {

        sesion.invalidate();
    }


    /*
     * Volver al inicio.
     */

    response.sendRedirect(
        response.encodeRedirectURL(
            request.getContextPath()
            + "/index.jsp"
        )
    );
%>