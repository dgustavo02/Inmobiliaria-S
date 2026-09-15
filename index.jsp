<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>

<%
    String tituloPagina = "Inicio - Inmobiliaria VSC";
    String ctx = request.getContextPath();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>


<!-- =====================================================
     HERO
     ===================================================== -->

<section class="hero">

    <div class="container">

        <div class="row align-items-center">

            <div class="col-lg-7">

                <span class="badge bg-primary mb-3">
                    <i class="bi bi-stars"></i>
                    Encuentra tu próximo hogar
                </span>

                <h1>
                    El lugar que buscas,
                    <span class="text-info">empieza aquí.</span>
                </h1>

                <p>
                    Encuentra propiedades para comprar o arrendar
                    de forma rápida, sencilla y segura.
                </p>

                <div class="d-flex flex-wrap gap-2 mt-4">

                    <a href="<%= ctx %>/catalogo.jsp"
                       class="btn btn-primary btn-lg">

                        <i class="bi bi-search"></i>
                        Ver propiedades

                    </a>

                    <a href="<%= ctx %>/registro.jsp"
                       class="btn btn-outline-light btn-lg">

                        <i class="bi bi-person-plus"></i>
                        Crear cuenta

                    </a>

                </div>

            </div>


            <div class="col-lg-5 d-none d-lg-block">

                <div class="text-center">

                    <i class="bi bi-buildings"
                       style="
                           font-size: 12rem;
                           color: rgba(255,255,255,0.12);
                       ">
                    </i>

                </div>

            </div>

        </div>


        <!-- =================================================
             BUSCADOR
             ================================================= -->

        <div class="hero-search">

            <form action="<%= ctx %>/catalogo.jsp"
                  method="get">

                <div class="row g-2 align-items-end">

                    <!-- PALABRA CLAVE -->

                    <div class="col-lg-5">

                        <label class="form-label text-dark">

                            <i class="bi bi-search"></i>
                            ¿Qué estás buscando?

                        </label>

                        <input
                            type="text"
                            name="q"
                            class="form-control"
                            placeholder="Ciudad, barrio o palabra clave">

                    </div>


                    <!-- TIPO -->

                    <div class="col-lg-4">

                        <label class="form-label text-dark">

                            <i class="bi bi-house"></i>
                            Tipo de propiedad

                        </label>

                        <select
                            name="tipo"
                            class="form-select">

                            <option value="">
                                Cualquier tipo
                            </option>

                            <%
                                Statement stTipo = null;
                                ResultSet rsTipo = null;

                                try {

                                    con = abrirConexion();

                                    stTipo = con.createStatement();

                                    rsTipo = stTipo.executeQuery(
                                        "SELECT id_tipo, nombre " +
                                        "FROM tipo_propiedad " +
                                        "ORDER BY nombre"
                                    );

                                    while (rsTipo.next()) {
                            %>

                                <option
                                    value="<%= rsTipo.getInt("id_tipo") %>">

                                    <%= esc(rsTipo.getString("nombre")) %>

                                </option>

                            <%
                                    }

                                } catch (SQLException e) {

                                    // Si ocurre un error no detenemos
                                    // toda la página.

                                } finally {

                                    cerrar(rsTipo, stTipo, con);

                                    con = null;
                                }
                            %>

                        </select>

                    </div>


                    <!-- BOTÓN -->

                    <div class="col-lg-3">

                        <button
                            type="submit"
                            class="btn btn-primary w-100">

                            <i class="bi bi-search"></i>
                            Buscar propiedades

                        </button>

                    </div>

                </div>

            </form>

        </div>

    </div>

</section>


<!-- =====================================================
     PROPIEDADES DESTACADAS
     ===================================================== -->

<section class="py-5">

    <div class="container">

        <div class="text-center mb-4">

            <span class="badge bg-primary mb-2">
                Propiedades destacadas
            </span>

            <h2 class="titulo-seccion">
                Encuentra un lugar que te guste
            </h2>

            <p class="subtitulo-seccion">
                Conoce algunas de las propiedades disponibles
                en nuestro catálogo.
            </p>

        </div>


        <div class="row g-4">

            <%
                con = null;
                ps = null;
                rs = null;

                boolean hayPropiedades = false;

                try {

                    con = abrirConexion();

                    String sql =
                        "SELECT p.id_propiedad, " +
                        "       p.titulo, " +
                        "       p.precio_venta, " +
                        "       p.precio_arriendo, " +
                        "       p.habitaciones, " +
                        "       p.banos, " +
                        "       p.area_m2, " +
                        "       p.destacada, " +
                        "       c.nombre AS ciudad, " +
                        "       t.nombre AS tipo " +
                        "FROM propiedad p " +
                        "JOIN ciudad c " +
                        "  ON c.id_ciudad = p.id_ciudad " +
                        "JOIN tipo_propiedad t " +
                        "  ON t.id_tipo = p.id_tipo " +
                        "WHERE p.estado_propiedad = 'DISPONIBLE' " +
                        "ORDER BY p.destacada DESC, " +
                        "         p.fecha_publicacion DESC " +
                        "LIMIT 6";

                    ps = con.prepareStatement(sql);

                    rs = ps.executeQuery();

                    while (rs.next()) {

                        hayPropiedades = true;
            %>

            <div class="col-md-6 col-lg-4">

                <div class="propiedad-card">

                    <!-- IMAGEN / ICONO -->

                    <div class="propiedad-imagen">

                        <i class="bi bi-house-door"></i>

                    </div>


                    <!-- INFORMACIÓN -->

                    <div class="propiedad-datos">

                        <span class="badge bg-primary mb-2">

                            <%= esc(rs.getString("tipo")) %>

                        </span>

                        <h5>

                            <%= esc(rs.getString("titulo")) %>

                        </h5>


                        <p class="mb-2">

                            <i class="bi bi-geo-alt"></i>

                            <%= esc(rs.getString("ciudad")) %>

                        </p>


                        <div class="d-flex flex-wrap gap-3">

                            <span>

                                <i class="bi bi-door-closed"></i>

                                <%= rs.getInt("habitaciones") %>
                                hab.

                            </span>


                            <span>

                                <i class="bi bi-droplet"></i>

                                <%= rs.getInt("banos") %>
                                baños

                            </span>


                            <%
                                if (rs.getObject("area_m2") != null) {
                            %>

                            <span>

                                <i class="bi bi-rulers"></i>

                                <%= rs.getDouble("area_m2") %>
                                m²

                            </span>

                            <%
                                }
                            %>

                        </div>

                    </div>


                    <!-- PRECIO Y BOTÓN -->

                    <div class="propiedad-footer">

                        <div class="propiedad-precio">

                            <%
                                if (rs.getObject("precio_venta") != null) {
                            %>

                                <i class="bi bi-tag"></i>

                                <%= moneda(
                                    rs.getDouble("precio_venta")
                                ) %>

                            <%
                                } else if (
                                    rs.getObject("precio_arriendo") != null
                                ) {
                            %>

                                <i class="bi bi-calendar"></i>

                                <%= moneda(
                                    rs.getDouble("precio_arriendo")
                                ) %>
                                /mes

                            <%
                                }
                            %>

                        </div>


                        <a
                            href="<%= ctx %>/propiedad.jsp?id=<%= rs.getInt("id_propiedad") %>"
                            class="btn btn-outline-primary w-100">

                            Ver propiedad

                            <i class="bi bi-arrow-right"></i>

                        </a>

                    </div>

                </div>

            </div>

            <%
                    }

                } catch (SQLException e) {
            %>

                <div class="col-12">

                    <div class="alert alert-warning">

                        <i class="bi bi-exclamation-triangle"></i>

                        No fue posible cargar las propiedades
                        en este momento.

                    </div>

                </div>

            <%
                } finally {

                    cerrar(rs, ps, con);
                }

                if (!hayPropiedades) {
            %>

                <div class="col-12">

                    <div class="catalogo-vacio">

                        <i class="bi bi-house-slash"></i>

                        <h5>
                            No hay propiedades disponibles
                        </h5>

                        <p>
                            Actualmente no tenemos propiedades
                            disponibles para mostrar.
                        </p>

                        <a
                            href="<%= ctx %>/catalogo.jsp"
                            class="btn btn-primary mt-3">

                            Explorar catálogo

                        </a>

                    </div>

                </div>

            <%
                }
            %>

        </div>


        <!-- BOTÓN CATÁLOGO -->

        <div class="text-center mt-4">

            <a
                href="<%= ctx %>/catalogo.jsp"
                class="btn btn-primary">

                Ver todo el catálogo

                <i class="bi bi-arrow-right"></i>

            </a>

        </div>

    </div>

</section>


<!-- =====================================================
     BENEFICIOS
     ===================================================== -->

<section class="py-5 bg-white">

    <div class="container">

        <div class="text-center mb-5">

            <span class="badge bg-primary mb-2">
                ¿Por qué elegirnos?
            </span>

            <h2 class="titulo-seccion">
                Todo más fácil
            </h2>

            <p class="subtitulo-seccion">
                Una plataforma pensada para facilitar
                la búsqueda y gestión de propiedades.
            </p>

        </div>


        <div class="row g-4">

            <!-- BENEFICIO 1 -->

            <div class="col-md-4">

                <div class="card beneficio-card">

                    <div class="beneficio-icon">

                        <i class="bi bi-search"></i>

                    </div>

                    <h5>
                        Busca fácilmente
                    </h5>

                    <p>
                        Encuentra propiedades utilizando
                        diferentes filtros y criterios de búsqueda.
                    </p>

                </div>

            </div>


            <!-- BENEFICIO 2 -->

            <div class="col-md-4">

                <div class="card beneficio-card">

                    <div class="beneficio-icon">

                        <i class="bi bi-shield-check"></i>

                    </div>

                    <h5>
                        Información clara
                    </h5>

                    <p>
                        Consulta las características,
                        ubicación y precios de cada propiedad.
                    </p>

                </div>

            </div>


            <!-- BENEFICIO 3 -->

            <div class="col-md-4">

                <div class="card beneficio-card">

                    <div class="beneficio-icon">

                        <i class="bi bi-person-check"></i>

                    </div>

                    <h5>
                        Gestión segura
                    </h5>

                    <p>
                        Los usuarios registrados cuentan
                        con herramientas según su rol.
                    </p>

                </div>

            </div>

        </div>

    </div>

</section>


<!-- =====================================================
     CTA FINAL
     ===================================================== -->

<section class="cta">

    <div class="container">

        <div class="row align-items-center">

            <div class="col-lg-8">

                <h2>
                    ¿Ya encontraste tu próxima propiedad?
                </h2>

                <p class="mb-lg-0">
                    Regístrate para acceder a más
                    funcionalidades de la plataforma.
                </p>

            </div>


            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">

                <a
                    href="<%= ctx %>/registro.jsp"
                    class="btn btn-primary btn-lg">

                    <i class="bi bi-person-plus"></i>

                    Crear mi cuenta

                </a>

            </div>

        </div>

    </div>

</section>


<%@ include file="/WEB-INF/jspf/pie.jspf" %>