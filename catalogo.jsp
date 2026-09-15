<%@ page import="java.sql.*" %>

<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    ResultSet rsTipo = null;
    Statement stTipo = null;

    String tipoSeleccionado =
        request.getParameter("tipo");

    String ciudadSeleccionada =
        request.getParameter("ciudad");

    String operacionSeleccionada =
        request.getParameter("operacion");

    try {

        con = abrirConexion();

        stTipo = con.createStatement();

        rsTipo = stTipo.executeQuery(
            "SELECT id_tipo, nombre " +
            "FROM tipo_propiedad " +
            "ORDER BY nombre"
        );
%>

<div class="container py-4">

    <div class="catalogo-header mb-4">

        <div>

            <span class="catalogo-etiqueta">

                <i class="bi bi-buildings"></i>
                INMOBILIARIA

            </span>

            <h1 class="catalogo-titulo">

                Encuentra tu próxima propiedad

            </h1>

            <p class="catalogo-descripcion">

                Explora nuestras propiedades disponibles
                y encuentra el lugar ideal para ti.

            </p>

        </div>

    </div>


    <!-- FILTROS -->

    <div class="catalogo-filtros mb-5">

        <div class="filtros-titulo">

            <i class="bi bi-funnel"></i>

            Buscar propiedades

        </div>


        <form
            method="get"
            action="catalogo.jsp"
        >

            <div class="row g-3">

                <div class="col-md-4">

                    <label
                        for="tipo"
                        class="form-label"
                    >
                        Tipo de propiedad
                    </label>

                    <select
                        name="tipo"
                        id="tipo"
                        class="form-select"
                    >

                        <option value="">
                            Todos los tipos
                        </option>

                        <%
                            while (rsTipo.next()) {
                        %>

                            <option
                                value="<%= rsTipo.getInt("id_tipo") %>"
                                <%= tipoSeleccionado != null &&
                                    tipoSeleccionado.equals(
                                        String.valueOf(
                                            rsTipo.getInt("id_tipo")
                                        )
                                    )
                                    ? "selected"
                                    : "" %>
                            >

                                <%= rsTipo.getString("nombre") %>

                            </option>

                        <%
                            }
                        %>

                    </select>

                </div>


                <div class="col-md-4">

                    <label
                        for="ciudad"
                        class="form-label"
                    >
                        Ciudad
                    </label>

                    <input
                        type="text"
                        name="ciudad"
                        id="ciudad"
                        class="form-control"
                        placeholder="Ej: Bucaramanga"
                        value="<%= ciudadSeleccionada != null
                            ? ciudadSeleccionada
                            : "" %>"
                    >

                </div>


                <div class="col-md-4">

                    <label
                        for="operacion"
                        class="form-label"
                    >
                        Operación
                    </label>

                    <select
                        name="operacion"
                        id="operacion"
                        class="form-select"
                    >

                        <option value="">
                            Venta o arriendo
                        </option>

                        <option
                            value="venta"
                            <%= "venta".equals(
                                operacionSeleccionada
                            )
                                ? "selected"
                                : "" %>
                        >
                            Venta
                        </option>

                        <option
                            value="arriendo"
                            <%= "arriendo".equals(
                                operacionSeleccionada
                            )
                                ? "selected"
                                : "" %>
                        >
                            Arriendo
                        </option>

                    </select>

                </div>


                <div class="col-12 d-flex gap-2">

                    <button
                        type="submit"
                        class="btn btn-primary"
                    >

                        <i class="bi bi-search"></i>

                        Buscar propiedades

                    </button>


                    <a
                        href="catalogo.jsp"
                        class="btn btn-outline-secondary"
                    >

                        <i class="bi bi-arrow-counterclockwise"></i>

                        Limpiar

                    </a>

                </div>

            </div>

        </form>

    </div>


    <%
        cerrar(rsTipo, stTipo);

        rsTipo = null;
        stTipo = null;
    %>


    <!-- PROPIEDADES -->

    <div class="catalogo-seccion">

        <div class="mb-4">

            <span class="catalogo-etiqueta">

                <i class="bi bi-house-door"></i>

                PROPIEDADES

            </span>

            <h2 class="section-title mb-0">

                Propiedades disponibles

            </h2>

        </div>


        <%
            StringBuilder sql =
                new StringBuilder();

            sql.append(
                "SELECT " +
                "p.id_propiedad, " +
                "p.titulo, " +
                "p.direccion, " +
                "p.barrio, " +
                "p.precio_venta, " +
                "p.precio_arriendo, " +
                "p.habitaciones, " +
                "p.banos, " +
                "p.destacada, " +
                "c.nombre AS ciudad, " +
                "t.nombre AS tipo " +
                "FROM propiedad p " +
                "JOIN ciudad c " +
                "ON c.id_ciudad = p.id_ciudad " +
                "JOIN tipo_propiedad t " +
                "ON t.id_tipo = p.id_tipo " +
                "WHERE p.estado_propiedad = " +
                "'DISPONIBLE' "
            );


            if (
                tipoSeleccionado != null &&
                !tipoSeleccionado.trim().isEmpty()
            ) {

                sql.append(
                    "AND p.id_tipo = ? "
                );

            }


            if (
                ciudadSeleccionada != null &&
                !ciudadSeleccionada.trim().isEmpty()
            ) {

                sql.append(
                    "AND c.nombre LIKE ? "
                );

            }


            if (
                "venta".equals(
                    operacionSeleccionada
                )
            ) {

                sql.append(
                    "AND p.precio_venta IS NOT NULL " +
                    "AND p.precio_venta > 0 "
                );

            }


            if (
                "arriendo".equals(
                    operacionSeleccionada
                )
            ) {

                sql.append(
                    "AND p.precio_arriendo IS NOT NULL " +
                    "AND p.precio_arriendo > 0 "
                );

            }


            sql.append(
                "ORDER BY " +
                "p.destacada DESC, " +
                "p.fecha_publicacion DESC"
            );


            ps = con.prepareStatement(
                sql.toString()
            );


            int parametro = 1;


            if (
                tipoSeleccionado != null &&
                !tipoSeleccionado.trim().isEmpty()
            ) {

                ps.setInt(
                    parametro++,
                    Integer.parseInt(
                        tipoSeleccionado
                    )
                );

            }


            if (
                ciudadSeleccionada != null &&
                !ciudadSeleccionada.trim().isEmpty()
            ) {

                ps.setString(
                    parametro++,
                    "%" +
                    ciudadSeleccionada.trim() +
                    "%"
                );

            }


            rs = ps.executeQuery();

            boolean hayPropiedades = false;
        %>


        <div class="row g-4">

            <%
                while (rs.next()) {

                    hayPropiedades = true;

                    int idPropiedad =
                        rs.getInt(
                            "id_propiedad"
                        );

                    String titulo =
                        rs.getString("titulo");

                    String direccion =
                        rs.getString("direccion");

                    String barrio =
                        rs.getString("barrio");

                    String ciudad =
                        rs.getString("ciudad");

                    String tipo =
                        rs.getString("tipo");

                    int habitaciones =
                        rs.getInt("habitaciones");

                    int banos =
                        rs.getInt("banos");

                    boolean destacada =
                        rs.getBoolean("destacada");


                    Object precioVentaObj =
                        rs.getObject(
                            "precio_venta"
                        );

                    Object precioArriendoObj =
                        rs.getObject(
                            "precio_arriendo"
                        );


                    String precio =
                        "Consultar precio";


                    if (
                        "arriendo".equals(
                            operacionSeleccionada
                        ) &&
                        precioArriendoObj != null
                    ) {

                        precio =
                            "$ " +
                            String.format(
                                "%,.0f",
                                rs.getDouble(
                                    "precio_arriendo"
                                )
                            ) +
                            " / mes";

                    } else if (
                        "venta".equals(
                            operacionSeleccionada
                        ) &&
                        precioVentaObj != null
                    ) {

                        precio =
                            "$ " +
                            String.format(
                                "%,.0f",
                                rs.getDouble(
                                    "precio_venta"
                                )
                            );

                    } else if (
                        precioVentaObj != null
                    ) {

                        precio =
                            "$ " +
                            String.format(
                                "%,.0f",
                                rs.getDouble(
                                    "precio_venta"
                                )
                            );

                    } else if (
                        precioArriendoObj != null
                    ) {

                        precio =
                            "$ " +
                            String.format(
                                "%,.0f",
                                rs.getDouble(
                                    "precio_arriendo"
                                )
                            ) +
                            " / mes";

                    }
            %>


            <!-- TARJETA -->

            <div class="col-md-6 col-lg-4">

                <div class="propiedad-card h-100">


                    <div class="propiedad-imagen">

                        <div
                            class="propiedad-imagen-contenido"
                        >

                            <i class="bi bi-house-heart"></i>

                        </div>


                        <span class="propiedad-tipo">

                            <%= tipo %>

                        </span>


                        <%
                            if (destacada) {
                        %>

                            <span
                                class="propiedad-destacada"
                            >

                                <i class="bi bi-star-fill"></i>

                                Destacada

                            </span>

                        <%
                            }
                        %>

                    </div>


                    <div class="propiedad-datos">

                        <div
                            class="propiedad-disponible"
                        >

                            <span
                                class="estado-punto"
                            ></span>

                            Disponible

                        </div>


                        <h3
                            class="propiedad-titulo"
                        >

                            <%= titulo %>

                        </h3>


                        <div
                            class="propiedad-ubicacion"
                        >

                            <i
                                class="bi bi-geo-alt-fill"
                            ></i>

                            <span>

                                <%= ciudad %>

                                <%
                                    if (
                                        barrio != null &&
                                        !barrio.trim().isEmpty()
                                    ) {
                                %>

                                    · <%= barrio %>

                                <%
                                    }
                                %>

                            </span>

                        </div>


                        <%
                            if (
                                direccion != null &&
                                !direccion.trim().isEmpty()
                            ) {
                        %>

                            <div
                                class="propiedad-direccion"
                            >

                                <i
                                    class="bi bi-pin-map"
                                ></i>

                                <%= direccion %>

                            </div>

                        <%
                            }
                        %>


                        <div
                            class="propiedad-caracteristicas"
                        >

                            <span>

                                <i
                                    class="bi bi-door-closed"
                                ></i>

                                <%= habitaciones %>

                                hab.

                            </span>


                            <span>

                                <i
                                    class="bi bi-droplet"
                                ></i>

                                <%= banos %>

                                baños

                            </span>

                        </div>


                        <div
                            class="propiedad-footer"
                        >

                            <div>

                                <small>
                                    Precio
                                </small>

                                <strong>

                                    <%= precio %>

                                </strong>

                            </div>


                            <a
                                href="propiedad.jsp?id=<%= idPropiedad %>"
                                class="btn btn-primary btn-sm"
                            >

                                Ver detalle

                                <i
                                    class="bi bi-arrow-right"
                                ></i>

                            </a>

                        </div>

                    </div>

                </div>

            </div>


            <%
                }
            %>

        </div>


        <%
            if (!hayPropiedades) {
        %>

            <div
                class="catalogo-vacio text-center"
            >

                <div
                    class="catalogo-vacio-icon"
                >

                    <i
                        class="bi bi-house-x"
                    ></i>

                </div>


                <h3>

                    No encontramos propiedades

                </h3>


                <p>

                    No hay propiedades disponibles
                    que coincidan con los filtros
                    seleccionados.

                </p>


                <a
                    href="catalogo.jsp"
                    class="btn btn-primary"
                >

                    <i
                        class="bi bi-arrow-counterclockwise"
                    ></i>

                    Ver todas las propiedades

                </a>

            </div>

        <%
            }
        %>


    </div>

</div>


<%
    } catch (Exception e) {
%>

    <div class="container py-5">

        <div class="alert alert-danger">

            <h5>

                <i
                    class="bi bi-exclamation-triangle"
                ></i>

                Error al buscar propiedades

            </h5>


            <p class="mb-0">

                <%= e.getMessage() %>

            </p>

        </div>

    </div>

<%
        e.printStackTrace();

    } finally {

        cerrar(
            rs,
            ps,
            con
        );

    }
%>


<%@ include file="/WEB-INF/jspf/pie.jspf" %>