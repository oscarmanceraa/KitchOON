from rest_framework import serializers
from .models import (
    Estado, TipoProducto, TipoUsuario, Persona, Usuario,
    Producto, Mesa, Orden, ProductoOrden, Mensaje
)


class EstadoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Estado
        fields = '__all__'


class TipoProductoSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoProducto
        fields = '__all__'


class TipoUsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoUsuario
        fields = '__all__'


class PersonaSerializer(serializers.ModelSerializer):
    NombreCompleto = serializers.SerializerMethodField()
    
    class Meta:
        model = Persona
        fields = '__all__'
    
    def get_NombreCompleto(self, obj):
        return obj.get_nombre_completo()


class UsuarioSerializer(serializers.ModelSerializer):
    Persona = PersonaSerializer(source='IdPersona', read_only=True)
    TipoUsuario = TipoUsuarioSerializer(source='IdTipoUsuario', read_only=True)
    Estado = EstadoSerializer(source='IdEstado', read_only=True)
    
    # Para escritura
    IdPersona_id = serializers.IntegerField(write_only=True, required=False)
    IdTipoUsuario_id = serializers.IntegerField(write_only=True, required=False)
    IdEstado_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Usuario
        fields = '__all__'
        extra_kwargs = {
            'Password': {'write_only': True}
        }
    
    def create(self, validated_data):
        # En producción, hashear la contraseña aquí
        return super().create(validated_data)
    
    def update(self, instance, validated_data):
        # En producción, hashear la contraseña aquí si se actualiza
        return super().update(instance, validated_data)


class UsuarioSimpleSerializer(serializers.ModelSerializer):
    """Versión simplificada para listados"""
    NombreCompleto = serializers.SerializerMethodField()
    TipoUsuario = serializers.CharField(source='IdTipoUsuario.TipoUsuario', read_only=True)
    
    class Meta:
        model = Usuario
        fields = ['IdUsuario', 'Username', 'NombreCompleto', 'TipoUsuario', 'IdEstado']
    
    def get_NombreCompleto(self, obj):
        return obj.IdPersona.get_nombre_completo()


class ProductoSerializer(serializers.ModelSerializer):
    TipoProducto = TipoProductoSerializer(source='IdTipoProducto', read_only=True)
    Estado = EstadoSerializer(source='IdEstado', read_only=True)
    
    # Para escritura
    IdTipoProducto_id = serializers.IntegerField(write_only=True, required=False)
    IdEstado_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Producto
        fields = '__all__'


class MesaSerializer(serializers.ModelSerializer):
    Estado = EstadoSerializer(source='IdEstado', read_only=True)
    
    # Para escritura
    IdEstado_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Mesa
        fields = '__all__'


class ProductoOrdenSerializer(serializers.ModelSerializer):
    Producto = ProductoSerializer(source='IdProducto', read_only=True)
    NombreProducto = serializers.CharField(source='IdProducto.NombreProducto', read_only=True)
    
    # Para escritura
    IdProducto_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = ProductoOrden
        fields = '__all__'


class ProductoOrdenCreateSerializer(serializers.ModelSerializer):
    """Serializer simplificado para crear productos de orden"""
    class Meta:
        model = ProductoOrden
        fields = ['IdProducto', 'Cantidad', 'PrecioUnitario', 'Observaciones']


class OrdenSerializer(serializers.ModelSerializer):
    Mesa = MesaSerializer(source='IdMesa', read_only=True)
    Usuario = UsuarioSimpleSerializer(source='IdUsuario', read_only=True)
    Estado = EstadoSerializer(source='IdEstado', read_only=True)
    Productos = ProductoOrdenSerializer(source='productos_orden', many=True, read_only=True)
    
    # Campos calculados de tiempo
    TiempoTranscurrido = serializers.SerializerMethodField()
    TiempoEnCocina = serializers.SerializerMethodField()
    TiempoPreparacionEstimado = serializers.SerializerMethodField()
    
    # Para escritura
    IdMesa_id = serializers.IntegerField(write_only=True, required=False)
    IdUsuario_id = serializers.IntegerField(write_only=True, required=False)
    IdEstado_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Orden
        fields = '__all__'
    
    def get_TiempoTranscurrido(self, obj):
        """Retorna tiempo transcurrido en minutos"""
        return obj.tiempo_transcurrido()
    
    def get_TiempoEnCocina(self, obj):
        """Retorna tiempo en cocina en minutos"""
        return obj.tiempo_en_cocina()
    
    def get_TiempoPreparacionEstimado(self, obj):
        """Retorna tiempo estimado de preparación en minutos"""
        return obj.tiempo_preparacion_estimado()


class OrdenCreateSerializer(serializers.ModelSerializer):
    """Serializer para crear órdenes con productos"""
    productos = ProductoOrdenCreateSerializer(many=True, write_only=True)
    
    class Meta:
        model = Orden
        fields = [
            'IdMesa', 'IdUsuario', 'IdEstado', 'NumeroComensales',
            'Observaciones', 'productos'
        ]
    
    def create(self, validated_data):
        productos_data = validated_data.pop('productos', [])
        orden = Orden.objects.create(**validated_data)
        
        for producto_data in productos_data:
            ProductoOrden.objects.create(IdOrden=orden, **producto_data)
        
        return orden


class MensajeSerializer(serializers.ModelSerializer):
    Emisor = UsuarioSimpleSerializer(source='IdEmisor', read_only=True)
    Receptor = UsuarioSimpleSerializer(source='IdReceptor', read_only=True)
    
    # Para escritura
    IdEmisor_id = serializers.IntegerField(write_only=True, required=False)
    IdReceptor_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = Mensaje
        fields = '__all__'


class LoginSerializer(serializers.Serializer):
    """Serializer para login"""
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)