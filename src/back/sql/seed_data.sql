-- =============================================
-- Script de datos iniciales para SQL Server
-- Sistema de Gestión de Restaurante
-- =============================================

USE restaurant_db;
GO

-- Limpiar datos existentes (solo para desarrollo)
DELETE FROM Mensajes;
DELETE FROM ProductosOrden;
DELETE FROM Ordenes;
DELETE FROM Mesas;
DELETE FROM Productos;
DELETE FROM Usuarios;
DELETE FROM Personas;
DELETE FROM TiposUsuario;
DELETE FROM TiposProducto;
DELETE FROM Estados;

-- Resetear contadores de identidad
DBCC CHECKIDENT ('Mensajes', RESEED, 0);
DBCC CHECKIDENT ('ProductosOrden', RESEED, 0);
DBCC CHECKIDENT ('Ordenes', RESEED, 0);
DBCC CHECKIDENT ('Mesas', RESEED, 0);
DBCC CHECKIDENT ('Productos', RESEED, 0);
DBCC CHECKIDENT ('Usuarios', RESEED, 0);
DBCC CHECKIDENT ('Personas', RESEED, 0);
DBCC CHECKIDENT ('TiposUsuario', RESEED, 0);
DBCC CHECKIDENT ('TiposProducto', RESEED, 0);
DBCC CHECKIDENT ('Estados', RESEED, 0);
GO

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
GO

-- Tipos de Producto
INSERT INTO TiposProducto (TipoProducto, Descripcion) VALUES
('Comida', 'Platos principales'),
('Bebida', 'Bebidas frías y calientes'),
('Postre', 'Postres y dulces'),
('Entrada', 'Entradas y aperitivos');
GO

-- Tipos de Usuario
INSERT INTO TiposUsuario (TipoUsuario, Descripcion) VALUES
('Administrador', 'Usuario con acceso completo'),
('Mesero', 'Personal de atención al cliente'),
('Cocina', 'Personal de cocina');
GO

-- =============================================
-- PERSONAS
-- =============================================

SET IDENTITY_INSERT Personas ON;

INSERT INTO Personas (IdPersona, PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, FechaNacimiento, Telefono, Email, Direccion) VALUES
(1, 'Juan', 'Carlos', 'Pérez', 'González', '1985-03-15', '555-0001', 'admin@restaurant.com', 'Calle Principal 123'),
(2, 'María', 'Isabel', 'García', 'López', '1990-07-22', '555-0002', 'maria@restaurant.com', 'Avenida Central 456'),
(3, 'Carlos', 'Alberto', 'Martínez', 'Rodríguez', '1988-11-30', '555-0003', 'carlos@restaurant.com', 'Boulevard Norte 789'),
(4, 'Ana', 'Patricia', 'López', 'Hernández', '1992-05-18', '555-0004', 'ana@restaurant.com', 'Calle Sur 321'),
(5, 'Luis', 'Fernando', 'Rodríguez', 'Sánchez', '1987-09-25', '555-0005', 'luis@restaurant.com', 'Avenida Este 654'),
(6, 'Carmen', 'Rosa', 'Sánchez', 'Ramírez', '1991-12-10', '555-0006', 'carmen@restaurant.com', 'Calle Oeste 987');

SET IDENTITY_INSERT Personas OFF;
GO

-- =============================================
-- USUARIOS
-- =============================================

SET IDENTITY_INSERT Usuarios ON;

INSERT INTO Usuarios (IdUsuario, IdPersona, IdTipoUsuario, IdEstado, Username, Password, FechaCreacion, UltimoAcceso) VALUES
(1, 1, 1, 1, 'admin', 'admin123', GETDATE(), NULL),
(2, 2, 2, 1, 'mesero1', 'mesero123', GETDATE(), NULL),
(3, 3, 3, 1, 'cocina1', 'cocina123', GETDATE(), NULL),
(4, 4, 2, 1, 'mesero2', 'mesero123', GETDATE(), NULL),
(5, 5, 3, 1, 'cocina2', 'cocina123', GETDATE(), NULL),
(6, 6, 2, 1, 'mesero3', 'mesero123', GETDATE(), NULL);

SET IDENTITY_INSERT Usuarios OFF;
GO

-- =============================================
-- PRODUCTOS
-- =============================================

SET IDENTITY_INSERT Productos ON;

INSERT INTO Productos (IdProducto, IdTipoProducto, IdEstado, NombreProducto, Descripcion, Precio, TiempoPreparacion) VALUES
-- Comidas
(1, 1, 1, 'Hamburguesa Clásica', 'Hamburguesa de carne con queso, lechuga y tomate', 120.00, 15),
(2, 1, 1, 'Pizza Margarita', 'Pizza con salsa de tomate, mozzarella y albahaca', 180.00, 20),
(3, 1, 1, 'Tacos de Bistec', 'Orden de 3 tacos de bistec con cebolla y cilantro', 95.00, 12),
(4, 1, 1, 'Pasta Alfredo', 'Pasta con salsa Alfredo y pollo', 145.00, 18),
(5, 1, 1, 'Burrito de Pollo', 'Burrito relleno de pollo, frijoles y queso', 110.00, 15),
-- Entradas
(6, 4, 1, 'Ensalada César', 'Lechuga romana, crutones y aderezo césar', 85.00, 10),
(7, 4, 1, 'Alitas BBQ', 'Orden de 8 alitas con salsa BBQ', 95.00, 15),
(8, 4, 1, 'Nachos con Queso', 'Nachos con queso fundido y jalapeños', 75.00, 8),
-- Bebidas
(9, 2, 1, 'Refresco', 'Refresco de 355ml', 30.00, 2),
(10, 2, 1, 'Agua Natural', 'Agua embotellada 500ml', 20.00, 1),
(11, 2, 1, 'Jugo Natural', 'Jugo natural de frutas 300ml', 45.00, 5),
(12, 2, 1, 'Café Americano', 'Café americano caliente', 35.00, 3),
-- Postres
(13, 3, 1, 'Pastel de Chocolate', 'Delicioso pastel de chocolate', 65.00, 5),
(14, 3, 1, 'Flan Napolitano', 'Flan casero con caramelo', 55.00, 5),
(15, 3, 1, 'Helado de Vainilla', 'Copa de helado de vainilla', 45.00, 3);

SET IDENTITY_INSERT Productos OFF;
GO

-- =============================================
-- MESAS
-- =============================================

SET IDENTITY_INSERT Mesas ON;

INSERT INTO Mesas (IdMesa, NumeroMesa, Capacidad, IdEstado, Ubicacion) VALUES
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

SET IDENTITY_INSERT Mesas OFF;
GO

-- =============================================
-- ÓRDENES DE EJEMPLO
-- =============================================

SET IDENTITY_INSERT Ordenes ON;

-- Orden 1 - En Preparación
INSERT INTO Ordenes (IdOrden, IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(1, 3, 2, 4, DATEADD(MINUTE, -30, GETDATE()), 2, 'Sin cebolla en las hamburguesas');

-- Orden 2 - Pendiente
INSERT INTO Ordenes (IdOrden, IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(2, 6, 4, 3, DATEADD(MINUTE, -15, GETDATE()), 4, NULL);

-- Orden 3 - Servida
INSERT INTO Ordenes (IdOrden, IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(3, 1, 2, 5, DATEADD(HOUR, -2, GETDATE()), 3, 'Mesa preferencial');

-- Orden 4 - Completada
INSERT INTO Ordenes (IdOrden, IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(4, 5, 6, 6, DATEADD(HOUR, -4, GETDATE()), 2, NULL);

-- Orden 5 - Pendiente
INSERT INTO Ordenes (IdOrden, IdMesa, IdUsuario, IdEstado, FechaCreacion, NumeroComensales, Observaciones) VALUES
(5, 9, 2, 3, DATEADD(MINUTE, -5, GETDATE()), 5, 'Celebración de cumpleaños');

SET IDENTITY_INSERT Ordenes OFF;
GO

-- =============================================
-- PRODUCTOS DE ÓRDENES
-- =============================================

SET IDENTITY_INSERT ProductosOrden ON;

-- Productos para Orden 1
INSERT INTO ProductosOrden (IdProductoOrden, IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(1, 1, 1, 2, 120.00, 'Sin cebolla'),
(2, 1, 9, 2, 30.00, NULL);

-- Productos para Orden 2
INSERT INTO ProductosOrden (IdProductoOrden, IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(3, 2, 2, 1, 180.00, NULL),
(4, 2, 6, 2, 85.00, NULL),
(5, 2, 10, 4, 20.00, NULL);

-- Productos para Orden 3
INSERT INTO ProductosOrden (IdProductoOrden, IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(6, 3, 3, 3, 95.00, 'Extra salsa'),
(7, 3, 11, 3, 45.00, NULL),
(8, 3, 13, 2, 65.00, NULL);

-- Productos para Orden 4
INSERT INTO ProductosOrden (IdProductoOrden, IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(9, 4, 4, 2, 145.00, NULL),
(10, 4, 12, 2, 35.00, NULL),
(11, 4, 14, 2, 55.00, NULL);

-- Productos para Orden 5
INSERT INTO ProductosOrden (IdProductoOrden, IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones) VALUES
(12, 5, 5, 3, 110.00, NULL),
(13, 5, 7, 2, 95.00, 'Extra picante'),
(14, 5, 9, 5, 30.00, NULL),
(15, 5, 13, 1, 65.00, 'Con vela de cumpleaños');

SET IDENTITY_INSERT ProductosOrden OFF;
GO

-- =============================================
-- MENSAJES DE EJEMPLO
-- =============================================

SET IDENTITY_INSERT Mensajes ON;

INSERT INTO Mensajes (IdMensaje, IdEmisor, IdReceptor, Mensaje, FechaEnvio, Leido) VALUES
(1, 2, 3, 'La mesa 3 pregunta si pueden agregar extra de queso a las hamburguesas', DATEADD(MINUTE, -25, GETDATE()), 1),
(2, 3, 2, 'Sí, sin problema. Ya está agregado.', DATEADD(MINUTE, -24, GETDATE()), 1),
(3, 1, 2, 'Recuerda actualizar el inventario al final del turno', DATEADD(HOUR, -2, GETDATE()), 0),
(4, 4, 3, 'La mesa 6 tiene una alergia a mariscos, por favor verificar ingredientes', DATEADD(MINUTE, -10, GETDATE()), 1),
(5, 3, 4, 'Confirmado, preparando sin ingredientes marinos', DATEADD(MINUTE, -9, GETDATE()), 1),
(6, 2, 1, 'Mesa 9 solicita música más baja para celebración', DATEADD(MINUTE, -3, GETDATE()), 0);

SET IDENTITY_INSERT Mensajes OFF;
GO

-- Actualizar los totales de las órdenes (el trigger debería haberlo hecho, pero lo forzamos)
UPDATE o
SET Total = (
    SELECT SUM(po.Cantidad * po.PrecioUnitario)
    FROM ProductosOrden po
    WHERE po.IdOrden = o.IdOrden
)
FROM Ordenes o;
GO

PRINT '==============================================';
PRINT 'Datos iniciales cargados exitosamente';
PRINT '==============================================';
PRINT '';
PRINT 'Credenciales de acceso:';
PRINT '  Admin:   admin / admin123';
PRINT '  Mesero:  mesero1 / mesero123';
PRINT '  Cocina:  cocina1 / cocina123';
PRINT '';
PRINT 'Base de datos lista para usar!';
GO
