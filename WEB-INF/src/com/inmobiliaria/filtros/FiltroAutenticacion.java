package com.inmobiliaria.filtros;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


/**
 * Filtro de autenticación y autorización.
 *
 * Protege:
 *
 * /cliente/*
 * /agente/*
 * /admin/*
 */
@WebFilter(
    urlPatterns = {
        "/cliente/*",
        "/agente/*",
        "/admin/*"
    }
)
public class FiltroAutenticacion implements Filter {


    @Override
    public void init(
            FilterConfig filterConfig)
            throws ServletException {

        // No requiere configuración adicional.
    }


    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {


        HttpServletRequest req =
            (HttpServletRequest) request;


        HttpServletResponse resp =
            (HttpServletResponse) response;


        String ctx =
            req.getContextPath();


        String uri =
            req.getRequestURI()
               .substring(ctx.length());


        /*
         * ========================================================
         * RECUPERAR SESIÓN
         * ========================================================
         */

        HttpSession sesion =
            req.getSession(false);


        boolean autenticado =
            sesion != null
            && sesion.getAttribute("idUsuario") != null
            && sesion.getAttribute("rol") != null;


        /*
         * ========================================================
         * SIN SESIÓN
         * ========================================================
         */

        if (!autenticado) {

            resp.sendRedirect(
                resp.encodeRedirectURL(
                    ctx
                    + "/login.jsp?error=requiere_login"
                )
            );

            return;
        }


        /*
         * ========================================================
         * ROL
         * ========================================================
         */

        String rol =
            (String) sesion.getAttribute("rol");


        /*
         * ========================================================
         * ADMINISTRADOR
         * ========================================================
         *
         * Tiene acceso general.
         */

        if ("Administrador".equals(rol)) {

            chain.doFilter(
                request,
                response
            );

            return;
        }


        /*
         * ========================================================
         * CLIENTE
         * ========================================================
         */

        if (uri.startsWith("/cliente/")) {

            if ("Cliente".equals(rol)) {

                chain.doFilter(
                    request,
                    response
                );

                return;
            }


            resp.sendRedirect(
                resp.encodeRedirectURL(
                    ctx
                    + "/panel.jsp?error=sin_permiso"
                )
            );

            return;
        }


        /*
         * ========================================================
         * INMOBILIARIA
         * ========================================================
         */

        if (uri.startsWith("/agente/")) {

            if ("Inmobiliaria".equals(rol)) {

                chain.doFilter(
                    request,
                    response
                );

                return;
            }


            resp.sendRedirect(
                resp.encodeRedirectURL(
                    ctx
                    + "/panel.jsp?error=sin_permiso"
                )
            );

            return;
        }


        /*
         * ========================================================
         * ADMIN
         * ========================================================
         */

        if (uri.startsWith("/admin/")) {

            if ("Administrador".equals(rol)) {

                chain.doFilter(
                    request,
                    response
                );

                return;
            }


            resp.sendRedirect(
                resp.encodeRedirectURL(
                    ctx
                    + "/panel.jsp?error=sin_permiso"
                )
            );

            return;
        }


        /*
         * ========================================================
         * RUTA NO RECONOCIDA
         * ========================================================
         */

        chain.doFilter(
            request,
            response
        );
    }


    @Override
    public void destroy() {

        // No requiere liberación de recursos.
    }
}