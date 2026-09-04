<%@ page import="java.sql.Connection, java.sql.Statement, java.sql.DriverManager, java.sql.SQLException, java.sql.ResultSet" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Equipos</title>
    <!-- Agregamos Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">

    <h2 class="text-center mb-4">Inventario de Equipos Registrados</h2>

    <table class="table table-striped table-bordered align-middle">
        <thead class="table-dark">
            <tr>
                <th>Nombre del equipo</th>
                <th>Id</th>
                <th>Categoría</th>
                <th>Marca</th>
                <th>Fecha</th>
                <th>Estado</th>
                <th>Observaciones</th>
                <th>Precio ($)</th>
            </tr>
        </thead>
        <tbody>

        <%
        Connection conexion = null;
        Statement sentencia = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conexion = DriverManager.getConnection("jdbc:mysql://bvwzcgztc073pq8l0hcw-mysql.services.clever-cloud.com:3306/bvwzcgztc073pq8l0hcw", "u8sze2iu8jddnirk", "Jgn7HNmwGURGIAVt39zd");
            sentencia = conexion.createStatement();
            
            // Consulta manteniendo el orden exacto del INSERT INTO
            String consultaSQL = "SELECT nombre_equipo, Id, categoria, marca, fecha, estado, observaciones, precio FROM quiz";
            rs = sentencia.executeQuery(consultaSQL);

            while (rs.next()) { %>
                <tr>
                    <td><%= rs.getString("nombre_equipo") %></td>
                    <td><%= rs.getString("Id") %></td>
                    <td><%= rs.getString("categoria") %></td>
                    <td><%= rs.getString("marca") %></td>
                    <td><%= rs.getString("fecha") %></td>
                    <td><%= rs.getString("estado") %></td>
                    <td><%= rs.getString("observaciones") %></td>
                    <td><%= rs.getString("precio") %></td>
                </tr>
            <% } 
        } catch (ClassNotFoundException e) {
            out.println("<tr><td colspan='8'><div class='alert alert-danger m-0'>Error accediendo al driver: " + e.getMessage() + "</div></td></tr>");
        } catch (SQLException e) {
            out.println("<tr><td colspan='8'><div class='alert alert-danger m-0'>Error accediendo a la Base de Datos: " + e.getMessage() + "</div></td></tr>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("<div class='alert alert-warning'>Error cerrando el Query: " + e.getMessage() + "</div>"); }
            if (sentencia != null) try { sentencia.close(); } catch (SQLException e) { out.println("<div class='alert alert-warning'>Error cerrando la sentencia: " + e.getMessage() + "</div>"); }
            if (conexion != null) try { conexion.close(); } catch (SQLException e) { out.println("<div class='alert alert-warning'>Error cerrando la conexión: " + e.getMessage() + "</div>"); }
        }
        %>

        </tbody>
    </table>

    <div class="text-center mt-4">
        <a href="index.jsp" class="btn btn-primary">Regresar</a>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>