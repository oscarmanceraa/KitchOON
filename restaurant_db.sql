-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 13-11-2025 a las 06:15:19
-- Versión del servidor: 9.1.0
-- Versión de PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `restaurant_db`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_CrearOrdenCompleta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CrearOrdenCompleta` (IN `p_IdMesa` INT, IN `p_IdUsuario` INT, IN `p_IdEstado` INT, IN `p_NumeroComensales` INT, IN `p_Observaciones` TEXT)   BEGIN DECLARE v_IdOrden INT; START TRANSACTION; INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, NumeroComensales, Observaciones) VALUES (p_IdMesa, p_IdUsuario, p_IdEstado, p_NumeroComensales, p_Observaciones); SET v_IdOrden = LAST_INSERT_ID(); COMMIT; SELECT v_IdOrden AS IdOrden; END$$

DROP PROCEDURE IF EXISTS `sp_ObtenerEstadisticas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ObtenerEstadisticas` (IN `p_FechaInicio` DATETIME, IN `p_FechaFin` DATETIME)   BEGIN DECLARE v_FechaInicio DATETIME; DECLARE v_FechaFin DATETIME; SET v_FechaInicio = IFNULL(p_FechaInicio, CURDATE()); SET v_FechaFin = IFNULL(p_FechaFin, DATE_ADD(CURDATE(), INTERVAL 1 DAY)); SELECT COUNT(*) AS TotalOrdenes, COUNT(CASE WHEN e.Estado = 'Completada' THEN 1 END) AS OrdenesCompletadas, COUNT(CASE WHEN e.Estado = 'Cancelada' THEN 1 END) AS OrdenesCanceladas, COUNT(CASE WHEN e.Estado NOT IN ('Completada', 'Cancelada') THEN 1 END) AS OrdenesActivas, IFNULL(SUM(CASE WHEN e.Estado = 'Completada' THEN Total ELSE 0 END), 0) AS IngresosTotales, IFNULL(AVG(CASE WHEN e.Estado = 'Completada' THEN Total END), 0) AS PromedioOrden FROM Ordenes o INNER JOIN Estados e ON o.IdEstado = e.IdEstado WHERE o.FechaCreacion BETWEEN v_FechaInicio AND v_FechaFin; SELECT pr.NombreProducto, SUM(po.Cantidad) AS TotalVendidos, SUM(po.Cantidad * po.PrecioUnitario) AS IngresosTotales FROM ProductosOrden po INNER JOIN Productos pr ON po.IdProducto = pr.IdProducto INNER JOIN Ordenes o ON po.IdOrden = o.IdOrden INNER JOIN Estados e ON o.IdEstado = e.IdEstado WHERE e.Estado = 'Completada' AND o.FechaCreacion BETWEEN v_FechaInicio AND v_FechaFin GROUP BY pr.IdProducto, pr.NombreProducto ORDER BY TotalVendidos DESC LIMIT 5; END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE IF NOT EXISTS `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE IF NOT EXISTS `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissions_group_id_b120cbf9` (`group_id`),
  KEY `auth_group_permissions_permission_id_84c5c92e` (`permission_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE IF NOT EXISTS `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  KEY `auth_permission_content_type_id_2f476e4b` (`content_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add content type', 5, 'add_contenttype'),
(18, 'Can change content type', 5, 'change_contenttype'),
(19, 'Can delete content type', 5, 'delete_contenttype'),
(20, 'Can view content type', 5, 'view_contenttype'),
(21, 'Can add session', 6, 'add_session'),
(22, 'Can change session', 6, 'change_session'),
(23, 'Can delete session', 6, 'delete_session'),
(24, 'Can view session', 6, 'view_session'),
(25, 'Can add Estado', 7, 'add_estado'),
(26, 'Can change Estado', 7, 'change_estado'),
(27, 'Can delete Estado', 7, 'delete_estado'),
(28, 'Can view Estado', 7, 'view_estado'),
(29, 'Can add Tipo de Producto', 8, 'add_tipoproducto'),
(30, 'Can change Tipo de Producto', 8, 'change_tipoproducto'),
(31, 'Can delete Tipo de Producto', 8, 'delete_tipoproducto'),
(32, 'Can view Tipo de Producto', 8, 'view_tipoproducto'),
(33, 'Can add Tipo de Usuario', 9, 'add_tipousuario'),
(34, 'Can change Tipo de Usuario', 9, 'change_tipousuario'),
(35, 'Can delete Tipo de Usuario', 9, 'delete_tipousuario'),
(36, 'Can view Tipo de Usuario', 9, 'view_tipousuario'),
(37, 'Can add Persona', 10, 'add_persona'),
(38, 'Can change Persona', 10, 'change_persona'),
(39, 'Can delete Persona', 10, 'delete_persona'),
(40, 'Can view Persona', 10, 'view_persona'),
(41, 'Can add Usuario', 11, 'add_usuario'),
(42, 'Can change Usuario', 11, 'change_usuario'),
(43, 'Can delete Usuario', 11, 'delete_usuario'),
(44, 'Can view Usuario', 11, 'view_usuario'),
(45, 'Can add Producto', 12, 'add_producto'),
(46, 'Can change Producto', 12, 'change_producto'),
(47, 'Can delete Producto', 12, 'delete_producto'),
(48, 'Can view Producto', 12, 'view_producto'),
(49, 'Can add Mesa', 13, 'add_mesa'),
(50, 'Can change Mesa', 13, 'change_mesa'),
(51, 'Can delete Mesa', 13, 'delete_mesa'),
(52, 'Can view Mesa', 13, 'view_mesa'),
(53, 'Can add Orden', 14, 'add_orden'),
(54, 'Can change Orden', 14, 'change_orden'),
(55, 'Can delete Orden', 14, 'delete_orden'),
(56, 'Can view Orden', 14, 'view_orden'),
(57, 'Can add Producto de Orden', 15, 'add_productoorden'),
(58, 'Can change Producto de Orden', 15, 'change_productoorden'),
(59, 'Can delete Producto de Orden', 15, 'delete_productoorden'),
(60, 'Can view Producto de Orden', 15, 'view_productoorden'),
(61, 'Can add Mensaje', 16, 'add_mensaje'),
(62, 'Can change Mensaje', 16, 'change_mensaje'),
(63, 'Can delete Mensaje', 16, 'delete_mensaje'),
(64, 'Can view Mensaje', 16, 'view_mensaje');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE IF NOT EXISTS `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
CREATE TABLE IF NOT EXISTS `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_user_id_6a12ed8b` (`user_id`),
  KEY `auth_user_groups_group_id_97559544` (`group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
CREATE TABLE IF NOT EXISTS `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permissions_user_id_a95ead1b` (`user_id`),
  KEY `auth_user_user_permissions_permission_id_1fbb5f2c` (`permission_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE IF NOT EXISTS `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE utf8mb4_unicode_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6` (`user_id`)
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE IF NOT EXISTS `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(2, 'auth', 'permission'),
(3, 'auth', 'group'),
(4, 'auth', 'user'),
(5, 'contenttypes', 'contenttype'),
(6, 'sessions', 'session'),
(7, 'restaurant', 'estado'),
(8, 'restaurant', 'tipoproducto'),
(9, 'restaurant', 'tipousuario'),
(10, 'restaurant', 'persona'),
(11, 'restaurant', 'usuario'),
(12, 'restaurant', 'producto'),
(13, 'restaurant', 'mesa'),
(14, 'restaurant', 'orden'),
(15, 'restaurant', 'productoorden'),
(16, 'restaurant', 'mensaje');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE IF NOT EXISTS `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2025-11-13 05:48:55.572570'),
(2, 'auth', '0001_initial', '2025-11-13 05:48:56.124998'),
(3, 'admin', '0001_initial', '2025-11-13 05:48:56.301765'),
(4, 'admin', '0002_logentry_remove_auto_add', '2025-11-13 05:48:56.308352'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2025-11-13 05:48:56.314428'),
(6, 'contenttypes', '0002_remove_content_type_name', '2025-11-13 05:48:56.401847'),
(7, 'auth', '0002_alter_permission_name_max_length', '2025-11-13 05:48:56.438114'),
(8, 'auth', '0003_alter_user_email_max_length', '2025-11-13 05:48:56.471722'),
(9, 'auth', '0004_alter_user_username_opts', '2025-11-13 05:48:56.478697'),
(10, 'auth', '0005_alter_user_last_login_null', '2025-11-13 05:48:56.510823'),
(11, 'auth', '0006_require_contenttypes_0002', '2025-11-13 05:48:56.513787'),
(12, 'auth', '0007_alter_validators_add_error_messages', '2025-11-13 05:48:56.525215'),
(13, 'auth', '0008_alter_user_username_max_length', '2025-11-13 05:48:56.557717'),
(14, 'auth', '0009_alter_user_last_name_max_length', '2025-11-13 05:48:56.591258'),
(15, 'auth', '0010_alter_group_name_max_length', '2025-11-13 05:48:56.625115'),
(16, 'auth', '0011_update_proxy_permissions', '2025-11-13 05:48:56.635387'),
(17, 'auth', '0012_alter_user_first_name_max_length', '2025-11-13 05:48:56.672533'),
(18, 'sessions', '0001_initial', '2025-11-13 05:48:56.716751');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_session`
--

DROP TABLE IF EXISTS `django_session`;
CREATE TABLE IF NOT EXISTS `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados`
--

DROP TABLE IF EXISTS `estados`;
CREATE TABLE IF NOT EXISTS `estados` (
  `IdEstado` int NOT NULL AUTO_INCREMENT,
  `Estado` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`IdEstado`),
  UNIQUE KEY `Estado` (`Estado`)
) ;

--
-- Volcado de datos para la tabla `estados`
--

INSERT INTO `estados` (`IdEstado`, `Estado`, `Descripcion`) VALUES
(1, 'Activo', 'Elemento activo en el sistema'),
(2, 'Inactivo', 'Elemento inactivo'),
(3, 'Pendiente', 'Orden pendiente de procesar'),
(4, 'En Preparación', 'Orden siendo preparada'),
(5, 'Servida', 'Orden servida al cliente'),
(6, 'Completada', 'Orden completada y pagada'),
(7, 'Cancelada', 'Orden cancelada'),
(8, 'Disponible', 'Mesa disponible'),
(9, 'Ocupada', 'Mesa ocupada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes`
--

DROP TABLE IF EXISTS `mensajes`;
CREATE TABLE IF NOT EXISTS `mensajes` (
  `IdMensaje` int NOT NULL AUTO_INCREMENT,
  `IdEmisor` int NOT NULL,
  `IdReceptor` int NOT NULL,
  `Mensaje` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `FechaEnvio` datetime DEFAULT CURRENT_TIMESTAMP,
  `Leido` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`IdMensaje`),
  KEY `IX_Mensajes_Emisor` (`IdEmisor`),
  KEY `IX_Mensajes_Receptor` (`IdReceptor`),
  KEY `IX_Mensajes_FechaEnvio` (`FechaEnvio`),
  KEY `IX_Mensajes_Leido` (`Leido`,`IdReceptor`)
) ;

--
-- Volcado de datos para la tabla `mensajes`
--

INSERT INTO `mensajes` (`IdMensaje`, `IdEmisor`, `IdReceptor`, `Mensaje`, `FechaEnvio`, `Leido`) VALUES
(1, 2, 3, 'La mesa 3 pregunta si pueden agregar extra de queso a las hamburguesas', '2025-11-13 00:30:37', 1),
(2, 3, 2, 'Sí, sin problema. Ya está agregado.', '2025-11-13 00:31:37', 1),
(3, 1, 2, 'Recuerda actualizar el inventario al final del turno', '2025-11-12 22:55:37', 0),
(4, 4, 3, 'La mesa 6 tiene una alergia a mariscos, por favor verificar ingredientes', '2025-11-13 00:45:37', 1),
(5, 3, 4, 'Confirmado, preparando sin ingredientes marinos', '2025-11-13 00:46:37', 1),
(6, 2, 1, 'Mesa 9 solicita música más baja para celebración', '2025-11-13 00:52:37', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mesas`
--

DROP TABLE IF EXISTS `mesas`;
CREATE TABLE IF NOT EXISTS `mesas` (
  `IdMesa` int NOT NULL AUTO_INCREMENT,
  `NumeroMesa` int NOT NULL,
  `Capacidad` int NOT NULL,
  `IdEstado` int NOT NULL,
  `Ubicacion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`IdMesa`),
  UNIQUE KEY `NumeroMesa` (`NumeroMesa`),
  KEY `IX_Mesas_NumeroMesa` (`NumeroMesa`),
  KEY `IX_Mesas_Estado` (`IdEstado`)
) ;

--
-- Volcado de datos para la tabla `mesas`
--

INSERT INTO `mesas` (`IdMesa`, `NumeroMesa`, `Capacidad`, `IdEstado`, `Ubicacion`) VALUES
(1, 1, 4, 8, 'Interior - Ventana'),
(2, 2, 4, 8, 'Interior - Centro'),
(3, 3, 2, 9, 'Interior - Esquina'),
(4, 4, 6, 8, 'Interior - Centro'),
(5, 5, 4, 8, 'Interior - Ventana'),
(6, 6, 4, 9, 'Terraza - Exterior'),
(7, 7, 6, 8, 'Terraza - Exterior'),
(8, 8, 2, 8, 'Terraza - Bar'),
(9, 9, 4, 8, 'Terraza - Jardín'),
(10, 10, 8, 8, 'Privado - VIP');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ordenes`
--

DROP TABLE IF EXISTS `ordenes`;
CREATE TABLE IF NOT EXISTS `ordenes` (
  `IdOrden` int NOT NULL AUTO_INCREMENT,
  `IdMesa` int NOT NULL,
  `IdUsuario` int NOT NULL,
  `IdEstado` int NOT NULL,
  `FechaCreacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `FechaActualizacion` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `FechaInicioCocina` datetime DEFAULT NULL,
  `FechaFinalizacion` datetime DEFAULT NULL,
  `NumeroComensales` int DEFAULT '1',
  `Observaciones` text COLLATE utf8mb4_unicode_ci,
  `Total` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`IdOrden`),
  KEY `IX_Ordenes_Mesa` (`IdMesa`),
  KEY `IX_Ordenes_Usuario` (`IdUsuario`),
  KEY `IX_Ordenes_Estado` (`IdEstado`),
  KEY `IX_Ordenes_FechaCreacion` (`FechaCreacion` DESC)
) ;

--
-- Volcado de datos para la tabla `ordenes`
--

INSERT INTO `ordenes` (`IdOrden`, `IdMesa`, `IdUsuario`, `IdEstado`, `FechaCreacion`, `FechaActualizacion`, `FechaInicioCocina`, `FechaFinalizacion`, `NumeroComensales`, `Observaciones`, `Total`) VALUES
(1, 3, 2, 4, '2025-11-13 00:25:37', '2025-11-13 00:55:37', '2025-11-13 00:30:37', NULL, 2, 'Sin cebolla en las hamburguesas', 300.00),
(2, 6, 4, 3, '2025-11-13 00:40:37', '2025-11-13 00:55:37', NULL, NULL, 4, NULL, 430.00),
(3, 1, 2, 5, '2025-11-12 22:55:37', '2025-11-13 00:55:37', '2025-11-12 23:05:37', '2025-11-12 23:25:37', 3, 'Mesa preferencial', 550.00),
(4, 5, 6, 6, '2025-11-12 20:55:37', '2025-11-13 00:55:37', '2025-11-12 21:05:37', '2025-11-12 21:35:37', 2, NULL, 470.00),
(5, 9, 2, 3, '2025-11-13 00:50:37', '2025-11-13 00:55:37', NULL, NULL, 5, 'Celebración de cumpleaños', 735.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

DROP TABLE IF EXISTS `personas`;
CREATE TABLE IF NOT EXISTS `personas` (
  `IdPersona` int NOT NULL AUTO_INCREMENT,
  `PrimerNombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `SegundoNombre` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PrimerApellido` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `SegundoApellido` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `FechaNacimiento` date DEFAULT NULL,
  `Telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Direccion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`IdPersona`),
  KEY `IX_Personas_Email` (`Email`),
  KEY `IX_Personas_Nombres` (`PrimerNombre`,`PrimerApellido`)
) ;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`IdPersona`, `PrimerNombre`, `SegundoNombre`, `PrimerApellido`, `SegundoApellido`, `FechaNacimiento`, `Telefono`, `Email`, `Direccion`) VALUES
(1, 'Juan', 'Carlos', 'Pérez', 'González', '1985-03-15', '555-0001', 'admin@restaurant.com', 'Calle Principal 123'),
(2, 'María', 'Isabel', 'García', 'López', '1990-07-22', '555-0002', 'maria@restaurant.com', 'Avenida Central 456'),
(3, 'Carlos', 'Alberto', 'Martínez', 'Rodríguez', '1988-11-30', '555-0003', 'carlos@restaurant.com', 'Boulevard Norte 789'),
(4, 'Ana', 'Patricia', 'López', 'Hernández', '1992-05-18', '555-0004', 'ana@restaurant.com', 'Calle Sur 321'),
(5, 'Luis', 'Fernando', 'Rodríguez', 'Sánchez', '1987-09-25', '555-0005', 'luis@restaurant.com', 'Avenida Este 654'),
(6, 'Carmen', 'Rosa', 'Sánchez', 'Ramírez', '1991-12-10', '555-0006', 'carmen@restaurant.com', 'Calle Oeste 987');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

DROP TABLE IF EXISTS `productos`;
CREATE TABLE IF NOT EXISTS `productos` (
  `IdProducto` int NOT NULL AUTO_INCREMENT,
  `IdTipoProducto` int NOT NULL,
  `IdEstado` int NOT NULL,
  `NombreProducto` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` text COLLATE utf8mb4_unicode_ci,
  `Precio` decimal(10,2) NOT NULL,
  `TiempoPreparacion` int NOT NULL,
  PRIMARY KEY (`IdProducto`),
  KEY `IX_Productos_TipoProducto` (`IdTipoProducto`),
  KEY `IX_Productos_Estado` (`IdEstado`),
  KEY `IX_Productos_Nombre` (`NombreProducto`)
) ;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`IdProducto`, `IdTipoProducto`, `IdEstado`, `NombreProducto`, `Descripcion`, `Precio`, `TiempoPreparacion`) VALUES
(1, 1, 1, 'Hamburguesa Clásica', 'Hamburguesa de carne con queso, lechuga y tomate', 120.00, 15),
(2, 1, 1, 'Pizza Margarita', 'Pizza con salsa de tomate, mozzarella y albahaca', 180.00, 20),
(3, 1, 1, 'Tacos de Bistec', 'Orden de 3 tacos de bistec con cebolla y cilantro', 95.00, 12),
(4, 1, 1, 'Pasta Alfredo', 'Pasta con salsa Alfredo y pollo', 145.00, 18),
(5, 1, 1, 'Burrito de Pollo', 'Burrito relleno de pollo, frijoles y queso', 110.00, 15),
(6, 4, 1, 'Ensalada César', 'Lechuga romana, crutones y aderezo césar', 85.00, 10),
(7, 4, 1, 'Alitas BBQ', 'Orden de 8 alitas con salsa BBQ', 95.00, 15),
(8, 4, 1, 'Nachos con Queso', 'Nachos con queso fundido y jalapeños', 75.00, 8),
(9, 2, 1, 'Refresco', 'Refresco de 355ml', 30.00, 2),
(10, 2, 1, 'Agua Natural', 'Agua embotellada 500ml', 20.00, 1),
(11, 2, 1, 'Jugo Natural', 'Jugo natural de frutas 300ml', 45.00, 5),
(12, 2, 1, 'Café Americano', 'Café americano caliente', 35.00, 3),
(13, 3, 1, 'Pastel de Chocolate', 'Delicioso pastel de chocolate', 65.00, 5),
(14, 3, 1, 'Flan Napolitano', 'Flan casero con caramelo', 55.00, 5),
(15, 3, 1, 'Helado de Vainilla', 'Copa de helado de vainilla', 45.00, 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productosorden`
--

DROP TABLE IF EXISTS `productosorden`;
CREATE TABLE IF NOT EXISTS `productosorden` (
  `IdProductoOrden` int NOT NULL AUTO_INCREMENT,
  `IdOrden` int NOT NULL,
  `IdProducto` int NOT NULL,
  `Cantidad` int DEFAULT '1',
  `PrecioUnitario` decimal(10,2) NOT NULL,
  `Observaciones` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`IdProductoOrden`),
  KEY `IX_ProductosOrden_Orden` (`IdOrden`),
  KEY `IX_ProductosOrden_Producto` (`IdProducto`)
) ;

--
-- Volcado de datos para la tabla `productosorden`
--

INSERT INTO `productosorden` (`IdProductoOrden`, `IdOrden`, `IdProducto`, `Cantidad`, `PrecioUnitario`, `Observaciones`) VALUES
(1, 1, 1, 2, 120.00, 'Sin cebolla'),
(2, 1, 9, 2, 30.00, NULL),
(3, 2, 2, 1, 180.00, NULL),
(4, 2, 6, 2, 85.00, NULL),
(5, 2, 10, 4, 20.00, NULL),
(6, 3, 3, 3, 95.00, 'Extra salsa'),
(7, 3, 11, 3, 45.00, NULL),
(8, 3, 13, 2, 65.00, NULL),
(9, 4, 4, 2, 145.00, NULL),
(10, 4, 12, 2, 35.00, NULL),
(11, 4, 14, 2, 55.00, NULL),
(12, 5, 5, 3, 110.00, NULL),
(13, 5, 7, 2, 95.00, 'Extra picante'),
(14, 5, 9, 5, 30.00, NULL),
(15, 5, 13, 1, 65.00, 'Con vela de cumpleaños');

--
-- Disparadores `productosorden`
--
DROP TRIGGER IF EXISTS `TR_ProductosOrden_Delete_ActualizarTotal`;
DELIMITER $$
CREATE TRIGGER `TR_ProductosOrden_Delete_ActualizarTotal` AFTER DELETE ON `productosorden` FOR EACH ROW BEGIN UPDATE Ordenes SET Total = ( SELECT IFNULL(SUM(Cantidad * PrecioUnitario), 0) FROM ProductosOrden WHERE IdOrden = OLD.IdOrden ) WHERE IdOrden = OLD.IdOrden; END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `TR_ProductosOrden_Insert_ActualizarTotal`;
DELIMITER $$
CREATE TRIGGER `TR_ProductosOrden_Insert_ActualizarTotal` AFTER INSERT ON `productosorden` FOR EACH ROW BEGIN UPDATE Ordenes SET Total = ( SELECT IFNULL(SUM(Cantidad * PrecioUnitario), 0) FROM ProductosOrden WHERE IdOrden = NEW.IdOrden ) WHERE IdOrden = NEW.IdOrden; END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `TR_ProductosOrden_Update_ActualizarTotal`;
DELIMITER $$
CREATE TRIGGER `TR_ProductosOrden_Update_ActualizarTotal` AFTER UPDATE ON `productosorden` FOR EACH ROW BEGIN UPDATE Ordenes SET Total = ( SELECT IFNULL(SUM(Cantidad * PrecioUnitario), 0) FROM ProductosOrden WHERE IdOrden = NEW.IdOrden ) WHERE IdOrden = NEW.IdOrden; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiposproducto`
--

DROP TABLE IF EXISTS `tiposproducto`;
CREATE TABLE IF NOT EXISTS `tiposproducto` (
  `IdTipoProducto` int NOT NULL AUTO_INCREMENT,
  `TipoProducto` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`IdTipoProducto`),
  UNIQUE KEY `TipoProducto` (`TipoProducto`)
) ;

--
-- Volcado de datos para la tabla `tiposproducto`
--

INSERT INTO `tiposproducto` (`IdTipoProducto`, `TipoProducto`, `Descripcion`) VALUES
(1, 'Comida', 'Platos principales'),
(2, 'Bebida', 'Bebidas frías y calientes'),
(3, 'Postre', 'Postres y dulces'),
(4, 'Entrada', 'Entradas y aperitivos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiposusuario`
--

DROP TABLE IF EXISTS `tiposusuario`;
CREATE TABLE IF NOT EXISTS `tiposusuario` (
  `IdTipoUsuario` int NOT NULL AUTO_INCREMENT,
  `TipoUsuario` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Descripcion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`IdTipoUsuario`),
  UNIQUE KEY `TipoUsuario` (`TipoUsuario`)
) ;

--
-- Volcado de datos para la tabla `tiposusuario`
--

INSERT INTO `tiposusuario` (`IdTipoUsuario`, `TipoUsuario`, `Descripcion`) VALUES
(1, 'Administrador', 'Usuario con acceso completo'),
(2, 'Mesero', 'Personal de atención al cliente'),
(3, 'Cocina', 'Personal de cocina');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `IdUsuario` int NOT NULL AUTO_INCREMENT,
  `IdPersona` int NOT NULL,
  `IdTipoUsuario` int NOT NULL,
  `IdEstado` int NOT NULL,
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `FechaCreacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `UltimoAcceso` datetime DEFAULT NULL,
  PRIMARY KEY (`IdUsuario`),
  UNIQUE KEY `Username` (`Username`),
  KEY `IX_Usuarios_Username` (`Username`),
  KEY `IX_Usuarios_Persona` (`IdPersona`),
  KEY `IX_Usuarios_TipoUsuario` (`IdTipoUsuario`),
  KEY `IX_Usuarios_Estado` (`IdEstado`)
) ;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`IdUsuario`, `IdPersona`, `IdTipoUsuario`, `IdEstado`, `Username`, `Password`, `FechaCreacion`, `UltimoAcceso`) VALUES
(1, 1, 1, 1, 'admin', 'admin123', '2025-11-13 00:55:36', NULL),
(2, 2, 2, 1, 'mesero1', 'mesero123', '2025-11-13 00:55:36', NULL),
(3, 3, 3, 1, 'cocina1', 'cocina123', '2025-11-13 00:55:36', NULL),
(4, 4, 2, 1, 'mesero2', 'mesero123', '2025-11-13 00:55:36', NULL),
(5, 5, 3, 1, 'cocina2', 'cocina123', '2025-11-13 00:55:36', NULL),
(6, 6, 2, 1, 'mesero3', 'mesero123', '2025-11-13 00:55:36', NULL);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_ordenescompletas`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_ordenescompletas`;
CREATE TABLE IF NOT EXISTS `vw_ordenescompletas` (
`IdOrden` int
,`NumeroComensales` int
,`ObservacionesOrden` text
,`Total` decimal(10,2)
,`FechaCreacion` datetime
,`FechaActualizacion` datetime
,`FechaInicioCocina` datetime
,`FechaFinalizacion` datetime
,`NumeroMesa` int
,`CapacidadMesa` int
,`UbicacionMesa` varchar(100)
,`Username` varchar(50)
,`PrimerNombre` varchar(50)
,`PrimerApellido` varchar(50)
,`NombreCompleto` varchar(101)
,`TipoUsuario` varchar(50)
,`EstadoOrden` varchar(50)
,`TotalProductos` bigint
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_productoscompletos`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_productoscompletos`;
CREATE TABLE IF NOT EXISTS `vw_productoscompletos` (
`IdProducto` int
,`NombreProducto` varchar(100)
,`Descripcion` text
,`Precio` decimal(10,2)
,`TiempoPreparacion` int
,`TipoProducto` varchar(50)
,`EstadoProducto` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_usuarioscompletos`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_usuarioscompletos`;
CREATE TABLE IF NOT EXISTS `vw_usuarioscompletos` (
`IdUsuario` int
,`Username` varchar(50)
,`FechaCreacion` datetime
,`UltimoAcceso` datetime
,`PrimerNombre` varchar(50)
,`SegundoNombre` varchar(50)
,`PrimerApellido` varchar(50)
,`SegundoApellido` varchar(50)
,`NombreCompleto` varchar(101)
,`Email` varchar(100)
,`Telefono` varchar(20)
,`TipoUsuario` varchar(50)
,`EstadoUsuario` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_ordenescompletas`
--
DROP TABLE IF EXISTS `vw_ordenescompletas`;

DROP VIEW IF EXISTS `vw_ordenescompletas`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_ordenescompletas`  AS SELECT `o`.`IdOrden` AS `IdOrden`, `o`.`NumeroComensales` AS `NumeroComensales`, `o`.`Observaciones` AS `ObservacionesOrden`, `o`.`Total` AS `Total`, `o`.`FechaCreacion` AS `FechaCreacion`, `o`.`FechaActualizacion` AS `FechaActualizacion`, `o`.`FechaInicioCocina` AS `FechaInicioCocina`, `o`.`FechaFinalizacion` AS `FechaFinalizacion`, `m`.`NumeroMesa` AS `NumeroMesa`, `m`.`Capacidad` AS `CapacidadMesa`, `m`.`Ubicacion` AS `UbicacionMesa`, `u`.`Username` AS `Username`, `p`.`PrimerNombre` AS `PrimerNombre`, `p`.`PrimerApellido` AS `PrimerApellido`, concat(`p`.`PrimerNombre`,' ',`p`.`PrimerApellido`) AS `NombreCompleto`, `tu`.`TipoUsuario` AS `TipoUsuario`, `e`.`Estado` AS `EstadoOrden`, (select count(0) from `productosorden` `po` where (`po`.`IdOrden` = `o`.`IdOrden`)) AS `TotalProductos` FROM (((((`ordenes` `o` join `mesas` `m` on((`o`.`IdMesa` = `m`.`IdMesa`))) join `usuarios` `u` on((`o`.`IdUsuario` = `u`.`IdUsuario`))) join `personas` `p` on((`u`.`IdPersona` = `p`.`IdPersona`))) join `tiposusuario` `tu` on((`u`.`IdTipoUsuario` = `tu`.`IdTipoUsuario`))) join `estados` `e` on((`o`.`IdEstado` = `e`.`IdEstado`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_productoscompletos`
--
DROP TABLE IF EXISTS `vw_productoscompletos`;

DROP VIEW IF EXISTS `vw_productoscompletos`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_productoscompletos`  AS SELECT `pr`.`IdProducto` AS `IdProducto`, `pr`.`NombreProducto` AS `NombreProducto`, `pr`.`Descripcion` AS `Descripcion`, `pr`.`Precio` AS `Precio`, `pr`.`TiempoPreparacion` AS `TiempoPreparacion`, `tp`.`TipoProducto` AS `TipoProducto`, `e`.`Estado` AS `EstadoProducto` FROM ((`productos` `pr` join `tiposproducto` `tp` on((`pr`.`IdTipoProducto` = `tp`.`IdTipoProducto`))) join `estados` `e` on((`pr`.`IdEstado` = `e`.`IdEstado`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_usuarioscompletos`
--
DROP TABLE IF EXISTS `vw_usuarioscompletos`;

DROP VIEW IF EXISTS `vw_usuarioscompletos`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_usuarioscompletos`  AS SELECT `u`.`IdUsuario` AS `IdUsuario`, `u`.`Username` AS `Username`, `u`.`FechaCreacion` AS `FechaCreacion`, `u`.`UltimoAcceso` AS `UltimoAcceso`, `p`.`PrimerNombre` AS `PrimerNombre`, `p`.`SegundoNombre` AS `SegundoNombre`, `p`.`PrimerApellido` AS `PrimerApellido`, `p`.`SegundoApellido` AS `SegundoApellido`, concat(`p`.`PrimerNombre`,' ',`p`.`PrimerApellido`) AS `NombreCompleto`, `p`.`Email` AS `Email`, `p`.`Telefono` AS `Telefono`, `tu`.`TipoUsuario` AS `TipoUsuario`, `e`.`Estado` AS `EstadoUsuario` FROM (((`usuarios` `u` join `personas` `p` on((`u`.`IdPersona` = `p`.`IdPersona`))) join `tiposusuario` `tu` on((`u`.`IdTipoUsuario` = `tu`.`IdTipoUsuario`))) join `estados` `e` on((`u`.`IdEstado` = `e`.`IdEstado`))) ;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `mensajes`
--
ALTER TABLE `mensajes`
  ADD CONSTRAINT `FK_Mensajes_Emisor` FOREIGN KEY (`IdEmisor`) REFERENCES `usuarios` (`IdUsuario`),
  ADD CONSTRAINT `FK_Mensajes_Receptor` FOREIGN KEY (`IdReceptor`) REFERENCES `usuarios` (`IdUsuario`);

--
-- Filtros para la tabla `mesas`
--
ALTER TABLE `mesas`
  ADD CONSTRAINT `FK_Mesas_Estados` FOREIGN KEY (`IdEstado`) REFERENCES `estados` (`IdEstado`);

--
-- Filtros para la tabla `ordenes`
--
ALTER TABLE `ordenes`
  ADD CONSTRAINT `FK_Ordenes_Estados` FOREIGN KEY (`IdEstado`) REFERENCES `estados` (`IdEstado`),
  ADD CONSTRAINT `FK_Ordenes_Mesas` FOREIGN KEY (`IdMesa`) REFERENCES `mesas` (`IdMesa`),
  ADD CONSTRAINT `FK_Ordenes_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `usuarios` (`IdUsuario`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `FK_Productos_Estados` FOREIGN KEY (`IdEstado`) REFERENCES `estados` (`IdEstado`),
  ADD CONSTRAINT `FK_Productos_TiposProducto` FOREIGN KEY (`IdTipoProducto`) REFERENCES `tiposproducto` (`IdTipoProducto`);

--
-- Filtros para la tabla `productosorden`
--
ALTER TABLE `productosorden`
  ADD CONSTRAINT `FK_ProductosOrden_Ordenes` FOREIGN KEY (`IdOrden`) REFERENCES `ordenes` (`IdOrden`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_ProductosOrden_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `productos` (`IdProducto`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `FK_Usuarios_Estados` FOREIGN KEY (`IdEstado`) REFERENCES `estados` (`IdEstado`),
  ADD CONSTRAINT `FK_Usuarios_Personas` FOREIGN KEY (`IdPersona`) REFERENCES `personas` (`IdPersona`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_Usuarios_TiposUsuario` FOREIGN KEY (`IdTipoUsuario`) REFERENCES `tiposusuario` (`IdTipoUsuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
