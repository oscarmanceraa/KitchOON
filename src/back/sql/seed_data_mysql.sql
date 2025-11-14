-- =============================================
-- Script de datos iniciales para MySQL
-- Sistema kitchON - Gestión de Restaurante
-- =============================================

USE restaurant_db;

-- Deshabilitar verificaciones de claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

-- Limpiar datos existentes (solo para desarrollo)
TRUNCATE TABLE Mensajes;
TRUNCATE TABLE ProductosOrden;
TRUNCATE TABLE Ordenes;
TRUNCATE TABLE Mesas;
TRUNCATE TABLE Productos;
TRUNCATE TABLE Usuarios;
TRUNCATE TABLE Personas;
TRUNCATE TABLE TiposUsuario;
TRUNCATE TABLE TiposProducto;
TRUNCATE TABLE Estados;

-- Habilitar verificaciones de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- DATOS CATÁLOGO
-- =============================================

-- Estados
INSERT INTO Estados (Estado, Descripcion) VALUES
('Activo', 'Elemento activo en el sistema'),
('Inactivo', 'Elemento inactivo'),
('Pendiente', 'Orden pendiente de procesar'),
('En Preparación', 'Orden siendo preparada'),
('Servida', 'Orden servida al cliente'),
('Completada', 'Orden completada y pagada'),
('Cancelada', 'Orden cancelada'),
('Disponible', 'Mesa disponible'),
('Ocupada', 'Mesa ocupada');

-- Tipos de Producto
INSERT INTO TiposProducto (TipoProducto, Descripcion) VALUES
('Comida', 'Platos principales'),
('Bebida', 'Bebidas frías y calientes'),
('Postre', 'Postres y dulces'),
('Entrada', 'Entradas y aperitivos');

-- Tipos de Usuario
INSERT INTO TiposUsuario (TipoUsuario, Descripcion) VALUES
('Administrador', 'Usuario con acceso completo'),
('Mesero', 'Personal de atención al cliente'),
('Cocina', 'Personal de cocina');

-- =============================================
-- PERSONAS
-- =============================================

INSERT INTO Personas (PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, FechaNacimiento, Telefono, Email, Direccion) VALUES
('Juan', 'Carlos', 'Pérez', 'González', '1985-03-15', '555-0001', 'admin@restaurant.com', 'Calle Principal 123'),
('María', 'Isabel', 'García', 'López', '1990-07-22', '555-0002', 'maria@restaurant.com', 'Avenida Central 456'),
('Carlos', 'Alberto', 'Martínez', 'Rodríguez', '1988-11-30', '555-0003', 'carlos@restaurant.com', 'Boulevard Norte 789'),
('Ana', 'Patricia', 'López', 'Hernández', '1992-05-18', '555-0004', 'ana@restaurant.com', 'Calle Sur 321'),
('Luis', 'Fernando', 'Rodríguez', 'Sánchez', '1987-09-25', '555-0005', 'luis@restaurant.com', 'Avenida Este 654'),
('Carmen', 'Rosa', 'Sánchez', 'Ramírez', '1991-12-10', '555-0006', 'carmen@restaurant.com', 'Calle Oeste 987');

-- =============================================
-- USUARIOS
-- =============================================

INSERT INTO Usuarios (IdPersona, IdTipoUsuario, IdEstado, Username, Password) VALUES
(1, 1, 1, 'admin', 'admin123'),
(2, 2, 1, 'mesero1', 'mesero123'),
(3, 3, 1, 'cocina1', 'cocina123'),
(4, 2, 1, 'mesero2', 'mesero123'),
(5, 3, 1, 'cocina2', 'cocina123'),
(6, 2, 1, 'mesero3', 'mesero123');

-- =============================================
-- PRODUCTOS
-- =============================================

INSERT INTO Productos (IdTipoProducto, IdEstado, NombreProducto, Descripcion, Precio, TiempoPreparacion) VALUES
-- Comidas
(1, 1, 'Hamburguesa Clásica', 'Hamburguesa de carne con queso, lechuga y tomate', 120.00, 15),
(1, 1, 'Pizza Margarita', 'Pizza con salsa de tomate, mozzarella y albahaca', 180.00, 20),
(1, 1, 'Tacos de Bistec', 'Orden de 3 tacos de bistec con cebolla y cilantro', 95.00, 12),
(1, 1, 'Pasta Alfredo', 'Pasta con salsa Alfredo y pollo', 145.00, 18),
(1, 1, 'Burrito de Pollo', 'Burrito relleno de pollo, frijoles y queso', 110.00, 15),
-- Entradas
(4, 1, 'Ensalada César', 'Lechuga romana, crutones y aderezo césar', 85.00, 10),
(4, 1, 'Alitas BBQ', 'Orden de 8 alitas con salsa BBQ', 95.00, 15),
(4, 1, 'Nachos con Queso', 'Nachos con queso fundido y jalapeños', 75.00, 8),
-- Bebidas
(2, 1, 'Refresco', 'Refresco de 355ml', 30.00, 2),
(2, 1, 'Agua Natural', 'Agua embotellada 500ml', 20.00, 1),
(2, 1, 'Jugo Natural', 'Jugo natural de frutas 300ml', 45.00, 5),
(2, 1, 'Café Americano', 'Café americano caliente', 35.00, 3),
-- Postres
(3, 1, 'Pastel de Chocolate', 'Delicioso pastel de chocolate', 65.00, 5),
(3, 1, 'Flan Napolitano', 'Flan casero con caramelo', 55.00, 5),
(3, 1, 'Helado de Vainilla', 'Copa de helado de vainilla', 45.00, 3);

-- =============================================
-- MESAS
-- =============================================

INSERT INTO Mesas (NumeroMesa, Capacidad, IdEstado, Ubicacion) VALUES
(1, 4, 8, 'Interior - Ventana'),
(2, 4, 8, 'Interior - Centro'),
(3, 2, 9, 'Interior - Esquina'),
(4, 6, 8, 'Interior - Centro'),
(5, 4, 8, 'Interior - Ventana'),
(6, 4, 9, 'Terraza - Exterior'),
(7, 6, 8, 'Terraza - Exterior'),
(8, 2, 8, 'Terraza - Bar'),
(9, 4, 8, 'Terraza - Jardín'),
(10, 8, 8, 'Privado - VIP');

-- =============================================
-- ÓRDENES DE EJEMPLO
-- =============================================

-- Orden 1 - En Preparación
INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, FechaCreacion, FechaInicioCocina, NumeroComensales, Observaciones) VALUES
(3, 2, 4, DATE_SUB(NOW(), INTERVAL 30 MINUTE), DATE_SUB(NOW(), INTERVAL 25 MINUTE), 2, 'Sin cebolla en las hamburguesas');

-- Orden 2 - Pendiente
INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(6, 4, 3, DATE_SUB(NOW(), INTERVAL 15 MINUTE), 4, NULL);

-- Orden 3 - Servida
INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, FechaCreacion, FechaInicioCocina, FechaFinalizacion, NumeroComensales, Observaciones) VALUES
(1, 2, 5, DATE_SUB(NOW(), INTERVAL 2 HOUR), DATE_SUB(NOW(), INTERVAL 110 MINUTE), DATE_SUB(NOW(), INTERVAL 90 MINUTE), 3, 'Mesa preferencial');

-- Orden 4 - Completada
INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, FechaCreacion, FechaInicioCocina, FechaFinalizacion, NumeroComensales, Observaciones) VALUES
(5, 6, 6, DATE_SUB(NOW(), INTERVAL 4 HOUR), DATE_SUB(NOW(), INTERVAL 230 MINUTE), DATE_SUB(NOW(), INTERVAL 200 MINUTE), 2, NULL);

-- Orden 5 - Pendiente
INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(9, 2, 3, DATE_SUB(NOW(), INTERVAL 5 MINUTE), 5, 'Celebración de cumpleaños');

-- =============================================
-- PRODUCTOS DE ÓRDENES
-- =============================================

-- Productos para Orden 1
INSERT INTO ProductosOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(1, 1, 2, 120.00, 'Sin cebolla'),
(1, 9, 2, 30.00, NULL);

-- Productos para Orden 2
INSERT INTO ProductosOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(2, 2, 1, 180.00, NULL),
(2, 6, 2, 85.00, NULL),
(2, 10, 4, 20.00, NULL);

-- Productos para Orden 3
INSERT INTO ProductosOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(3, 3, 3, 95.00, 'Extra salsa'),
(3, 11, 3, 45.00, NULL),
(3, 13, 2, 65.00, NULL);

-- Productos para Orden 4
INSERT INTO ProductosOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(4, 4, 2, 145.00, NULL),
(4, 12, 2, 35.00, NULL),
(4, 14, 2, 55.00, NULL);

-- Productos para Orden 5
INSERT INTO ProductosOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(5, 5, 3, 110.00, NULL),
(5, 7, 2, 95.00, 'Extra picante'),
(5, 9, 5, 30.00, NULL),
(5, 13, 1, 65.00, 'Con vela de cumpleaños');

-- =============================================
-- MENSAJES DE EJEMPLO
-- =============================================

INSERT INTO Mensajes (IdEmisor, IdReceptor, Mensaje, FechaEnvio, Leido) VALUES
(2, 3, 'La mesa 3 pregunta si pueden agregar extra de queso a las hamburguesas', DATE_SUB(NOW(), INTERVAL 25 MINUTE), TRUE),
(3, 2, 'Sí, sin problema. Ya está agregado.', DATE_SUB(NOW(), INTERVAL 24 MINUTE), TRUE),
(1, 2, 'Recuerda actualizar el inventario al final del turno', DATE_SUB(NOW(), INTERVAL 2 HOUR), FALSE),
(4, 3, 'La mesa 6 tiene una alergia a mariscos, por favor verificar ingredientes', DATE_SUB(NOW(), INTERVAL 10 MINUTE), TRUE),
(3, 4, 'Confirmado, preparando sin ingredientes marinos', DATE_SUB(NOW(), INTERVAL 9 MINUTE), TRUE),
(2, 1, 'Mesa 9 solicita música más baja para celebración', DATE_SUB(NOW(), INTERVAL 3 MINUTE), FALSE);

-- Verificar que los totales estén correctos (los triggers deberían haberlo hecho)
-- Pero lo forzamos por si acaso
UPDATE Ordenes o
SET Total = (
    SELECT IFNULL(SUM(po.Cantidad * po.PrecioUnitario), 0)
    FROM ProductosOrden po
    WHERE po.IdOrden = o.IdOrden
);

SELECT '==============================================' AS Separador;
SELECT 'Datos iniciales cargados exitosamente para kitchON' AS Mensaje;
SELECT '==============================================' AS Separador;
SELECT '' AS Linea;
SELECT 'Credenciales de acceso:' AS Info;
SELECT '  Admin:   admin / admin123' AS Credencial1;
SELECT '  Mesero:  mesero1 / mesero123' AS Credencial2;
SELECT '  Cocina:  cocina1 / cocina123' AS Credencial3;
SELECT '' AS Linea;
SELECT 'Base de datos lista para usar con phpMyAdmin!' AS Estado;
