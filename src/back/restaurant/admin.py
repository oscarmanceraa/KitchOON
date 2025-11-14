from django.contrib import admin
from .models import (
    Estado, TipoProducto, TipoUsuario, Persona, Usuario,
    Producto, Mesa, Orden, ProductoOrden, Mensaje
)


@admin.register(Estado)
class EstadoAdmin(admin.ModelAdmin):
    list_display = ['IdEstado', 'Estado', 'Descripcion']
    search_fields = ['Estado']


@admin.register(TipoProducto)
class TipoProductoAdmin(admin.ModelAdmin):
    list_display = ['IdTipoProducto', 'TipoProducto', 'Descripcion']
    search_fields = ['TipoProducto']


@admin.register(TipoUsuario)
class TipoUsuarioAdmin(admin.ModelAdmin):
    list_display = ['IdTipoUsuario', 'TipoUsuario', 'Descripcion']
    search_fields = ['TipoUsuario']


@admin.register(Persona)
class PersonaAdmin(admin.ModelAdmin):
    list_display = ['IdPersona', 'get_nombre_completo', 'Email', 'Telefono']
    search_fields = ['PrimerNombre', 'PrimerApellido', 'Email']
    list_filter = ['FechaNacimiento']


@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = ['IdUsuario', 'Username', 'get_nombre', 'IdTipoUsuario', 'IdEstado', 'UltimoAcceso']
    search_fields = ['Username', 'IdPersona__PrimerNombre', 'IdPersona__PrimerApellido']
    list_filter = ['IdTipoUsuario', 'IdEstado', 'FechaCreacion']
    
    def get_nombre(self, obj):
        return obj.IdPersona.get_nombre_completo()
    get_nombre.short_description = 'Nombre Completo'


@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):
    list_display = ['IdProducto', 'NombreProducto', 'IdTipoProducto', 'Precio', 'TiempoPreparacion', 'IdEstado']
    search_fields = ['NombreProducto', 'Descripcion']
    list_filter = ['IdTipoProducto', 'IdEstado']


@admin.register(Mesa)
class MesaAdmin(admin.ModelAdmin):
    list_display = ['IdMesa', 'NumeroMesa', 'Capacidad', 'Ubicacion', 'IdEstado']
    search_fields = ['NumeroMesa', 'Ubicacion']
    list_filter = ['IdEstado', 'Capacidad']


class ProductoOrdenInline(admin.TabularInline):
    model = ProductoOrden
    extra = 1


@admin.register(Orden)
class OrdenAdmin(admin.ModelAdmin):
    list_display = ['IdOrden', 'IdMesa', 'IdUsuario', 'IdEstado', 'Total', 'NumeroComensales', 'FechaCreacion']
    search_fields = ['IdOrden', 'IdMesa__NumeroMesa']
    list_filter = ['IdEstado', 'FechaCreacion']
    inlines = [ProductoOrdenInline]


@admin.register(ProductoOrden)
class ProductoOrdenAdmin(admin.ModelAdmin):
    list_display = ['IdProductoOrden', 'IdOrden', 'IdProducto', 'Cantidad', 'PrecioUnitario']
    search_fields = ['IdOrden__IdOrden', 'IdProducto__NombreProducto']
    list_filter = ['IdOrden__FechaCreacion']


@admin.register(Mensaje)
class MensajeAdmin(admin.ModelAdmin):
    list_display = ['IdMensaje', 'IdEmisor', 'IdReceptor', 'Mensaje', 'FechaEnvio', 'Leido']
    search_fields = ['Mensaje', 'IdEmisor__Username', 'IdReceptor__Username']
    list_filter = ['Leido', 'FechaEnvio']
