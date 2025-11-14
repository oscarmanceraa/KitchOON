from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.utils import timezone


class Estado(models.Model):
    """Estados para usuarios, órdenes, productos, etc."""
    IdEstado = models.AutoField(primary_key=True)
    Estado = models.CharField(max_length=50, unique=True)
    Descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'Estados'
        verbose_name = 'Estado'
        verbose_name_plural = 'Estados'
    
    def __str__(self):
        return self.Estado


class TipoProducto(models.Model):
    """Tipos de productos (Comida, Bebida, Postre, etc.)"""
    IdTipoProducto = models.AutoField(primary_key=True)
    TipoProducto = models.CharField(max_length=50, unique=True)
    Descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'TiposProducto'
        verbose_name = 'Tipo de Producto'
        verbose_name_plural = 'Tipos de Producto'
    
    def __str__(self):
        return self.TipoProducto


class TipoUsuario(models.Model):
    """Tipos de usuarios (Administrador, Mesero, Cocina)"""
    IdTipoUsuario = models.AutoField(primary_key=True)
    TipoUsuario = models.CharField(max_length=50, unique=True)
    Descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'TiposUsuario'
        verbose_name = 'Tipo de Usuario'
        verbose_name_plural = 'Tipos de Usuario'
    
    def __str__(self):
        return self.TipoUsuario


class Persona(models.Model):
    """Información personal de los usuarios"""
    IdPersona = models.AutoField(primary_key=True)
    PrimerNombre = models.CharField(max_length=50)
    SegundoNombre = models.CharField(max_length=50, blank=True, null=True)
    PrimerApellido = models.CharField(max_length=50)
    SegundoApellido = models.CharField(max_length=50, blank=True, null=True)
    FechaNacimiento = models.DateField(blank=True, null=True)
    Telefono = models.CharField(max_length=20, blank=True, null=True)
    Email = models.EmailField(blank=True, null=True)
    Direccion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'Personas'
        verbose_name = 'Persona'
        verbose_name_plural = 'Personas'
    
    def __str__(self):
        return f"{self.PrimerNombre} {self.PrimerApellido}"
    
    def get_nombre_completo(self):
        nombres = [self.PrimerNombre]
        if self.SegundoNombre:
            nombres.append(self.SegundoNombre)
        apellidos = [self.PrimerApellido]
        if self.SegundoApellido:
            apellidos.append(self.SegundoApellido)
        return f"{' '.join(nombres)} {' '.join(apellidos)}"


class Usuario(models.Model):
    """Usuarios del sistema"""
    IdUsuario = models.AutoField(primary_key=True)
    IdPersona = models.ForeignKey(Persona, on_delete=models.CASCADE, db_column='IdPersona')
    IdTipoUsuario = models.ForeignKey(TipoUsuario, on_delete=models.PROTECT, db_column='IdTipoUsuario')
    IdEstado = models.ForeignKey(Estado, on_delete=models.PROTECT, db_column='IdEstado')
    Username = models.CharField(max_length=50, unique=True)
    Password = models.CharField(max_length=255)  # Usar hash en producción
    FechaCreacion = models.DateTimeField(default=timezone.now)
    UltimoAcceso = models.DateTimeField(blank=True, null=True)
    
    class Meta:
        db_table = 'Usuarios'
        verbose_name = 'Usuario'
        verbose_name_plural = 'Usuarios'
    
    def __str__(self):
        return self.Username


class Producto(models.Model):
    """Productos del menú"""
    IdProducto = models.AutoField(primary_key=True)
    IdTipoProducto = models.ForeignKey(TipoProducto, on_delete=models.PROTECT, db_column='IdTipoProducto')
    IdEstado = models.ForeignKey(Estado, on_delete=models.PROTECT, db_column='IdEstado')
    NombreProducto = models.CharField(max_length=100)
    Descripcion = models.TextField(blank=True, null=True)
    Precio = models.DecimalField(max_digits=10, decimal_places=2)
    TiempoPreparacion = models.IntegerField(help_text='Tiempo en minutos')
    
    class Meta:
        db_table = 'Productos'
        verbose_name = 'Producto'
        verbose_name_plural = 'Productos'
    
    def __str__(self):
        return self.NombreProducto


class Mesa(models.Model):
    """Mesas del restaurante"""
    IdMesa = models.AutoField(primary_key=True)
    NumeroMesa = models.IntegerField(unique=True)
    Capacidad = models.IntegerField()
    IdEstado = models.ForeignKey(Estado, on_delete=models.PROTECT, db_column='IdEstado')
    Ubicacion = models.CharField(max_length=100, blank=True, null=True)
    
    class Meta:
        db_table = 'Mesas'
        verbose_name = 'Mesa'
        verbose_name_plural = 'Mesas'
    
    def __str__(self):
        return f"Mesa {self.NumeroMesa}"


class Orden(models.Model):
    """Órdenes del restaurante"""
    IdOrden = models.AutoField(primary_key=True)
    IdMesa = models.ForeignKey(Mesa, on_delete=models.PROTECT, db_column='IdMesa')
    IdUsuario = models.ForeignKey(Usuario, on_delete=models.PROTECT, db_column='IdUsuario', related_name='ordenes_creadas')
    IdEstado = models.ForeignKey(Estado, on_delete=models.PROTECT, db_column='IdEstado')
    FechaCreacion = models.DateTimeField(default=timezone.now)
    FechaActualizacion = models.DateTimeField(auto_now=True)
    FechaInicioCocina = models.DateTimeField(blank=True, null=True, help_text='Cuando inicia preparación')
    FechaFinalizacion = models.DateTimeField(blank=True, null=True, help_text='Cuando se completa')
    NumeroComensales = models.IntegerField(default=1)
    Observaciones = models.TextField(blank=True, null=True)
    Total = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    class Meta:
        db_table = 'Ordenes'
        verbose_name = 'Orden'
        verbose_name_plural = 'Órdenes'
        ordering = ['-FechaCreacion']
    
    def __str__(self):
        return f"Orden #{self.IdOrden} - Mesa {self.IdMesa.NumeroMesa}"
    
    def calcular_total(self):
        """Calcula el total de la orden basado en los productos"""
        total = sum(
            po.Cantidad * po.PrecioUnitario 
            for po in self.productos_orden.all()
        )
        self.Total = total
        self.save()
        return total
    
    def tiempo_preparacion_estimado(self):
        """Calcula el tiempo estimado de preparación basado en los productos"""
        tiempos = [
            po.IdProducto.TiempoPreparacion * po.Cantidad 
            for po in self.productos_orden.all()
        ]
        # El tiempo total es el máximo (se preparan en paralelo)
        return max(tiempos) if tiempos else 0
    
    def tiempo_transcurrido(self):
        """Retorna el tiempo transcurrido desde la creación en minutos"""
        if self.FechaFinalizacion:
            delta = self.FechaFinalizacion - self.FechaCreacion
        else:
            delta = timezone.now() - self.FechaCreacion
        return int(delta.total_seconds() / 60)
    
    def tiempo_en_cocina(self):
        """Retorna el tiempo que estuvo/está en cocina en minutos"""
        if not self.FechaInicioCocina:
            return 0
        
        if self.FechaFinalizacion:
            delta = self.FechaFinalizacion - self.FechaInicioCocina
        else:
            delta = timezone.now() - self.FechaInicioCocina
        return int(delta.total_seconds() / 60)


class ProductoOrden(models.Model):
    """Productos incluidos en cada orden"""
    IdProductoOrden = models.AutoField(primary_key=True)
    IdOrden = models.ForeignKey(Orden, on_delete=models.CASCADE, db_column='IdOrden', related_name='productos_orden')
    IdProducto = models.ForeignKey(Producto, on_delete=models.PROTECT, db_column='IdProducto')
    Cantidad = models.IntegerField(default=1)
    PrecioUnitario = models.DecimalField(max_digits=10, decimal_places=2)
    Observaciones = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'ProductosOrden'
        verbose_name = 'Producto de Orden'
        verbose_name_plural = 'Productos de Orden'
    
    def __str__(self):
        return f"{self.IdProducto.NombreProducto} x{self.Cantidad}"
    
    def save(self, *args, **kwargs):
        # Si no se especifica precio, tomar el precio actual del producto
        if not self.PrecioUnitario:
            self.PrecioUnitario = self.IdProducto.Precio
        super().save(*args, **kwargs)
        # Actualizar total de la orden
        self.IdOrden.calcular_total()


class Mensaje(models.Model):
    """Mensajes entre usuarios del sistema"""
    IdMensaje = models.AutoField(primary_key=True)
    IdEmisor = models.ForeignKey(Usuario, on_delete=models.CASCADE, db_column='IdEmisor', related_name='mensajes_enviados')
    IdReceptor = models.ForeignKey(Usuario, on_delete=models.CASCADE, db_column='IdReceptor', related_name='mensajes_recibidos')
    Mensaje = models.TextField()
    FechaEnvio = models.DateTimeField(default=timezone.now)
    Leido = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'Mensajes'
        verbose_name = 'Mensaje'
        verbose_name_plural = 'Mensajes'
        ordering = ['FechaEnvio']
    
    def __str__(self):
        return f"De {self.IdEmisor.Username} a {self.IdReceptor.Username}"