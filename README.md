# Inmobiliaria - JSP + JSPF + JDBC + Tomcat

Proyecto académico para **Visual Studio Code + Apache Tomcat 9 + MySQL**, manteniendo la arquitectura basada en JSP/JSPF del parcial.

## Tecnologías
- Java EE / JSP
- JSPF (`conexion.jspf`, `utilidades.jspf`, `seguridad.jspf`, `cabecera.jspf`, `pie.jspf`)
- JDBC
- MySQL
- HTML5, CSS3, JavaScript y Bootstrap
- Apache Tomcat 9 (`javax.servlet`)

## Seguridad
Las contraseñas se almacenan mediante **SHA-256 + salt aleatorio de 16 bytes**.
El formato guardado en `usuario.clave_hash` es:

`salt_hex:hash_hex`

La implementación está en `WEB-INF/jspf/utilidades.jspf`.

## Estructura importante
- `index.jsp`: landing page pública.
- `login.jsp`, `acceso.jsp`: autenticación.
- `registro.jsp`, `registrar.jsp`: registro.
- `cliente/`, `agente/`, `admin/`: módulos por rol.
- `WEB-INF/jspf/conexion.jspf`: conexión JDBC centralizada y cierre de recursos.
- `WEB-INF/jspf/utilidades.jspf`: SHA-256 + salt y utilidades.
- `WEB-INF/jspf/seguridad.jspf`: validación de sesión/rol.
- `WEB-INF/classes/com/inmobiliaria/filtros/FiltroAutenticacion.class`: filtro compilado para Tomcat 9.
- `sql/01_esquema.sql`: DDL.
- `sql/02_datos_semilla.sql`: DML y usuarios de prueba.

## Antes de ejecutar
1. Crear la base de datos ejecutando `sql/01_esquema.sql`.
2. Ejecutar `sql/02_datos_semilla.sql`.
3. Colocar el driver MySQL Connector/J en `WEB-INF/lib/`.
4. Revisar usuario, contraseña y nombre de BD en `WEB-INF/jspf/conexion.jspf`.
5. Copiar la carpeta `Inmobiliaria` a `apache-tomcat-9.x/webapps/`.
6. Iniciar Tomcat.
7. Abrir `http://localhost:8080/Inmobiliaria/`.

## Usuarios de prueba
Todos usan la contraseña: `Clave123!`

- `admin@inmobiliaria.com` — Administrador
- `agente@inmobiliaria.com` — Inmobiliaria
- `cliente@correo.com` — Cliente

## Nota sobre Tomcat
Este proyecto utiliza `javax.servlet`, por lo que está preparado para **Tomcat 9**. No usar Tomcat 10/11 sin migrar a `jakarta.servlet`.
