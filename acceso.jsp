<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>

<%
    String ctx = request.getContextPath();

    String correo =
        request.getParameter("correo");

    String clave =
        request.getParameter("clave");


    /*
     * ============================================================
     * VALIDACIÓN BÁSICA
     * ============================================================
     */

    if (correo == null) {
        correo = "";
    }

    if (clave == null) {
        clave = "";
    }

    correo = correo.trim();


    if (correo.isEmpty() || clave.isEmpty()) {

        response.sendRedirect(
            ctx + "/login.jsp?error=credenciales"
        );

        return;
    }


    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;


    try {

        con = abrirConexion();


        /*
         * ========================================================
         * BUSCAR USUARIO
         * ========================================================
         */

        String sql =
            "SELECT " +
            "u.id_usuario, " +
            "u.clave_hash, " +
            "u.estado_cuenta, " +
            "u.intentos_fallidos, " +
            "u.fecha_bloqueo, " +
            "p.nombres, " +
            "p.apellidos " +
            "FROM usuario u " +
            "LEFT JOIN perfil p " +
            "ON p.id_usuario = u.id_usuario " +
            "WHERE u.correo = ?";


        ps = con.prepareStatement(sql);

        ps.setString(1, correo);

        rs = ps.executeQuery();


        /*
         * ========================================================
         * USUARIO NO EXISTE
         * ========================================================
         */

        if (!rs.next()) {

            response.sendRedirect(
                ctx + "/login.jsp?error=credenciales"
            );

            return;
        }


        int idUsuario =
            rs.getInt("id_usuario");


        String hashGuardado =
            rs.getString("clave_hash");


        String estadoCuenta =
            rs.getString("estado_cuenta");


        int intentosFallidos =
            rs.getInt("intentos_fallidos");


        Timestamp fechaBloqueo =
            rs.getTimestamp("fecha_bloqueo");


        String nombres =
            rs.getString("nombres");


        String apellidos =
            rs.getString("apellidos");


        /*
         * ========================================================
         * CUENTA INACTIVA
         * ========================================================
         */

        if ("INACTIVA".equalsIgnoreCase(estadoCuenta)) {

            response.sendRedirect(
                ctx + "/login.jsp?error=inactivo"
            );

            return;
        }


        /*
         * ========================================================
         * BLOQUEO TEMPORAL
         * ========================================================
         */

        if ("BLOQUEADA".equalsIgnoreCase(estadoCuenta)
                && fechaBloqueo != null) {

            long ahora =
                System.currentTimeMillis();

            long bloqueoHasta =
                fechaBloqueo.getTime()
                + (15L * 60L * 1000L);


            if (ahora < bloqueoHasta) {

                response.sendRedirect(
                    ctx + "/login.jsp?error=bloqueado"
                );

                return;
            }


            /*
             * Ya pasaron los 15 minutos.
             * Desbloquear.
             */

            PreparedStatement psDesbloqueo = null;

            try {

                psDesbloqueo =
                    con.prepareStatement(
                        "UPDATE usuario " +
                        "SET estado_cuenta = 'ACTIVA', " +
                        "intentos_fallidos = 0, " +
                        "fecha_bloqueo = NULL " +
                        "WHERE id_usuario = ?"
                    );

                psDesbloqueo.setInt(1, idUsuario);

                psDesbloqueo.executeUpdate();

            } finally {

                cerrar(psDesbloqueo);
            }

            estadoCuenta = "ACTIVA";
            intentosFallidos = 0;
            fechaBloqueo = null;
        }


        /*
         * ========================================================
         * COMPROBAR CONTRASEÑA
         * ========================================================
         */

        boolean claveCorrecta =
            verificarClave(clave, hashGuardado);


        /*
         * ========================================================
         * CONTRASEÑA INCORRECTA
         * ========================================================
         */

        if (!claveCorrecta) {

            int nuevosIntentos =
                intentosFallidos + 1;


            if (nuevosIntentos >= 5) {

                PreparedStatement psBloqueo = null;

                try {

                    psBloqueo =
                        con.prepareStatement(
                            "UPDATE usuario " +
                            "SET intentos_fallidos = ?, " +
                            "fecha_bloqueo = NOW(), " +
                            "estado_cuenta = 'BLOQUEADA' " +
                            "WHERE id_usuario = ?"
                        );

                    psBloqueo.setInt(1, nuevosIntentos);
                    psBloqueo.setInt(2, idUsuario);

                    psBloqueo.executeUpdate();

                } finally {

                    cerrar(psBloqueo);
                }


                response.sendRedirect(
                    ctx + "/login.jsp?error=bloqueado"
                );

                return;
            }


            PreparedStatement psIntentos = null;

            try {

                psIntentos =
                    con.prepareStatement(
                        "UPDATE usuario " +
                        "SET intentos_fallidos = ? " +
                        "WHERE id_usuario = ?"
                    );

                psIntentos.setInt(1, nuevosIntentos);
                psIntentos.setInt(2, idUsuario);

                psIntentos.executeUpdate();

            } finally {

                cerrar(psIntentos);
            }


            response.sendRedirect(
                ctx + "/login.jsp?error=credenciales"
            );

            return;
        }


        /*
         * ========================================================
         * OBTENER ROL PRINCIPAL
         * ========================================================
         */

        String rolPrincipal =
            resolverRolPrincipal(
                con,
                idUsuario
            );


        /*
         * Si la cuenta no tiene rol activo,
         * no puede utilizar el sistema.
         */

        if (rolPrincipal == null
                || rolPrincipal.trim().isEmpty()) {

            response.sendRedirect(
                ctx + "/login.jsp?error=inactivo"
            );

            return;
        }


        /*
         * ========================================================
         * ACTUALIZAR USUARIO
         * ========================================================
         */

        PreparedStatement psActualizar = null;

        try {

            psActualizar =
                con.prepareStatement(
                    "UPDATE usuario " +
                    "SET intentos_fallidos = 0, " +
                    "fecha_bloqueo = NULL, " +
                    "estado_cuenta = 'ACTIVA', " +
                    "ultimo_acceso = NOW() " +
                    "WHERE id_usuario = ?"
                );

            psActualizar.setInt(1, idUsuario);

            psActualizar.executeUpdate();

        } finally {

            cerrar(psActualizar);
        }


        /*
         * ========================================================
         * NOMBRE COMPLETO
         * ========================================================
         */

        String nombreCompleto =
            ((nombres != null) ? nombres : "")
            + " "
            + ((apellidos != null) ? apellidos : "");


        nombreCompleto =
            nombreCompleto.trim();


        if (nombreCompleto.isEmpty()) {
            nombreCompleto = correo;
        }


        /*
         * ========================================================
         * CREAR SESIÓN
         * ========================================================
         *
         * IMPORTANTE:
         *
         * Si ya existía una sesión anterior, se invalida.
         * Luego se crea una sesión nueva.
         *
         * Esto evita mezclar información de usuarios anteriores.
         */

        HttpSession sesionAnterior =
            request.getSession(false);


        if (sesionAnterior != null) {

            sesionAnterior.invalidate();
        }


        HttpSession sesion =
            request.getSession(true);


        /*
         * Guardar identidad del usuario.
         */

        sesion.setAttribute(
            "idUsuario",
            Integer.valueOf(idUsuario)
        );


        sesion.setAttribute(
            "nombreCompleto",
            nombreCompleto
        );


        sesion.setAttribute(
            "rol",
            rolPrincipal
        );


        /*
         * 30 minutos de inactividad.
         */

        sesion.setMaxInactiveInterval(
            30 * 60
        );


        /*
         * ========================================================
         * REDIRECCIÓN
         * ========================================================
         *
         * Todos van al panel.
         * El panel cambia según el rol.
         */

        response.sendRedirect(
            response.encodeRedirectURL(
                ctx + "/panel.jsp"
            )
        );

    } catch (SQLException e) {

        e.printStackTrace();

        response.sendRedirect(
            ctx + "/login.jsp?error=general"
        );

    } finally {

        cerrar(rs, ps, con);
    }
%>