-- ============================================
-- DATOS SEMILLA - INMOBILIARIA (16 tablas)
-- Ejecutar DESPUÉS de 01_esquema.sql
-- ============================================

USE inmobiliaria_db;

-- ROLES ("Visitante" no se guarda: es cualquiera sin sesión iniciada)
INSERT INTO rol (nombre, descripcion) VALUES
('Cliente', 'Busca inmuebles, agenda citas y radica solicitudes'),
('Inmobiliaria', 'Administra propiedades, atiende citas y solicitudes'),
('Administrador', 'Gestiona usuarios, roles, catálogos y auditoría');

-- CATÁLOGOS MÍNIMOS
INSERT INTO ciudad (nombre, departamento) VALUES
('Bucaramanga', 'Santander'),
('Bogotá', 'Cundinamarca'),
('Medellín', 'Antioquia'),
('Floridablanca', 'Santander');

INSERT INTO tipo_propiedad (nombre) VALUES
('Apartamento'),
('Casa'),
('Local comercial'),
('Lote');

INSERT INTO caracteristica (nombre) VALUES
('Piscina'),
('Parqueadero cubierto'),
('Ascensor'),
('Zona verde'),
('Vigilancia 24h');

-- USUARIOS DE PRUEBA (clave para los tres: Clave123!)
-- Contraseñas de prueba: Clave123! | Formato: salt_hex:sha256_hex

-- 1) Administrador -----------------------------------------------------
INSERT INTO usuario (correo, clave_hash)
VALUES ('admin@inmobiliaria.com',
        '5b1c2779c818a92f5fe590abf8a4b72e:d1bdfe50aa22c217d1fdb8e1582943355a539f2b67f916d11f196ce606af81c1');

INSERT INTO perfil (id_usuario, nombres, apellidos, tipo_documento, numero_documento, telefono, direccion, id_ciudad)
VALUES (LAST_INSERT_ID(), 'Diana', 'Rojas', 'CC', '1000000001', '3001112233',
        'Calle 1 # 2-34', (SELECT id_ciudad FROM ciudad WHERE nombre = 'Bucaramanga'));

INSERT INTO usuario_rol (id_usuario, id_rol)
VALUES ((SELECT id_usuario FROM usuario WHERE correo = 'admin@inmobiliaria.com'),
        (SELECT id_rol FROM rol WHERE nombre = 'Administrador'));

-- 2) Inmobiliaria (agente) ----------------------------------------------
INSERT INTO usuario (correo, clave_hash)
VALUES ('agente@inmobiliaria.com',
        'fe5f78263f7c7a8d5d0d9a9f97f0110e:12d4c75a0d4b1d28eba3b0526c31eae05963f313d463fde0f5664cfd12748e96');

INSERT INTO perfil (id_usuario, nombres, apellidos, tipo_documento, numero_documento, telefono, direccion, id_ciudad)
VALUES (LAST_INSERT_ID(), 'Carlos', 'Rueda', 'CC', '1000000002', '3002223344',
        'Carrera 5 # 10-20', (SELECT id_ciudad FROM ciudad WHERE nombre = 'Bucaramanga'));

INSERT INTO usuario_rol (id_usuario, id_rol)
VALUES ((SELECT id_usuario FROM usuario WHERE correo = 'agente@inmobiliaria.com'),
        (SELECT id_rol FROM rol WHERE nombre = 'Inmobiliaria'));

INSERT INTO inmobiliaria (id_usuario, razon_social, nit, telefono, email, direccion, id_ciudad)
VALUES ((SELECT id_usuario FROM usuario WHERE correo = 'agente@inmobiliaria.com'),
        'Buen Hogar Inmobiliaria S.A.S.', '900123456-1', '6076001122',
        'contacto@buenhogar.com', 'Carrera 5 # 10-20',
        (SELECT id_ciudad FROM ciudad WHERE nombre = 'Bucaramanga'));

-- 3) Cliente --------------------------------------------------------------
INSERT INTO usuario (correo, clave_hash)
VALUES ('cliente@correo.com',
        '6b5b318b8450f6810b63a1984bd736fd:b78527f285be1990298f0c6568ae39fffab480ae585bec95f200b02a6e3388a5');

INSERT INTO perfil (id_usuario, nombres, apellidos, tipo_documento, numero_documento, telefono, direccion, id_ciudad)
VALUES (LAST_INSERT_ID(), 'Ana', 'Prada', 'CC', '1000000003', '3004445566',
        'Calle 20 # 15-08', (SELECT id_ciudad FROM ciudad WHERE nombre = 'Bucaramanga'));

INSERT INTO usuario_rol (id_usuario, id_rol)
VALUES ((SELECT id_usuario FROM usuario WHERE correo = 'cliente@correo.com'),
        (SELECT id_rol FROM rol WHERE nombre = 'Cliente'));

-- ============================================
-- UNA PROPIEDAD DE EJEMPLO (para probar buscador y fichas)
-- ============================================
INSERT INTO propiedad (id_inmobiliaria, id_tipo, id_ciudad, matricula_inmobiliaria,
                        titulo, descripcion, direccion, barrio, estrato,
                        precio_venta, area_construida, habitaciones, banos)
VALUES ((SELECT id_inmobiliaria FROM inmobiliaria WHERE nit = '900123456-1'),
        (SELECT id_tipo FROM tipo_propiedad WHERE nombre = 'Apartamento'),
        (SELECT id_ciudad FROM ciudad WHERE nombre = 'Bucaramanga'),
        'MAT-0001',
        'Apartamento moderno en Cabecera',
        'Amplio apartamento con excelente iluminación natural.',
        'Calle 36 # 25-10', 'Cabecera', '5',
        350000000, 85.50, 3, 2);

INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica)
VALUES ((SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = 'MAT-0001'),
        (SELECT id_caracteristica FROM caracteristica WHERE nombre = 'Ascensor')),
       ((SELECT id_propiedad FROM propiedad WHERE matricula_inmobiliaria = 'MAT-0001'),
        (SELECT id_caracteristica FROM caracteristica WHERE nombre = 'Parqueadero cubierto'));
