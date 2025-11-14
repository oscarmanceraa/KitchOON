-- =============================================
-- Script de creación de base de datos para SQL Server
-- Sistema de Gestión de Restaurante
-- =============================================

USE master;
GO

-- Eliminar base de datos si existe (solo para desarrollo/testing)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'restaurant_db')
BEGIN
    ALTER DATABASE restaurant_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE restaurant_db;
END
GO

-- Crear base de datos
CREATE DATABASE restaurant_db
COLLATE Modern_Spanish_CI_AS;
GO

USE restaurant_db;
GO

-- =============================================
-- TABLAS CATÁLOGO
-- =============================================

-- Tabla Estados
CREATE TABLE Estados (
    IdEstado INT IDENTITY(1,1) PRIMARY KEY,
    Estado NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(MAX),
    CONSTRAINT CK_Estados_Estado CHECK (LEN(Estado) > 0)
);
GO

-- Tabla TiposProducto
CREATE TABLE TiposProducto (
    IdTipoProducto INT IDENTITY(1,1) PRIMARY KEY,
    TipoProducto NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(MAX),
    CONSTRAINT CK_TiposProducto_Tipo CHECK (LEN(TipoProducto) > 0)
);
GO

-- Tabla TiposUsuario
CREATE TABLE TiposUsuario (
    IdTipoUsuario INT IDENTITY(1,1) PRIMARY KEY,
    TipoUsuario NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(MAX),
    CONSTRAINT CK_TiposUsuario_Tipo CHECK (LEN(TipoUsuario) > 0)
);
GO

-- =============================================
-- TABLAS PRINCIPALES
-- =============================================

-- Tabla Personas
CREATE TABLE Personas (
    IdPersona INT IDENTITY(1,1) PRIMARY KEY,
    PrimerNombre NVARCHAR(50) NOT NULL,
    SegundoNombre NVARCHAR(50),
    PrimerApellido NVARCHAR(50) NOT NULL,
    SegundoApellido NVARCHAR(50),
    FechaNacimiento DATE,
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    Direccion NVARCHAR(MAX),
    CONSTRAINT CK_Personas_Nombres CHECK (LEN(PrimerNombre) > 0 AND LEN(PrimerApellido) > 0),
    CONSTRAINT CK_Personas_Email CHECK (Email LIKE '%@%.%' OR Email IS NULL)
);
GO

-- Índices para Personas
CREATE INDEX IX_Personas_Email ON Personas(Email);
CREATE INDEX IX_Personas_Nombres ON Personas(PrimerNombre, PrimerApellido);
GO

-- Tabla Usuarios
CREATE TABLE Usuarios (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    IdPersona INT NOT NULL,
    IdTipoUsuario INT NOT NULL,
    IdEstado INT NOT NULL,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    UltimoAcceso DATETIME2,
    CONSTRAINT FK_Usuarios_Personas FOREIGN KEY (IdPersona) REFERENCES Personas(IdPersona),
    CONSTRAINT FK_Usuarios_TiposUsuario FOREIGN KEY (IdTipoUsuario) REFERENCES TiposUsuario(IdTipoUsuario),
    CONSTRAINT FK_Usuarios_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Usuarios_Username CHECK (LEN(Username) >= 3),
    CONSTRAINT CK_Usuarios_Password CHECK (LEN(Password) >= 6)
);
GO

-- Índices para Usuarios
CREATE INDEX IX_Usuarios_Username ON Usuarios(Username);
CREATE INDEX IX_Usuarios_Persona ON Usuarios(IdPersona);
CREATE INDEX IX_Usuarios_TipoUsuario ON Usuarios(IdTipoUsuario);
CREATE INDEX IX_Usuarios_Estado ON Usuarios(IdEstado);
GO

-- Tabla Productos
CREATE TABLE Productos (
    IdProducto INT IDENTITY(1,1) PRIMARY KEY,
    IdTipoProducto INT NOT NULL,
    IdEstado INT NOT NULL,
    NombreProducto NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(MAX),
    Precio DECIMAL(10,2) NOT NULL,
    TiempoPreparacion INT NOT NULL,
    CONSTRAINT FK_Productos_TiposProducto FOREIGN KEY (IdTipoProducto) REFERENCES TiposProducto(IdTipoProducto),
    CONSTRAINT FK_Productos_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Productos_Nombre CHECK (LEN(NombreProducto) > 0),
    CONSTRAINT CK_Productos_Precio CHECK (Precio >= 0),
    CONSTRAINT CK_Productos_Tiempo CHECK (TiempoPreparacion > 0)
);
GO

-- Índices para Productos
CREATE INDEX IX_Productos_TipoProducto ON Productos(IdTipoProducto);
CREATE INDEX IX_Productos_Estado ON Productos(IdEstado);
CREATE INDEX IX_Productos_Nombre ON Productos(NombreProducto);
GO

-- Tabla Mesas
CREATE TABLE Mesas (
    IdMesa INT IDENTITY(1,1) PRIMARY KEY,
    NumeroMesa INT NOT NULL UNIQUE,
    Capacidad INT NOT NULL,
    IdEstado INT NOT NULL,
    Ubicacion NVARCHAR(100),
    CONSTRAINT FK_Mesas_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Mesas_Numero CHECK (NumeroMesa > 0),
    CONSTRAINT CK_Mesas_Capacidad CHECK (Capacidad > 0)
);
GO

-- Índices para Mesas
CREATE INDEX IX_Mesas_NumeroMesa ON Mesas(NumeroMesa);
CREATE INDEX IX_Mesas_Estado ON Mesas(IdEstado);
GO

-- Tabla Ordenes
CREATE TABLE Ordenes (
    IdOrden INT IDENTITY(1,1) PRIMARY KEY,
    IdMesa INT NOT NULL,
    IdUsuario INT NOT NULL,
    IdEstado INT NOT NULL,
    FechaCreacion DATETIME2 DEFAULT GETDATE(),
    FechaActualizacion DATETIME2 DEFAULT GETDATE(),
    FechaInicioCocina DATETIME2 NULL,
    FechaFinalizacion DATETIME2 NULL,
    NumeroComensales INT DEFAULT 1,
    Observaciones NVARCHAR(MAX),
    Total DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT FK_Ordenes_Mesas FOREIGN KEY (IdMesa) REFERENCES Mesas(IdMesa),
    CONSTRAINT FK_Ordenes_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Ordenes_Estados FOREIGN KEY (IdEstado) REFERENCES Estados(IdEstado),
    CONSTRAINT CK_Ordenes_NumeroComensales CHECK (NumeroComensales > 0),
    CONSTRAINT CK_Ordenes_Total CHECK (Total >= 0)
);
GO

-- Índices para Ordenes
CREATE INDEX IX_Ordenes_Mesa ON Ordenes(IdMesa);
CREATE INDEX IX_Ordenes_Usuario ON Ordenes(IdUsuario);
CREATE INDEX IX_Ordenes_Estado ON Ordenes(IdEstado);
CREATE INDEX IX_Ordenes_FechaCreacion ON Ordenes(FechaCreacion DESC);
GO

-- Tabla ProductosOrden
CREATE TABLE ProductosOrden (
    IdProductoOrden INT IDENTITY(1,1) PRIMARY KEY,
    IdOrden INT NOT NULL,
    IdProducto INT NOT NULL,
    Cantidad INT DEFAULT 1,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Observaciones NVARCHAR(MAX),
    CONSTRAINT FK_ProductosOrden_Ordenes FOREIGN KEY (IdOrden) REFERENCES Ordenes(IdOrden) ON DELETE CASCADE,
    CONSTRAINT FK_ProductosOrden_Productos FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto),
    CONSTRAINT CK_ProductosOrden_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CK_ProductosOrden_Precio CHECK (PrecioUnitario >= 0)
);
GO

-- Índices para ProductosOrden
CREATE INDEX IX_ProductosOrden_Orden ON ProductosOrden(IdOrden);
CREATE INDEX IX_ProductosOrden_Producto ON ProductosOrden(IdProducto);
GO

-- Tabla Mensajes
CREATE TABLE Mensajes (
    IdMensaje INT IDENTITY(1,1) PRIMARY KEY,
    IdEmisor INT NOT NULL,
    IdReceptor INT NOT NULL,
    Mensaje NVARCHAR(MAX) NOT NULL,
    FechaEnvio DATETIME2 DEFAULT GETDATE(),
    Leido BIT DEFAULT 0,
    CONSTRAINT FK_Mensajes_Emisor FOREIGN KEY (IdEmisor) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Mensajes_Receptor FOREIGN KEY (IdReceptor) REFERENCES Usuarios(IdUsuario),
    CONSTRAINT CK_Mensajes_Mensaje CHECK (LEN(Mensaje) > 0)
);
GO

-- Índices para Mensajes
CREATE INDEX IX_Mensajes_Emisor ON Mensajes(IdEmisor);
CREATE INDEX IX_Mensajes_Receptor ON Mensajes(IdReceptor);
CREATE INDEX IX_Mensajes_FechaEnvio ON Mensajes(FechaEnvio);
CREATE INDEX IX_Mensajes_Leido ON Mensajes(Leido, IdReceptor);
GO

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger para actualizar FechaActualizacion en Ordenes
CREATE TRIGGER TR_Ordenes_ActualizarFecha
ON Ordenes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Ordenes
    SET FechaActualizacion = GETDATE()
    FROM Ordenes o
    INNER JOIN inserted i ON o.IdOrden = i.IdOrden;
END;
GO

-- Trigger para actualizar el Total de la Orden al insertar/actualizar ProductosOrden
CREATE TRIGGER TR_ProductosOrden_ActualizarTotal
ON ProductosOrden
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Actualizar totales de órdenes afectadas por INSERT/UPDATE
    UPDATE Ordenes
    SET Total = (
        SELECT ISNULL(SUM(Cantidad * PrecioUnitario), 0)
        FROM ProductosOrden
        WHERE IdOrden = Ordenes.IdOrden
    )
    WHERE IdOrden IN (SELECT DISTINCT IdOrden FROM inserted);
    
    -- Actualizar totales de órdenes afectadas por DELETE
    UPDATE Ordenes
    SET Total = (
        SELECT ISNULL(SUM(Cantidad * PrecioUnitario), 0)
        FROM ProductosOrden
        WHERE IdOrden = Ordenes.IdOrden
    )
    WHERE IdOrden IN (SELECT DISTINCT IdOrden FROM deleted);
END;
GO

-- =============================================
-- VISTAS
-- =============================================

-- Vista para Órdenes Completas
CREATE VIEW vw_OrdenesCompletas
AS
SELECT 
    o.IdOrden,
    o.NumeroComensales,
    o.Observaciones AS ObservacionesOrden,
    o.Total,
    o.FechaCreacion,
    o.FechaActualizacion,
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
GO

-- Vista para Productos con Información Completa
CREATE VIEW vw_ProductosCompletos
AS
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
GO

-- Vista para Usuarios con Información Completa
CREATE VIEW vw_UsuariosCompletos
AS
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
GO

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- Procedimiento para crear una orden completa con productos
CREATE PROCEDURE sp_CrearOrdenCompleta
    @IdMesa INT,
    @IdUsuario INT,
    @IdEstado INT,
    @NumeroComensales INT,
    @Observaciones NVARCHAR(MAX) = NULL,
    @Productos NVARCHAR(MAX) -- JSON con productos: [{"IdProducto":1,"Cantidad":2,"PrecioUnitario":100,"Observaciones":""}]
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Crear la orden
        DECLARE @IdOrden INT;
        INSERT INTO Ordenes (IdMesa, IdUsuario, IdEstado, NumeroComensales, Observaciones)
        VALUES (@IdMesa, @IdUsuario, @IdEstado, @NumeroComensales, @Observaciones);
        
        SET @IdOrden = SCOPE_IDENTITY();
        
        -- Insertar productos (requiere SQL Server 2016+)
        IF @Productos IS NOT NULL
        BEGIN
            INSERT INTO ProductosOrden (IdOrden, IdProducto, Cantidad, PrecioUnitario, Observaciones)
            SELECT 
                @IdOrden,
                JSON_VALUE(value, '$.IdProducto'),
                JSON_VALUE(value, '$.Cantidad'),
                JSON_VALUE(value, '$.PrecioUnitario'),
                JSON_VALUE(value, '$.Observaciones')
            FROM OPENJSON(@Productos);
        END
        
        COMMIT TRANSACTION;
        
        -- Retornar el ID de la orden creada
        SELECT @IdOrden AS IdOrden;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END;
GO

-- Procedimiento para obtener estadísticas del restaurante
CREATE PROCEDURE sp_ObtenerEstadisticas
    @FechaInicio DATETIME2 = NULL,
    @FechaFin DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Si no se especifican fechas, usar el día actual
    IF @FechaInicio IS NULL
        SET @FechaInicio = CAST(GETDATE() AS DATE);
    IF @FechaFin IS NULL
        SET @FechaFin = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));
    
    -- Estadísticas generales
    SELECT 
        COUNT(*) AS TotalOrdenes,
        COUNT(CASE WHEN e.Estado = 'Completada' THEN 1 END) AS OrdenesCompletadas,
        COUNT(CASE WHEN e.Estado = 'Cancelada' THEN 1 END) AS OrdenesCanceladas,
        COUNT(CASE WHEN e.Estado NOT IN ('Completada', 'Cancelada') THEN 1 END) AS OrdenesActivas,
        ISNULL(SUM(CASE WHEN e.Estado = 'Completada' THEN Total ELSE 0 END), 0) AS IngresosTotales,
        ISNULL(AVG(CASE WHEN e.Estado = 'Completada' THEN Total END), 0) AS PromedioOrden
    FROM Ordenes o
    INNER JOIN Estados e ON o.IdEstado = e.IdEstado
    WHERE o.FechaCreacion BETWEEN @FechaInicio AND @FechaFin;
    
    -- Top 5 productos más vendidos
    SELECT TOP 5
        pr.NombreProducto,
        SUM(po.Cantidad) AS TotalVendidos,
        SUM(po.Cantidad * po.PrecioUnitario) AS IngresosTotales
    FROM ProductosOrden po
    INNER JOIN Productos pr ON po.IdProducto = pr.IdProducto
    INNER JOIN Ordenes o ON po.IdOrden = o.IdOrden
    INNER JOIN Estados e ON o.IdEstado = e.IdEstado
    WHERE e.Estado = 'Completada'
        AND o.FechaCreacion BETWEEN @FechaInicio AND @FechaFin
    GROUP BY pr.IdProducto, pr.NombreProducto
    ORDER BY TotalVendidos DESC;
END;
GO

PRINT 'Base de datos restaurant_db creada exitosamente con todas las tablas, índices, triggers, vistas y procedimientos almacenados.';
GO