

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/

CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `ip` varchar(45) NOT NULL,
  `user_agent` varchar(255) NOT NULL,
  `accion` varchar(100) NOT NULL,
  `tabla_afectada` varchar(100) DEFAULT NULL,
  `registro_id` int(11) DEFAULT NULL,
  `detalle_antes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detalle_antes`)),
  `detalle_despues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detalle_despues`)),
  `fecha_hora` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `caracteristica` (
  `id_caracteristica` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `icono` varchar(50) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `cita` (
  `id_cita` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_agente` int(11) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `duracion_minutos` int(11) DEFAULT 30,
  `comentario_cliente` text DEFAULT NULL,
  `comentario_agente` text DEFAULT NULL,
  `estado` enum('SOLICITADA','CONFIRMADA','REALIZADA','CANCELADA','NO_ASISTIO') DEFAULT 'SOLICITADA',
  `fecha_solicitud` datetime DEFAULT current_timestamp(),
  `fecha_confirmacion` datetime DEFAULT NULL,
  `requiere_acompanante` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `ciudad` (
  `id_ciudad` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `departamento` varchar(100) NOT NULL,
  `pais` varchar(100) DEFAULT 'Colombia',
  `codigo_postal` varchar(10) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `documento_solicitud` (
  `id_documento` int(11) NOT NULL,
  `id_expediente` int(11) NOT NULL,
  `nombre_original` varchar(255) NOT NULL,
  `url_archivo` varchar(1000) NOT NULL,
  `tamano_kb` int(11) DEFAULT NULL,
  `extension` varchar(10) DEFAULT NULL,
  `fecha_subida` datetime DEFAULT current_timestamp(),
  `estado_verificacion` enum('PENDIENTE','VERIFICADO','RECHAZADO') DEFAULT 'PENDIENTE',
  `observacion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `expediente_drive` (
  `id_expediente` int(11) NOT NULL,
  `id_solicitud` int(11) NOT NULL,
  `url_drive` varchar(1000) NOT NULL,
  `fecha_compartido` datetime DEFAULT current_timestamp(),
  `ultima_revision` datetime DEFAULT NULL,
  `estado_revision` enum('PENDIENTE','EN_REVISION','APROBADO','INCOMPLETO') DEFAULT 'PENDIENTE',
  `observaciones_agente` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `favorito` (
  `id_usuario` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `fecha_agregado` datetime DEFAULT current_timestamp(),
  `nota` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `imagen_propiedad` (
  `id_imagen` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `ruta` varchar(500) NOT NULL,
  `nombre_original` varchar(255) NOT NULL,
  `es_principal` tinyint(1) DEFAULT 0,
  `orden` int(11) DEFAULT 0,
  `tamano_kb` int(11) DEFAULT NULL,
  `fecha_subida` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `inmobiliaria` (
  `id_inmobiliaria` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `razon_social` varchar(150) NOT NULL,
  `nit` varchar(20) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `direccion` varchar(255) NOT NULL,
  `id_ciudad` int(11) NOT NULL,
  `logo` varchar(500) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `estado` enum('ACTIVA','SUSPENDIDA','INACTIVA') DEFAULT 'ACTIVA'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `perfil` (
  `id_perfil` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `tipo_documento` enum('CC','CE','NIT','PASAPORTE') NOT NULL,
  `numero_documento` varchar(20) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `telefono_alternativo` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) NOT NULL,
  `barrio` varchar(100) DEFAULT NULL,
  `id_ciudad` int(11) DEFAULT NULL,
  `foto_perfil` varchar(500) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `genero` enum('M','F','OTRO') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE `propiedad` (
  `id_propiedad` int(11) NOT NULL,
  `id_inmobiliaria` int(11) NOT NULL,
  `id_tipo` int(11) NOT NULL,
  `id_ciudad` int(11) NOT NULL,
  `matricula_inmobiliaria` varchar(50) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` text NOT NULL,
  `direccion` varchar(255) NOT NULL,
  `barrio` varchar(100) NOT NULL,
  `estrato` enum('1','2','3','4','5','6') DEFAULT NULL,
  `precio_venta` decimal(15,2) DEFAULT NULL,
  `precio_arriendo` decimal(15,2) DEFAULT NULL,
  `area_construida` decimal(10,2) NOT NULL,
  `area_terreno` decimal(10,2) NOT NULL,
  `habitaciones` int(11) DEFAULT 0,
  `banos` int(11) DEFAULT 0,
  `parqueadero` tinyint(1) DEFAULT 0,
  `antiguedad` int(11) DEFAULT NULL,
  `estado_propiedad` enum('DISPONIBLE','EN_NEGOCIACION','VENDIDA','ARRENDADA','INACTIVA') DEFAULT 'DISPONIBLE',
  `fecha_publicacion` datetime DEFAULT current_timestamp(),
  `ultima_actualizacion` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `destacada` tinyint(1) DEFAULT 0,
  `visitas` int(11) DEFAULT 0
) ;



CREATE TABLE `propiedad_caracteristica` (
  `id_propiedad` int(11) NOT NULL,
  `id_caracteristica` int(11) NOT NULL,
  `cantidad` int(11) DEFAULT 1,
  `observacion` varchar(255) DEFAULT NULL
) ;



CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `solicitud` (
  `id_solicitud` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_agente` int(11) NOT NULL,
  `tipo` enum('COMPRA','ARRIENDO') NOT NULL,
  `monto_ofrecido` decimal(15,2) DEFAULT NULL,
  `plazo_meses` int(11) DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `comentario_cliente` text NOT NULL,
  `comentario_agente` text DEFAULT NULL,
  `estado` enum('RADICADA','EN_REVISION','APROBADA','RECHAZADA','CONTRATO_FIRMADO','CANCELADA') DEFAULT 'RADICADA',
  `fecha_radicacion` datetime DEFAULT current_timestamp(),
  `fecha_resolucion` datetime DEFAULT NULL,
  `resuelto_por` int(11) DEFAULT NULL,
  `numero_contrato` varchar(50) DEFAULT NULL,
  `valor_acordado` decimal(15,2) DEFAULT NULL,
  `fecha_firma` datetime DEFAULT NULL
) ;



CREATE TABLE `tipo_propiedad` (
  `id_tipo` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `icono` varchar(50) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `clave_hash` varchar(255) NOT NULL,
  `estado_cuenta` enum('ACTIVA','BLOQUEADA','INACTIVA') DEFAULT 'ACTIVA',
  `intentos_fallidos` int(11) DEFAULT 0,
  `fecha_bloqueo` datetime DEFAULT NULL,
  `ultimo_acceso` datetime DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `acepta_terminos` tinyint(1) DEFAULT 0
) ;


CREATE TABLE `usuario_rol` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `fecha_asignacion` datetime DEFAULT current_timestamp(),
  `asignado_por` int(11) DEFAULT NULL,
  `estado` enum('ACTIVO','REVOCADO') DEFAULT 'ACTIVO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `id_usuario` (`id_usuario`);

-
ALTER TABLE `caracteristica`
  ADD PRIMARY KEY (`id_caracteristica`),
  ADD UNIQUE KEY `nombre` (`nombre`);


ALTER TABLE `cita`
  ADD PRIMARY KEY (`id_cita`),
  ADD UNIQUE KEY `uk_cita_propiedad_fecha` (`id_propiedad`,`fecha_hora`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `idx_cita_estado` (`estado`),
  ADD KEY `idx_cita_fecha` (`fecha_hora`),
  ADD KEY `idx_agenda_citas` (`id_agente`,`estado`,`fecha_hora`);



ALTER TABLE `ciudad`
  ADD PRIMARY KEY (`id_ciudad`),
  ADD UNIQUE KEY `uk_ciudad_departamento` (`nombre`,`departamento`);


ALTER TABLE `documento_solicitud`
  ADD PRIMARY KEY (`id_documento`),
  ADD KEY `idx_documento_solicitud` (`id_expediente`);


ALTER TABLE `expediente_drive`
  ADD PRIMARY KEY (`id_expediente`),
  ADD UNIQUE KEY `id_solicitud` (`id_solicitud`),
  ADD KEY `idx_expediente_estado` (`estado_revision`);

--
-- Indices de la tabla `favorito`
--
ALTER TABLE `favorito`
  ADD PRIMARY KEY (`id_usuario`,`id_propiedad`),
  ADD KEY `id_propiedad` (`id_propiedad`);

--
-- Indices de la tabla `imagen_propiedad`
--
ALTER TABLE `imagen_propiedad`
  ADD PRIMARY KEY (`id_imagen`),
  ADD KEY `id_propiedad` (`id_propiedad`);

--
-- Indices de la tabla `inmobiliaria`
--
ALTER TABLE `inmobiliaria`
  ADD PRIMARY KEY (`id_inmobiliaria`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`),
  ADD UNIQUE KEY `razon_social` (`razon_social`),
  ADD UNIQUE KEY `nit` (`nit`),
  ADD KEY `id_ciudad` (`id_ciudad`);

--
-- Indices de la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD PRIMARY KEY (`id_perfil`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`),
  ADD UNIQUE KEY `numero_documento` (`numero_documento`),
  ADD KEY `id_ciudad` (`id_ciudad`);

--
-- Indices de la tabla `propiedad`
--
ALTER TABLE `propiedad`
  ADD PRIMARY KEY (`id_propiedad`),
  ADD UNIQUE KEY `matricula_inmobiliaria` (`matricula_inmobiliaria`),
  ADD KEY `id_inmobiliaria` (`id_inmobiliaria`),
  ADD KEY `idx_propiedad_ciudad` (`id_ciudad`),
  ADD KEY `idx_propiedad_tipo` (`id_tipo`),
  ADD KEY `idx_propiedad_estado` (`estado_propiedad`),
  ADD KEY `idx_buscador_propiedad` (`estado_propiedad`,`id_ciudad`,`id_tipo`,`precio_venta`);

--
-- Indices de la tabla `propiedad_caracteristica`
--
ALTER TABLE `propiedad_caracteristica`
  ADD PRIMARY KEY (`id_propiedad`,`id_caracteristica`),
  ADD KEY `id_caracteristica` (`id_caracteristica`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD PRIMARY KEY (`id_solicitud`),
  ADD UNIQUE KEY `numero_contrato` (`numero_contrato`),
  ADD KEY `id_propiedad` (`id_propiedad`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_agente` (`id_agente`),
  ADD KEY `resuelto_por` (`resuelto_por`),
  ADD KEY `idx_solicitud_estado` (`estado`);

--
-- Indices de la tabla `tipo_propiedad`
--
ALTER TABLE `tipo_propiedad`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indices de la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD PRIMARY KEY (`id_usuario`,`id_rol`),
  ADD KEY `id_rol` (`id_rol`),
  ADD KEY `asignado_por` (`asignado_por`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `caracteristica`
--
ALTER TABLE `caracteristica`
  MODIFY `id_caracteristica` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cita`
--
ALTER TABLE `cita`
  MODIFY `id_cita` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  MODIFY `id_ciudad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `documento_solicitud`
--
ALTER TABLE `documento_solicitud`
  MODIFY `id_documento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `expediente_drive`
--
ALTER TABLE `expediente_drive`
  MODIFY `id_expediente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `imagen_propiedad`
--
ALTER TABLE `imagen_propiedad`
  MODIFY `id_imagen` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `inmobiliaria`
--
ALTER TABLE `inmobiliaria`
  MODIFY `id_inmobiliaria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfil`
--
ALTER TABLE `perfil`
  MODIFY `id_perfil` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `propiedad`
--
ALTER TABLE `propiedad`
  MODIFY `id_propiedad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  MODIFY `id_solicitud` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipo_propiedad`
--
ALTER TABLE `tipo_propiedad`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `auditoria_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `cita`
--
ALTER TABLE `cita`
  ADD CONSTRAINT `cita_ibfk_1` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`),
  ADD CONSTRAINT `cita_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `cita_ibfk_3` FOREIGN KEY (`id_agente`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `documento_solicitud`
--
ALTER TABLE `documento_solicitud`
  ADD CONSTRAINT `documento_solicitud_ibfk_1` FOREIGN KEY (`id_expediente`) REFERENCES `expediente_drive` (`id_expediente`) ON DELETE CASCADE;

--
-- Filtros para la tabla `expediente_drive`
--
ALTER TABLE `expediente_drive`
  ADD CONSTRAINT `expediente_drive_ibfk_1` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE;

--
-- Filtros para la tabla `favorito`
--
ALTER TABLE `favorito`
  ADD CONSTRAINT `favorito_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorito_ibfk_2` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE;

--
-- Filtros para la tabla `imagen_propiedad`
--
ALTER TABLE `imagen_propiedad`
  ADD CONSTRAINT `imagen_propiedad_ibfk_1` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE;

--
-- Filtros para la tabla `inmobiliaria`
--
ALTER TABLE `inmobiliaria`
  ADD CONSTRAINT `inmobiliaria_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `inmobiliaria_ibfk_2` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`);

--
-- Filtros para la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD CONSTRAINT `perfil_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `perfil_ibfk_2` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`) ON DELETE SET NULL;

--
-- Filtros para la tabla `propiedad`
--
ALTER TABLE `propiedad`
  ADD CONSTRAINT `propiedad_ibfk_1` FOREIGN KEY (`id_inmobiliaria`) REFERENCES `inmobiliaria` (`id_inmobiliaria`),
  ADD CONSTRAINT `propiedad_ibfk_2` FOREIGN KEY (`id_tipo`) REFERENCES `tipo_propiedad` (`id_tipo`),
  ADD CONSTRAINT `propiedad_ibfk_3` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`);

--
-- Filtros para la tabla `propiedad_caracteristica`
--
ALTER TABLE `propiedad_caracteristica`
  ADD CONSTRAINT `propiedad_caracteristica_ibfk_1` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE,
  ADD CONSTRAINT `propiedad_caracteristica_ibfk_2` FOREIGN KEY (`id_caracteristica`) REFERENCES `caracteristica` (`id_caracteristica`) ON DELETE CASCADE;

--
-- Filtros para la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD CONSTRAINT `solicitud_ibfk_1` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`),
  ADD CONSTRAINT `solicitud_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `solicitud_ibfk_3` FOREIGN KEY (`id_agente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `solicitud_ibfk_4` FOREIGN KEY (`resuelto_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD CONSTRAINT `usuario_rol_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `usuario_rol_ibfk_2` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE,
  ADD CONSTRAINT `usuario_rol_ibfk_3` FOREIGN KEY (`asignado_por`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
