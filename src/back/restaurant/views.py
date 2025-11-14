from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.db.models import Q, Count, Sum, Avg
from django.utils import timezone
from datetime import timedelta

from .models import (
    Estado, TipoProducto, TipoUsuario, Persona, Usuario,
    Producto, Mesa, Orden, ProductoOrden, Mensaje
)
from .serializers import (
    EstadoSerializer, TipoProductoSerializer, TipoUsuarioSerializer,
    PersonaSerializer, UsuarioSerializer, UsuarioSimpleSerializer,
    ProductoSerializer, MesaSerializer, OrdenSerializer,
    ProductoOrdenSerializer, MensajeSerializer, LoginSerializer,
    OrdenCreateSerializer
)


class EstadoViewSet(viewsets.ModelViewSet):
    queryset = Estado.objects.all()
    serializer_class = EstadoSerializer


class TipoProductoViewSet(viewsets.ModelViewSet):
    queryset = TipoProducto.objects.all()
    serializer_class = TipoProductoSerializer


class TipoUsuarioViewSet(viewsets.ModelViewSet):
    queryset = TipoUsuario.objects.all()
    serializer_class = TipoUsuarioSerializer


class PersonaViewSet(viewsets.ModelViewSet):
    queryset = Persona.objects.all()
    serializer_class = PersonaSerializer


class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.select_related('IdPersona', 'IdTipoUsuario', 'IdEstado').all()
    
    def get_serializer_class(self):
        if self.action == 'list':
            return UsuarioSimpleSerializer
        return UsuarioSerializer
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        """Endpoint de login"""
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            username = serializer.validated_data['username']
            password = serializer.validated_data['password']
            
            try:
                # En producción, usar autenticación con hash
                usuario = Usuario.objects.select_related(
                    'IdPersona', 'IdTipoUsuario', 'IdEstado'
                ).get(Username=username, Password=password)
                
                # Verificar que el usuario esté activo
                if usuario.IdEstado.Estado != 'Activo':
                    return Response(
                        {'error': 'Usuario inactivo'},
                        status=status.HTTP_403_FORBIDDEN
                    )
                
                # Actualizar último acceso
                usuario.UltimoAcceso = timezone.now()
                usuario.save()
                
                # Retornar datos del usuario
                user_serializer = UsuarioSerializer(usuario)
                return Response({
                    'user': user_serializer.data,
                    'message': 'Login exitoso'
                })
                
            except Usuario.DoesNotExist:
                return Response(
                    {'error': 'Credenciales inválidas'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'])
    def activos(self, request):
        """Obtener solo usuarios activos"""
        usuarios = self.queryset.filter(IdEstado__Estado='Activo')
        serializer = self.get_serializer(usuarios, many=True)
        return Response(serializer.data)


class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.select_related('IdTipoProducto', 'IdEstado').all()
    serializer_class = ProductoSerializer
    
    @action(detail=False, methods=['get'])
    def disponibles(self, request):
        """Obtener solo productos disponibles"""
        productos = self.queryset.filter(IdEstado__Estado='Activo')
        serializer = self.get_serializer(productos, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def por_tipo(self, request):
        """Agrupar productos por tipo"""
        tipo_id = request.query_params.get('tipo')
        if tipo_id:
            productos = self.queryset.filter(IdTipoProducto_id=tipo_id)
        else:
            productos = self.queryset.all()
        
        serializer = self.get_serializer(productos, many=True)
        return Response(serializer.data)


class MesaViewSet(viewsets.ModelViewSet):
    queryset = Mesa.objects.select_related('IdEstado').all()
    serializer_class = MesaSerializer
    
    @action(detail=False, methods=['get'])
    def disponibles(self, request):
        """Obtener solo mesas disponibles"""
        mesas = self.queryset.filter(IdEstado__Estado='Disponible')
        serializer = self.get_serializer(mesas, many=True)
        return Response(serializer.data)


class OrdenViewSet(viewsets.ModelViewSet):
    queryset = Orden.objects.select_related(
        'IdMesa', 'IdUsuario', 'IdEstado'
    ).prefetch_related(
        'productos_orden__IdProducto'
    ).all()
    
    def get_serializer_class(self):
        if self.action == 'create':
            return OrdenCreateSerializer
        return OrdenSerializer
    
    def create(self, request, *args, **kwargs):
        """Crear orden con productos"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        orden = serializer.save()
        
        # Retornar la orden completa con relaciones
        orden_serializer = OrdenSerializer(orden)
        return Response(orden_serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['patch'])
    def actualizar_estado(self, request, pk=None):
        """Actualizar solo el estado de una orden"""
        orden = self.get_object()
        nuevo_estado_id = request.data.get('IdEstado')
        
        if not nuevo_estado_id:
            return Response(
                {'error': 'IdEstado es requerido'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            estado = Estado.objects.get(IdEstado=nuevo_estado_id)
            orden.IdEstado = estado
            
            # Actualizar fechas según el estado
            if estado.Estado == 'En Preparación' and not orden.FechaInicioCocina:
                from django.utils import timezone
                orden.FechaInicioCocina = timezone.now()
            elif estado.Estado in ['Completada', 'Servida', 'Entregado'] and not orden.FechaFinalizacion:
                from django.utils import timezone
                orden.FechaFinalizacion = timezone.now()
            
            orden.save()
            
            serializer = self.get_serializer(orden)
            return Response(serializer.data)
        except Estado.DoesNotExist:
            return Response(
                {'error': 'Estado no encontrado'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['get'])
    def activas(self, request):
        """Obtener órdenes activas (no completadas ni canceladas)"""
        ordenes = self.queryset.exclude(
            IdEstado__Estado__in=['Completada', 'Cancelada']
        )
        serializer = self.get_serializer(ordenes, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def por_mesero(self, request):
        """Obtener órdenes de un mesero específico"""
        mesero_id = request.query_params.get('mesero_id')
        if not mesero_id:
            return Response(
                {'error': 'mesero_id es requerido'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ordenes = self.queryset.filter(IdUsuario_id=mesero_id)
        serializer = self.get_serializer(ordenes, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def estadisticas(self, request):
        """Obtener estadísticas de órdenes"""
        # Estadísticas de hoy
        hoy = timezone.now().date()
        ordenes_hoy = self.queryset.filter(FechaCreacion__date=hoy)
        
        # Estadísticas de la semana
        inicio_semana = timezone.now() - timedelta(days=7)
        ordenes_semana = self.queryset.filter(FechaCreacion__gte=inicio_semana)
        
        stats = {
            'hoy': {
                'total': ordenes_hoy.count(),
                'completadas': ordenes_hoy.filter(IdEstado__Estado='Completada').count(),
                'pendientes': ordenes_hoy.filter(IdEstado__Estado='Pendiente').count(),
                'en_preparacion': ordenes_hoy.filter(IdEstado__Estado='En Preparación').count(),
                'ingresos': float(ordenes_hoy.aggregate(Sum('Total'))['Total__sum'] or 0),
            },
            'semana': {
                'total': ordenes_semana.count(),
                'completadas': ordenes_semana.filter(IdEstado__Estado='Completada').count(),
                'ingresos': float(ordenes_semana.aggregate(Sum('Total'))['Total__sum'] or 0),
                'promedio_comensales': float(ordenes_semana.aggregate(Avg('NumeroComensales'))['NumeroComensales__avg'] or 0),
            }
        }
        
        return Response(stats)


class ProductoOrdenViewSet(viewsets.ModelViewSet):
    queryset = ProductoOrden.objects.select_related('IdOrden', 'IdProducto').all()
    serializer_class = ProductoOrdenSerializer


class MensajeViewSet(viewsets.ModelViewSet):
    queryset = Mensaje.objects.select_related('IdEmisor', 'IdReceptor').all()
    serializer_class = MensajeSerializer
    
    @action(detail=False, methods=['get'])
    def conversacion(self, request):
        """Obtener mensajes entre dos usuarios"""
        usuario1_id = request.query_params.get('usuario1')
        usuario2_id = request.query_params.get('usuario2')
        
        if not usuario1_id or not usuario2_id:
            return Response(
                {'error': 'usuario1 y usuario2 son requeridos'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        mensajes = self.queryset.filter(
            Q(IdEmisor_id=usuario1_id, IdReceptor_id=usuario2_id) |
            Q(IdEmisor_id=usuario2_id, IdReceptor_id=usuario1_id)
        ).order_by('FechaEnvio')
        
        serializer = self.get_serializer(mensajes, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def conversaciones(self, request):
        """Obtener lista de usuarios con los que se ha conversado"""
        usuario_id = request.query_params.get('usuario_id')
        
        if not usuario_id:
            return Response(
                {'error': 'usuario_id es requerido'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Obtener IDs únicos de usuarios con conversaciones
        conversaciones = Mensaje.objects.filter(
            Q(IdEmisor_id=usuario_id) | Q(IdReceptor_id=usuario_id)
        ).values_list('IdEmisor_id', 'IdReceptor_id')
        
        usuarios_ids = set()
        for emisor_id, receptor_id in conversaciones:
            if emisor_id != int(usuario_id):
                usuarios_ids.add(emisor_id)
            if receptor_id != int(usuario_id):
                usuarios_ids.add(receptor_id)
        
        return Response(list(usuarios_ids))
    
    @action(detail=False, methods=['get'])
    def no_leidos(self, request):
        """Obtener cantidad de mensajes no leídos"""
        usuario_id = request.query_params.get('usuario_id')
        
        if not usuario_id:
            return Response(
                {'error': 'usuario_id es requerido'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        count = self.queryset.filter(
            IdReceptor_id=usuario_id,
            Leido=False
        ).count()
        
        return Response({'count': count})
    
    @action(detail=False, methods=['post'])
    def marcar_leidos(self, request):
        """Marcar mensajes como leídos"""
        usuario_id = request.data.get('usuario_id')
        emisor_id = request.data.get('emisor_id')
        
        if not usuario_id or not emisor_id:
            return Response(
                {'error': 'usuario_id y emisor_id son requeridos'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        updated = self.queryset.filter(
            IdReceptor_id=usuario_id,
            IdEmisor_id=emisor_id,
            Leido=False
        ).update(Leido=True)
        
        return Response({'updated': updated})