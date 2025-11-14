from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from restaurant.models import (
    Estado, TipoProducto, TipoUsuario, Persona, Usuario,
    Producto, Mesa, Orden, ProductoOrden, Mensaje
)


class Command(BaseCommand):
    help = 'Poblar la base de datos con datos de prueba'

    def handle(self, *args, **kwargs):
        self.stdout.write('Iniciando población de datos...')

        # Limpiar datos existentes (opcional)
        # self.stdout.write('Limpiando datos existentes...')
        # Mensaje.objects.all().delete()
        # ProductoOrden.objects.all().delete()
        # Orden.objects.all().delete()
        # Mesa.objects.all().delete()
        # Producto.objects.all().delete()
        # Usuario.objects.all().delete()
        # Persona.objects.all().delete()
        # TipoUsuario.objects.all().delete()
        # TipoProducto.objects.all().delete()
        # Estado.objects.all().delete()

        # 1. Estados
        self.stdout.write('Creando Estados...')
        estados_data = [
            {'Estado': 'Activo', 'Descripcion': 'Elemento activo en el sistema'},
            {'Estado': 'Inactivo', 'Descripcion': 'Elemento inactivo'},
            {'Estado': 'Pendiente', 'Descripcion': 'Orden pendiente de procesar'},
            {'Estado': 'En Preparación', 'Descripcion': 'Orden siendo preparada'},
            {'Estado': 'Servida', 'Descripcion': 'Orden servida al cliente'},
            {'Estado': 'Completada', 'Descripcion': 'Orden completada y pagada'},
            {'Estado': 'Cancelada', 'Descripcion': 'Orden cancelada'},
            {'Estado': 'Disponible', 'Descripcion': 'Mesa disponible'},
            {'Estado': 'Ocupada', 'Descripcion': 'Mesa ocupada'},
        ]
        estados = {}
        for data in estados_data:
            estado, created = Estado.objects.get_or_create(**data)
            estados[data['Estado']] = estado
            if created:
                self.stdout.write(f'  ✓ {data["Estado"]}')

        # 2. Tipos de Producto
        self.stdout.write('Creando Tipos de Producto...')
        tipos_producto_data = [
            {'TipoProducto': 'Comida', 'Descripcion': 'Platos principales'},
            {'TipoProducto': 'Bebida', 'Descripcion': 'Bebidas frías y calientes'},
            {'TipoProducto': 'Postre', 'Descripcion': 'Postres y dulces'},
            {'TipoProducto': 'Entrada', 'Descripcion': 'Entradas y aperitivos'},
        ]
        tipos_producto = {}
        for data in tipos_producto_data:
            tipo, created = TipoProducto.objects.get_or_create(**data)
            tipos_producto[data['TipoProducto']] = tipo
            if created:
                self.stdout.write(f'  ✓ {data["TipoProducto"]}')

        # 3. Tipos de Usuario
        self.stdout.write('Creando Tipos de Usuario...')
        tipos_usuario_data = [
            {'TipoUsuario': 'Administrador', 'Descripcion': 'Usuario con acceso completo'},
            {'TipoUsuario': 'Mesero', 'Descripcion': 'Personal de atención al cliente'},
            {'TipoUsuario': 'Cocina', 'Descripcion': 'Personal de cocina'},
        ]
        tipos_usuario = {}
        for data in tipos_usuario_data:
            tipo, created = TipoUsuario.objects.get_or_create(**data)
            tipos_usuario[data['TipoUsuario']] = tipo
            if created:
                self.stdout.write(f'  ✓ {data["TipoUsuario"]}')

        # 4. Personas
        self.stdout.write('Creando Personas...')
        personas_data = [
            {
                'PrimerNombre': 'Juan',
                'PrimerApellido': 'Pérez',
                'Email': 'admin@restaurant.com',
                'Telefono': '555-0001'
            },
            {
                'PrimerNombre': 'María',
                'PrimerApellido': 'García',
                'Email': 'maria@restaurant.com',
                'Telefono': '555-0002'
            },
            {
                'PrimerNombre': 'Carlos',
                'PrimerApellido': 'López',
                'Email': 'carlos@restaurant.com',
                'Telefono': '555-0003'
            },
            {
                'PrimerNombre': 'Ana',
                'PrimerApellido': 'Martínez',
                'Email': 'ana@restaurant.com',
                'Telefono': '555-0004'
            },
        ]
        personas = []
        for data in personas_data:
            persona, created = Persona.objects.get_or_create(**data)
            personas.append(persona)
            if created:
                self.stdout.write(f'  ✓ {persona.get_nombre_completo()}')

        # 5. Usuarios
        self.stdout.write('Creando Usuarios...')
        usuarios_data = [
            {
                'IdPersona': personas[0],
                'IdTipoUsuario': tipos_usuario['Administrador'],
                'IdEstado': estados['Activo'],
                'Username': 'admin',
                'Password': 'admin123'
            },
            {
                'IdPersona': personas[1],
                'IdTipoUsuario': tipos_usuario['Mesero'],
                'IdEstado': estados['Activo'],
                'Username': 'mesero1',
                'Password': 'mesero123'
            },
            {
                'IdPersona': personas[2],
                'IdTipoUsuario': tipos_usuario['Cocina'],
                'IdEstado': estados['Activo'],
                'Username': 'cocina1',
                'Password': 'cocina123'
            },
            {
                'IdPersona': personas[3],
                'IdTipoUsuario': tipos_usuario['Mesero'],
                'IdEstado': estados['Activo'],
                'Username': 'mesero2',
                'Password': 'mesero123'
            },
        ]
        usuarios = []
        for data in usuarios_data:
            usuario, created = Usuario.objects.get_or_create(
                Username=data['Username'],
                defaults=data
            )
            usuarios.append(usuario)
            if created:
                self.stdout.write(f'  ✓ {usuario.Username}')

        # 6. Productos
        self.stdout.write('Creando Productos...')
        productos_data = [
            {
                'NombreProducto': 'Hamburguesa Clásica',
                'IdTipoProducto': tipos_producto['Comida'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Hamburguesa de carne con queso, lechuga y tomate',
                'Precio': 120.00,
                'TiempoPreparacion': 15
            },
            {
                'NombreProducto': 'Pizza Margarita',
                'IdTipoProducto': tipos_producto['Comida'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Pizza con salsa de tomate, mozzarella y albahaca',
                'Precio': 180.00,
                'TiempoPreparacion': 20
            },
            {
                'NombreProducto': 'Ensalada César',
                'IdTipoProducto': tipos_producto['Entrada'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Lechuga romana, crutones y aderezo césar',
                'Precio': 85.00,
                'TiempoPreparacion': 10
            },
            {
                'NombreProducto': 'Refresco',
                'IdTipoProducto': tipos_producto['Bebida'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Refresco de 355ml',
                'Precio': 30.00,
                'TiempoPreparacion': 2
            },
            {
                'NombreProducto': 'Agua Natural',
                'IdTipoProducto': tipos_producto['Bebida'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Agua embotellada',
                'Precio': 20.00,
                'TiempoPreparacion': 1
            },
            {
                'NombreProducto': 'Pastel de Chocolate',
                'IdTipoProducto': tipos_producto['Postre'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Delicioso pastel de chocolate',
                'Precio': 65.00,
                'TiempoPreparacion': 5
            },
            {
                'NombreProducto': 'Tacos de Bistec',
                'IdTipoProducto': tipos_producto['Comida'],
                'IdEstado': estados['Activo'],
                'Descripcion': 'Orden de 3 tacos de bistec',
                'Precio': 95.00,
                'TiempoPreparacion': 12
            },
        ]
        productos = []
        for data in productos_data:
            producto, created = Producto.objects.get_or_create(
                NombreProducto=data['NombreProducto'],
                defaults=data
            )
            productos.append(producto)
            if created:
                self.stdout.write(f'  ✓ {producto.NombreProducto}')

        # 7. Mesas
        self.stdout.write('Creando Mesas...')
        for i in range(1, 11):
            mesa, created = Mesa.objects.get_or_create(
                NumeroMesa=i,
                defaults={
                    'Capacidad': 4 if i <= 6 else 6,
                    'IdEstado': estados['Disponible'] if i % 3 != 0 else estados['Ocupada'],
                    'Ubicacion': 'Interior' if i <= 5 else 'Terraza'
                }
            )
            if created:
                self.stdout.write(f'  ✓ Mesa {i}')

        # 8. Órdenes de ejemplo
        self.stdout.write('Creando Órdenes...')
        mesas = Mesa.objects.all()
        
        # Orden 1
        orden1, created = Orden.objects.get_or_create(
            IdMesa=mesas[0],
            IdUsuario=usuarios[1],  # mesero1
            IdEstado=estados['En Preparación'],
            NumeroComensales=2,
            defaults={'FechaCreacion': timezone.now() - timedelta(minutes=30)}
        )
        if created:
            ProductoOrden.objects.create(
                IdOrden=orden1,
                IdProducto=productos[0],  # Hamburguesa
                Cantidad=2,
                PrecioUnitario=productos[0].Precio
            )
            ProductoOrden.objects.create(
                IdOrden=orden1,
                IdProducto=productos[3],  # Refresco
                Cantidad=2,
                PrecioUnitario=productos[3].Precio
            )
            self.stdout.write(f'  ✓ Orden #{orden1.IdOrden}')

        # Orden 2
        orden2, created = Orden.objects.get_or_create(
            IdMesa=mesas[1],
            IdUsuario=usuarios[3],  # mesero2
            IdEstado=estados['Pendiente'],
            NumeroComensales=4,
            defaults={'FechaCreacion': timezone.now() - timedelta(minutes=10)}
        )
        if created:
            ProductoOrden.objects.create(
                IdOrden=orden2,
                IdProducto=productos[1],  # Pizza
                Cantidad=1,
                PrecioUnitario=productos[1].Precio
            )
            ProductoOrden.objects.create(
                IdOrden=orden2,
                IdProducto=productos[2],  # Ensalada
                Cantidad=2,
                PrecioUnitario=productos[2].Precio
            )
            ProductoOrden.objects.create(
                IdOrden=orden2,
                IdProducto=productos[4],  # Agua
                Cantidad=4,
                PrecioUnitario=productos[4].Precio
            )
            self.stdout.write(f'  ✓ Orden #{orden2.IdOrden}')

        # 9. Mensajes de ejemplo
        self.stdout.write('Creando Mensajes...')
        mensajes_data = [
            {
                'IdEmisor': usuarios[1],  # mesero1
                'IdReceptor': usuarios[2],  # cocina1
                'Mensaje': 'La mesa 3 pregunta si pueden agregar extra de queso',
                'FechaEnvio': timezone.now() - timedelta(minutes=15),
                'Leido': True
            },
            {
                'IdEmisor': usuarios[2],  # cocina1
                'IdReceptor': usuarios[1],  # mesero1
                'Mensaje': 'Sí, sin problema. Ya está agregado.',
                'FechaEnvio': timezone.now() - timedelta(minutes=14),
                'Leido': True
            },
            {
                'IdEmisor': usuarios[0],  # admin
                'IdReceptor': usuarios[1],  # mesero1
                'Mensaje': 'Recuerda actualizar el inventario al final del turno',
                'FechaEnvio': timezone.now() - timedelta(hours=2),
                'Leido': False
            },
        ]
        
        for data in mensajes_data:
            mensaje, created = Mensaje.objects.get_or_create(**data)
            if created:
                self.stdout.write(f'  ✓ Mensaje de {mensaje.IdEmisor.Username} a {mensaje.IdReceptor.Username}')

        self.stdout.write(self.style.SUCCESS('\n¡Datos poblados exitosamente!'))
        self.stdout.write(self.style.SUCCESS('\nCredenciales de acceso:'))
        self.stdout.write('  Admin: admin / admin123')
        self.stdout.write('  Mesero: mesero1 / mesero123')
        self.stdout.write('  Cocina: cocina1 / cocina123')
