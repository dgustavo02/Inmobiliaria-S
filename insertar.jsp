<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.Statement"%>
<%@ page import="java.sql.DriverManager"%>
<%@ page import="java.sql.SQLException"%>

<%
String nombre_equipo = request.getParameter("nombre");
String Id = request.getParameter("idEquipo");
String categoria = request.getParameter("categoria");
String marca = request.getParameter("marca");
String fecha = request.getParameter("fecha");
String precio = request.getParameter("precio");
String estado = request.getParameter("estado");
String observaciones = request.getParameter("observaciones"); 

Connection conexion = null;
Statement sentencia = null;

int filas = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");

    conexion = DriverManager.getConnection(
        "jdbc:mysql://bvwzcgztc073pq8l0hcw-mysql.services.clever-cloud.com:3306/bvwzcgztc073pq8l0hcw", "u8sze2iu8jddnirk", "Jgn7HNmwGURGIAVt39zd");

    sentencia = conexion.createStatement();

    String consultaSQL = "INSERT INTO quiz (nombre_equipo, Id, categoria, marca, fecha, estado, observaciones, precio) VALUES ";
consultaSQL += "('" + nombre_equipo + "', '" + Id + "', '" + categoria + "', '" + marca + "', '" + fecha + "', '" + estado + "', '" + observaciones + "', '" + precio + "')";

    filas = sentencia.executeUpdate(consultaSQL);

    response.sendRedirect("mostrar.jsp");

} catch (ClassNotFoundException e) {
    out.println("Error accediendo a la Base de Datos: " + e.getMessage());
} catch (SQLException e) {
    out.println("Error SQL: " + e.getMessage());
} finally {
    if (sentencia != null) {
        try { sentencia.close(); }
        catch (SQLException e) {
            out.println("Error cerrando la sentencia: " + e.getMessage());
        }
    }
    if (conexion != null) {
        try { conexion.close(); }
        catch (SQLException e) {
            out.println("Error cerrando la conexión: " + e.getMessage());
        }
    }
}
%>
