from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    EstadoViewSet, TipoProductoViewSet, TipoUsuarioViewSet,
    PersonaViewSet, UsuarioViewSet, ProductoViewSet, MesaViewSet,
    OrdenViewSet, ProductoOrdenViewSet, MensajeViewSet
)

router = DefaultRouter()
router.register(r'estados', EstadoViewSet)
router.register(r'tipos-producto', TipoProductoViewSet)
router.register(r'tipos-usuario', TipoUsuarioViewSet)
router.register(r'personas', PersonaViewSet)
router.register(r'usuarios', UsuarioViewSet)
router.register(r'productos', ProductoViewSet)
router.register(r'mesas', MesaViewSet)
router.register(r'ordenes', OrdenViewSet)
router.register(r'productos-orden', ProductoOrdenViewSet)
router.register(r'mensajes', MensajeViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
