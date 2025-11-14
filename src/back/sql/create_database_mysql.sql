-- =============================================
-- Script de creación de base de datos para MySQL
-- Sistema kitchON - Gestión de Restaurante
-- =============================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS restaurant_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE restaurant_db;

-- =============================================
-- TABLAS CATÁLOGO
-- =============================================

-- Tabla Estados
DROP TABLE IF EXISTS Estados;
CREATE TABLE Estados (
    IdEstado INT AUTO_INCREMENT PRIMARY KEY,
    Estado VARCHAR(50) NOT NULL UNIQUE,
    Descripcion TEXT,
    CONSTRAINT CK_Estados_Estado CHECK (CHAR_LENGTH(Estado) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla TiposProducto
DROP TABLE IF EXISTS TiposProducto;
CREATE TABLE TiposProducto (
    IdTipoProducto INT AUTO_INCREMENT PRIMARY KEY,
    TipoProducto VARCHAR(50) NOT NULL UNIQUE,
    Descripcion TEXT,
    CONSTRAINT CK_TiposProducto_Tipo CHECK (CHAR_LENGTH(TipoProducto) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla TiposUsuario
DROP TABLE IF EXISTS TiposUsuario;
CREATE TABLE TiposUsuario (
    IdTipoUsuario INT AUTO_INCREMENT PRIMARY KEY,
    TipoUsuario VARCHAR(50) NOT NULL UNIQUE,
    Descripcion TEXT,
    CONSTRAINT CK_TiposUsuario_Tipo CHECK (CHAR_LENGTH(TipoUsuario) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- TABLAS PRINCIPALES
-- =============================================

-- Tabla Personas
DROP TABLE IF EXISTS Personas;
CREATE TABLE Personas (
    IdPersona INT AUTO_INCREMENT PRIMARY KEY,
    PrimerNombre VARCHAR(50) NOT NULL,
    SegundoNombre VARCHAR(50),
    PrimerApellido VARCHAR(50) NOT NULL,
    SegundoApellido VARCHAR(50),
    FechaNacimiento DATE,
    Telefono VARCHAR(20),
    Email VARCHAR(100),
    Direccion TEXT,
    CONSTRAINT CK_Personas_Nombres CHECK (CHAR_LENGTH(PrimerNombre) > 0 AND CHAR_LENGTH(PrimerApellido) > 0),
    CONSTRAINT CK_Personas_Email CHECK (Email LIKE '%@%.%' OR Email IS NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para Personas
CREATE INDEX IX_Personas_Email ON Personas(Email);
CREATE INDEX IX_Personas_Nombres ON Personas(PrimerNombre, PrimerApellido);

-- Tabla Usuarios
DROP TABLE IF EXISTS Usuarios;
CREATE TABLE Usuarios (
    IdUsuario INT AUTO_INCREMENT PRIMARY KEY,
    IdPersona INT NOT NULL,
    IdTipoUsuario INT NOT NULL,
    IdEstado INT NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    FechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    UltimoAcceso DATETIME,
    CONSTRAINT FK_Usuarios_Personas FOREIGN KEY (IdPersona) REFERENCES Personas(IdPersona) ON DELETE CASCADE,
    CONSTRAINT FK_Usuarios_TiposUsuario FOREIGN KEY (IdTipoUsuario) REFERENCES TiposUsuario(IdTipoUsuario),
    CONSTRAINT FK_Usuarios_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Usuarios_Username CHECK (CHAR_LENGTH(Username) >= 3),
    CONSTRAINT CK_Usuarios_Password CHECK (CHAR_LENGTH(Password) >= 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para Usuarios
CREATE INDEX IX_Usuarios_Username ON Usuarios(Username);
CREATE INDEX IX_Usuarios_Persona ON Usuarios(IdPersona);
CREATE INDEX IX_Usuarios_TipoUsuario ON Usuarios(IdTipoUsuario);
CREATE INDEX IX_Usuarios_Estado ON Usuarios(IdEstado);

-- Tabla Productos
DROP TABLE IF EXISTS Productos;
CREATE TABLE Productos (
    IdProducto INT AUTO_INCREMENT PRIMARY KEY,
    IdTipoProducto INT NOT NULL,
    IdEstado INT NOT NULL,
    NombreProducto VARCHAR(100) NOT NULL,
    Descripcion TEXT,
    Precio DECIMAL(10,2) NOT NULL,
    TiempoPreparacion INT NOT NULL,
    CONSTRAINT FK_Productos_TiposProducto FOREIGN KEY (IdTipoProducto) REFERENCES TiposProducto(IdTipoProducto),
    CONSTRAINT FK_Productos_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Productos_Nombre CHECK (CHAR_LENGTH(NombreProducto) > 0),
    CONSTRAINT CK_Productos_Precio CHECK (Precio >= 0),
    CONSTRAINT CK_Productos_Tiempo CHECK (TiempoPreparacion > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para Productos
CREATE INDEX IX_Productos_TipoProducto ON Productos(IdTipoProducto);
CREATE INDEX IX_Productos_Estado ON Productos(IdEstado);
CREATE INDEX IX_Productos_Nombre ON Productos(NombreProducto);

-- Tabla Mesas
DROP TABLE IF EXISTS Mesas;
CREATE TABLE Mesas (
    IdMesa INT AUTO_INCREMENT PRIMARY KEY,
    NumeroMesa INT NOT NULL UNIQUE,
    Capacidad INT NOT NULL,
    IdEstado INT NOT NULL,
    Ubicacion VARCHAR(100),
    CONSTRAINT FK_Mesas_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Mesas_Numero CHECK (NumeroMesa > 0),
    CONSTRAINT CK_Mesas_Capacidad CHECK (Capacidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para Mesas
CREATE INDEX IX_Mesas_NumeroMesa ON Mesas(NumeroMesa);
CREATE INDEX IX_Mesas_Estado ON Mesas(IdEstado);

-- Tabla Ordenes
DROP TABLE IF EXISTS Ordenes;
CREATE TABLE Ordenes (
    IdOrden INT AUTO_INCREMENT PRIMARY KEY,
    IdMesa INT NOT NULL,
    IdUsuario INT NOT NULL,
    IdEstado INT NOT NULL,
    FechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FechaActualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FechaInicioCocina DATETIME NULL,
    FechaFinalizacion DATETIME NULL,
    NumeroComensales INT DEFAULT 1,
    Observaciones TEXT,
    Total DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT FK_Ordenes_Mesas FOREIGN KEY (IdMesa) REFERENCES Mesas(IdMesa),
    CONSTRAINT FK_Ordenes_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Ordenes_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Ordenes_NumeroComensales CHECK (NumeroComensales > 0),
    CONSTRAINT CK_Ordenes_Total CHECK (Total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para Ordenes
CREATE INDEX IX_Ordenes_Mesa ON Ordenes(IdMesa);
CREATE INDEX IX_Ordenes_Usuario ON Ordenes(IdUsuario);
CREATE INDEX IX_Ordenes_Estado ON Ordenes(IdEstado);
CREATE INDEX IX_Ordenes_FechaCreacion ON Ordenes(FechaCreacion DESC);

-- Tabla ProductosOrden
DROP TABLE IF EXISTS ProductosOrden;
CREATE TABLE ProductosOrden (
    IdProductoOrden INT AUTO_INCREMENT PRIMARY KEY,
    IdOrden INT NOT NULL,
    IdProducto INT NOT NULL,
    Cantidad INT DEFAULT 1,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Observaciones TEXT,
    CONSTRAINT FK_ProductosOrden_Ordenes FOREIGN KEY (IdOrden) REFERENCES Ordenes(IdOrden) ON DELETE CASCADE,
    CONSTRAINT FK_ProductosOrden_Productos FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto),
    CONSTRAINT CK_ProductosOrden_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_ProductosOrden_Precio CHECK (PrecioUnitario >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para ProductosOrden
CREATE INDEX IX_ProductosOrden_Orden ON ProductosOrden(IdOrden);
CREATE INDEX IX_ProductosOrden_Producto ON ProductosOrden(IdProducto);

-- Tabla Mensajes
DROP TABLE IF EXISTS Mensajes;
CREATE TABLE Mensajes (
    IdMensaje INT AUTO_INCREMENT PRIMARY KEY,
    IdEmisor INT NOT NULL,
    IdReceptor INT NOT NULL,
    Mensaje TEXT NOT NULL,
    FechaEnvio DATETIME DEFAULT CURRENT_TIMESTAMP,
    Leido BOOLEAN DEFAULT FALSE,
    CONSTRAINT FK_Mensajes_Emisor FOREIGN KEY (IdEmisor) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Mensajes_Receptor FOREIGN KEY (IdReceptor) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT CK_Mensajes_Mensaje CHECK (CHAR_LENGTH(Mensaje) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para Mensajes
CREATE INDEX IX_Mensajes_Emisor ON Mensajes(IdEmisor);
CREATE INDEX IX_Mensajes_Receptor ON Mensajes(IdReceptor);
CREATE INDEX IX_Mensajes_FechaEnvio ON Mensajes(FechaEnvio);
CREATE INDEX IX_Mensajes_Leido ON Mensajes(Leido, IdReceptor);

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger para actualizar el Total de la Orden al insertar ProductosOrden
DELIMITER //
DROP TRIGGER IF EXISTS TR_ProductosOrden_Insert_ActualizarTotal//
CREATE TRIGGER TR_ProductosOrden_Insert_ActualizarTotal
AFTER INSERT ON ProductosOrden
FOR EACH ROW
BEGIN
    UPDATE Ordenes
    SET Total = (
        SELECT IFNULL(SUM(Cantidad * PrecioUnitario), 0)
        FROM ProductosOrden
        WHERE IdOrden = NEW.IdOrden
    )
    WHERE IdOrden = NEW.IdOrden;
END//
DELIMITER ;

-- Trigger para actualizar el Total de la Orden al actualizar ProductosOrden
DELIMITER //
DROP TRIGGER IF EXISTS TR_ProductosOrden_Update_ActualizarTotal//
CREATE TRIGGER TR_ProductosOrden_Update_ActualizarTotal
AFTER UPDATE ON ProductosOrden
FOR EACH ROW
BEGIN
    UPDATE Ordenes
    SET Total = (
        SELECT IFNULL(SUM(Cantidad * PrecioUnitario), 0)
        FROM ProductosOrden
        WHERE IdOrden = NEW.IdOrden
    )
    WHERE IdOrden = NEW.IdOrden;
END//
DELIMITER ;

-- Trigger para actualizar el Total de la Orden al eliminar ProductosOrden
DELIMITER //
DROP TRIGGER IF EXISTS TR_ProductosOrden_Delete_ActualizarTotal//
CREATE TRIGGER TR_ProductosOrden_Delete_ActualizarTotal
AFTER DELETE ON ProductosOrden
FOR EACH ROW
BEGIN
    UPDATE Ordenes
    SET Total = (
        SELECT IFNULL(SUM(Cantidad * PrecioUnitario), 0)
        FROM ProductosOrden
        WHERE IdOrden = OLD.IdOrden
    )
    WHERE IdOrden = OLD.IdOrden;
END//
DELIMITER ;

-- =============================================
-- VISTAS
-- =============================================

-- Vista para Órdenes Completas
DROP VIEW IF EXISTS vw_OrdenesCompletas;
CREATE VIEW vw_OrdenesCompletas AS
SELECT 
    o.IdOrden,
    o.NumeroComensales,
    o.Observaciones AS ObservacionesOrden,
    o.Total,
    o.FechaCreacion,
    o.FechaActualizacion,
    o.FechaInicioCocina,
    o.FechaFinalizacion,
    m.NumeroMesa,
    m.Capacidad AS CapacidadMesa,
    m.Ubicacion AS UbicacionMesa,
    u.Username,
    p.PrimerNombre,
    p.PrimerApellido,
    CONCAT(p.PrimerNombre, ' ', p.PrimerApellido) AS NombreCompleto,
    tu.TipoUsuario,
    e.Estado AS EstadoOrden,
    (
        SELECT COUNT(*) 
        FROM ProductosOrden po 
        WHERE po.IdOrden = o.IdOrden
    ) AS TotalProductos
FROM Ordenes o
INNER JOIN Mesas m ON o.IdMesa = m.IdMesa
INNER JOIN Usuarios u ON o.IdUsuario = u.IdUsuario
INNER JOIN Personas p ON u.IdPersona = p.IdPersona
INNER JOIN TiposUsuario tu ON u.IdTipoUsuario = tu.IdTipoUsuario
INNER JOIN Estados e ON o.IdEstado = e.IdEstado;

-- Vista para Productos con Información Completa
DROP VIEW IF EXISTS vw_ProductosCompletos;
CREATE VIEW vw_ProductosCompletos AS
SELECT 
    pr.IdProducto,
    pr.NombreProducto,
    pr.Descripcion,
    pr.Precio,
    pr.TiempoPreparacion,
    tp.TipoProducto,
    e.Estado AS EstadoProducto
FROM Productos pr
INNER JOIN TiposProducto tp ON pr.IdTipoProducto = tp.IdTipoProducto
INNER JOIN Estados e ON pr.IdEstado = e.IdEstado;

-- Vista para Usuarios con Información Completa
DROP VIEW IF EXISTS vw_UsuariosCompletos;
CREATE VIEW vw_UsuariosCompletos AS
SELECT 
    u.IdUsuario,
    u.Username,
    u.FechaCreacion,
    u.UltimoAcceso,
    p.PrimerNombre,
    p.SegundoNombre,
    p.PrimerApellido,
    p.SegundoApellido,
    CONCAT(p.PrimerNombre, ' ', p.PrimerApellido) AS NombreCompleto,
    p.Email,
    p.Telefono,
    tu.TipoUsuario,
    e.Estado AS EstadoUsuario
FROM Usuarios u
INNER JOIN Personas p ON u.IdPersona = p.IdPersona
INNER JOIN TiposUsuario tu ON u.IdTipoUsuario = tu.IdTipoUsuario
INNER JOIN Estados e ON u.IdEstado = e.IdEstado;

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- Procedimiento para crear una orden completa con productos
DELIMITER //
DROP PROCEDURE IF EXISTS sp_CrearOrdenCompleta//
CREATE PROCEDURE sp_CrearOrdenCompleta(
    IN p_IdMesa INT,
    IN p_IdUsuario INT,
    IN p_IdEstado INT,
    IN p_NumeroComensales INT,
    IN p_Observaciones TEXT
)
BEGIN
    DECLARE v_IdOrden INT;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Crear la orden
    INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, NumeroComensales, Observaciones)
    VALUES (p_IdMesa, p_IdUsuario, p_IdEstado, p_NumeroComensales, p_Observaciones);
    
    -- Obtener el ID de la orden creada
    SET v_IdOrden = LAST_INSERT_ID();
    
    -- Confirmar transacción
    COMMIT;
    
    -- Retornar el ID de la orden creada
    SELECT v_IdOrden AS IdOrden;
END//
DELIMITER ;

-- Procedimiento para obtener estadísticas del restaurante
DELIMITER //
DROP PROCEDURE IF EXISTS sp_ObtenerEstadisticas//
CREATE PROCEDURE sp_ObtenerEstadisticas(
    IN p_FechaInicio DATETIME,
    IN p_FechaFin DATETIME
)
BEGIN
    DECLARE v_FechaInicio DATETIME;
    DECLARE v_FechaFin DATETIME;
    
    -- Si no se especifican fechas, usar el día actual
    SET v_FechaInicio = IFNULL(p_FechaInicio, CURDATE());
    SET v_FechaFin = IFNULL(p_FechaFin, DATE_ADD(CURDATE(), INTERVAL 1 DAY));
    
    -- Estadísticas generales
    SELECT 
        COUNT(*) AS TotalOrdenes,
        COUNT(CASE WHEN e.Estado = 'Completada' THEN 1 END) AS OrdenesCompletadas,
        COUNT(CASE WHEN e.Estado = 'Cancelada' THEN 1 END) AS OrdenesCanceladas,
        COUNT(CASE WHEN e.Estado NOT IN ('Completada', 'Cancelada') THEN 1 END) AS OrdenesActivas,
        IFNULL(SUM(CASE WHEN e.Estado = 'Completada' THEN Total ELSE 0 END), 0) AS IngresosTotales,
        IFNULL(AVG(CASE WHEN e.Estado = 'Completada' THEN Total END), 0) AS PromedioOrden
    FROM Ordenes o
    INNER JOIN Estados e ON o.IdEstado = e.IdEstado
    WHERE o.FechaCreacion BETWEEN v_FechaInicio AND v_FechaFin;
    
    -- Top 5 productos más vendidos
    SELECT 
        pr.NombreProducto,
        SUM(po.Cantidad) AS TotalVendidos,
        SUM(po.Cantidad * po.PrecioUnitario) AS IngresosTotales
    FROM ProductosOrden po
    INNER JOIN Productos pr ON po.IdProducto = pr.IdProducto
    INNER JOIN Ordenes o ON po.IdOrden = o.IdOrden
    INNER JOIN Estados e ON o.IdEstado = e.IdEstado
    WHERE e.Estado = 'Completada'
        AND o.FechaCreacion BETWEEN v_FechaInicio AND v_FechaFin
    GROUP BY pr.IdProducto, pr.NombreProducto
    ORDER BY TotalVendidos DESC
    LIMIT 5;
END//
DELIMITER ;

SELECT 'Base de datos restaurant_db creada exitosamente para kitchON con todas las tablas, índices, triggers, vistas y procedimientos almacenados.' AS Mensaje;
