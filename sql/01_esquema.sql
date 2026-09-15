-- ============================================
-- BASE DE DATOS - INMOBILIARIA (16 tablas)
-- Basado en el esquema de referencia del usuario, agregando
-- únicamente las columnas que el proyecto JSP ya construido necesita
-- para funcionar. Cada adición lleva un comentario "-- (para ...)".
-- Sin campos decorativos (logo, icono, foto_perfil, etc.)
-- ============================================

CREATE DATABASE IF NOT EXISTS inmobiliaria_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE inmobiliaria_db;

-- 1. CIUDAD
CREATE TABLE ciudad (
    id_ciudad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,           -- (para registro.jsp / admin/catalogos.jsp)
    codigo_postal VARCHAR(10) NULL,
    estado TINYINT(1) DEFAULT 1,
    -- nombre solo no puede ser UNIQUE: hay municipios homónimos en
    -- distintos departamentos (ej. "La Unión" en Antioquia y Nariño)
    CONSTRAINT uk_ciudad_departamento UNIQUE (nombre, departamento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. ROL
CREATE TABLE rol (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. TIPO_PROPIEDAD
CREATE TABLE tipo_propiedad (
    id_tipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. CARACTERISTICA
CREATE TABLE caracteristica (
    id_caracteristica INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. USUARIO
CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    correo VARCHAR(100) UNIQUE NOT NULL,
    clave_hash VARCHAR(255) NOT NULL,
    estado_cuenta ENUM('ACTIVA', 'BLOQUEADA', 'INACTIVA') DEFAULT 'ACTIVA',
    intentos_fallidos INT DEFAULT 0,
    fecha_bloqueo DATETIME NULL,                  -- (para el bloqueo temporal en acceso.jsp)
    ultimo_acceso DATETIME NULL,                  -- (para acceso.jsp: se actualiza en cada login)
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. PERFIL (Relación 1:1 con Usuario)
CREATE TABLE perfil (
    id_perfil INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    tipo_documento ENUM('CC', 'CE', 'NIT', 'PASAPORTE') NOT NULL,
    numero_documento VARCHAR(20) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    id_ciudad INT NULL,
    fecha_nacimiento DATE NULL,
    genero ENUM('M', 'F', 'OTRO') NULL,
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_perfil_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. USUARIO_ROL (Relación N:M)
CREATE TABLE usuario_rol (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    asignado_por INT NULL,                        -- (para admin/accion_usuario.jsp: quién asignó el rol)
    estado ENUM('ACTIVO', 'REVOCADO') DEFAULT 'ACTIVO',
    PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT fk_uro_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_uro_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE,
    CONSTRAINT fk_uro_asignador FOREIGN KEY (asignado_por) REFERENCES usuario(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. INMOBILIARIA
CREATE TABLE inmobiliaria (
    id_inmobiliaria INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT UNIQUE NOT NULL,
    razon_social VARCHAR(150) UNIQUE NOT NULL,
    nit VARCHAR(20) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    id_ciudad INT NOT NULL,
    descripcion TEXT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('ACTIVA', 'SUSPENDIDA', 'INACTIVA') DEFAULT 'ACTIVA',
    CONSTRAINT fk_inm_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_inm_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. PROPIEDAD (1:N desde Inmobiliaria)
CREATE TABLE propiedad (
    id_propiedad INT PRIMARY KEY AUTO_INCREMENT,
    id_inmobiliaria INT NOT NULL,
    id_tipo INT NOT NULL,
    id_ciudad INT NOT NULL,
    matricula_inmobiliaria VARCHAR(50) UNIQUE NOT NULL,
    titulo VARCHAR(200) NOT NULL,                 -- (para catalogo.jsp / propiedad.jsp: nombre del anuncio)
    descripcion TEXT NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    barrio VARCHAR(100) NOT NULL,                 -- (para el buscador y la ficha de detalle)
    estrato ENUM('1','2','3','4','5','6') NULL,   -- (para la ficha de detalle)
    precio_venta DECIMAL(15,2) NULL,
    precio_arriendo DECIMAL(15,2) NULL,
    area_construida DECIMAL(10,2) NOT NULL,
    area_terreno DECIMAL(10,2) NULL,              -- (para el formulario de propiedad)
    habitaciones INT DEFAULT 0,
    banos INT DEFAULT 0,
    parqueadero TINYINT(1) DEFAULT 0,              -- (para la ficha de detalle)
    estado_propiedad ENUM('DISPONIBLE', 'EN_NEGOCIACION', 'VENDIDA', 'ARRENDADA', 'INACTIVA') DEFAULT 'DISPONIBLE',
    fecha_publicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultima_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    destacada TINYINT(1) DEFAULT 0,
    visitas INT DEFAULT 0,                         -- (contador simple en propiedad.jsp / reportes)
    CONSTRAINT fk_prop_inmobiliaria FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria) ON DELETE RESTRICT,
    CONSTRAINT fk_prop_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo) ON DELETE RESTRICT,
    CONSTRAINT fk_prop_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. IMAGEN_PROPIEDAD (1:N desde Propiedad)
CREATE TABLE imagen_propiedad (
    id_imagen INT PRIMARY KEY AUTO_INCREMENT,
    id_propiedad INT NOT NULL,
    ruta VARCHAR(500) NOT NULL,
    nombre_original VARCHAR(255) NOT NULL,
    es_principal TINYINT(1) DEFAULT 0,
    orden INT DEFAULT 0,                           -- (para ordenar la galería en propiedad.jsp)
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_img_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. PROPIEDAD_CARACTERISTICA (Relación N:M)
CREATE TABLE propiedad_caracteristica (
    id_propiedad INT NOT NULL,
    id_caracteristica INT NOT NULL,
    cantidad INT DEFAULT 1,
    observacion VARCHAR(255) NULL,
    PRIMARY KEY (id_propiedad, id_caracteristica),
    CONSTRAINT fk_pca_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    CONSTRAINT fk_pca_caracteristica FOREIGN KEY (id_caracteristica) REFERENCES caracteristica(id_caracteristica) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. FAVORITO
CREATE TABLE favorito (
    id_usuario INT NOT NULL,
    id_propiedad INT NOT NULL,
    fecha_agregado DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_propiedad),
    CONSTRAINT fk_fav_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_fav_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. CITA (Restricción UNIQUE id_propiedad + fecha_hora)
CREATE TABLE cita (
    id_cita INT PRIMARY KEY AUTO_INCREMENT,
    id_propiedad INT NOT NULL,
    id_cliente INT NOT NULL,
    id_agente INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    comentario_cliente TEXT NULL,
    estado ENUM('SOLICITADA', 'CONFIRMADA', 'REALIZADA', 'CANCELADA', 'NO_ASISTIO') DEFAULT 'SOLICITADA',
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_confirmacion DATETIME NULL,
    requiere_acompanante TINYINT(1) DEFAULT 0,
    CONSTRAINT uk_cita_propiedad_horario UNIQUE (id_propiedad, fecha_hora),
    CONSTRAINT fk_cita_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_cliente FOREIGN KEY (id_cliente) REFERENCES usuario(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_agente FOREIGN KEY (id_agente) REFERENCES usuario(id_usuario) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. SOLICITUD
CREATE TABLE solicitud (
    id_solicitud INT PRIMARY KEY AUTO_INCREMENT,
    id_propiedad INT NOT NULL,
    id_cliente INT NOT NULL,
    id_agente INT NOT NULL,
    tipo ENUM('COMPRA', 'ARRIENDO') NOT NULL,
    monto_ofrecido DECIMAL(15,2) NOT NULL,        -- (para nueva_solicitud.jsp: monto que ofrece el cliente)
    plazo_meses INT NULL,
    comentario_cliente TEXT NOT NULL,
    comentario_agente TEXT NULL,
    estado ENUM('RADICADA', 'EN_REVISION', 'APROBADA', 'RECHAZADA', 'CONTRATO_FIRMADO', 'CANCELADA') DEFAULT 'RADICADA',
    fecha_radicacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion DATETIME NULL,               -- (para agente/accion.jsp: cuándo se aprobó/rechazó)
    resuelto_por INT NULL,                        -- (para agente/accion.jsp: qué agente la resolvió)
    numero_contrato VARCHAR(50) UNIQUE NULL,
    valor_acordado DECIMAL(15,2) NULL,
    fecha_firma DATETIME NULL,
    CONSTRAINT fk_sol_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE RESTRICT,
    CONSTRAINT fk_sol_cliente FOREIGN KEY (id_cliente) REFERENCES usuario(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_sol_agente FOREIGN KEY (id_agente) REFERENCES usuario(id_usuario) ON DELETE RESTRICT,
    CONSTRAINT fk_sol_resuelto_por FOREIGN KEY (resuelto_por) REFERENCES usuario(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. DOCUMENTO_SOLICITUD (1:N desde Solicitud; reemplaza a expediente_drive)
CREATE TABLE documento_solicitud (
    id_documento INT PRIMARY KEY AUTO_INCREMENT,
    id_solicitud INT NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    url_archivo VARCHAR(1000) NOT NULL,
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doc_solicitud FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. AUDITORIA
CREATE TABLE auditoria (
    id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NULL,
    user_agent VARCHAR(255) NOT NULL,
    accion VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NULL,
    registro_id INT NULL,
    detalle_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL CHECK (json_valid(`detalle_antes`)),
    detalle_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL CHECK (json_valid(`detalle_despues`)),
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_aud_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ÍNDICES PARA RENDIMIENTO
-- ============================================
CREATE INDEX idx_propiedad_ciudad ON propiedad(id_ciudad);
CREATE INDEX idx_propiedad_tipo ON propiedad(id_tipo);
CREATE INDEX idx_propiedad_estado ON propiedad(estado_propiedad);
CREATE INDEX idx_cita_estado ON cita(estado);
CREATE INDEX idx_cita_fecha ON cita(fecha_hora);
CREATE INDEX idx_solicitud_estado ON solicitud(estado);
CREATE INDEX idx_documento_solicitud ON documento_solicitud(id_solicitud);
