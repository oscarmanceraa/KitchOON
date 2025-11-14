# 🍽️ Sistema de Gestión de Restaurante

Sistema completo de gestión de restaurante con dashboards específicos por rol, gestión de órdenes en tiempo real, mensajería interna y analíticas avanzadas.

![Stack](https://img.shields.io/badge/React-TypeScript-blue)
![Backend](https://img.shields.io/badge/Django-REST_Framework-green)
![Database](https://img.shields.io/badge/SQL_Server-Relacional-red)

## 🎯 Características Principales

### 👤 Gestión por Roles

- **👨‍💼 Administrador**: Panel completo con estadísticas, CRUD de usuarios, productos y órdenes
- **👨‍🍳 Cocina**: Gestión de órdenes en preparación, actualización de estados
- **🧑‍💼 Mesero**: Creación de órdenes, gestión de mesas, seguimiento de pedidos

### 📊 Analíticas Avanzadas

- Ingresos por día/período
- Productos más vendidos
- Tiempo promedio de preparación
- Distribución por estado de órdenes
- Ventas por categoría
- Gráficas interactivas con Recharts

### 💬 Mensajería Interna

- Chat en tiempo real entre usuarios
- Notificaciones de mensajes no leídos
- Historial de conversaciones

### 🛠️ CRUD Completo

- Gestión de usuarios y personal
- Catálogo de productos
- Administración de mesas
- Control de órdenes

## 🚀 Tecnologías

### Frontend
- **React** con TypeScript
- **Tailwind CSS** para estilos
- **shadcn/ui** para componentes
- **Recharts** para gráficas
- **Lucide React** para iconos
- **Sonner** para notificaciones

### Backend
- **Django 4.2** - Framework web
- **Django REST Framework** - API REST
- **mssql-django** - Conector SQL Server
- **django-cors-headers** - CORS

### Base de Datos
- **SQL Server** (Recomendado)
- También compatible con PostgreSQL y SQLite

## 📋 Estructura de Base de Datos

```sql
Estados
├── IdEstado (PK)
├── Estado
└── Descripcion

TiposProducto
├── IdTipoProducto (PK)
├── TipoProducto
└── Descripcion

TiposUsuario
├── IdTipoUsuario (PK)
├── TipoUsuario
└── Descripcion

Personas
├── IdPersona (PK)
├── PrimerNombre
├── SegundoNombre
├── PrimerApellido
├── SegundoApellido
├── FechaNacimiento
├── Telefono
├── Email
└── Direccion

Usuarios
├── IdUsuario (PK)
├── IdPersona (FK)
├── IdTipoUsuario (FK)
├── IdEstado (FK)
├── Username
├── Password
├── FechaCreacion
└── UltimoAcceso

Productos
├── IdProducto (PK)
├── IdTipoProducto (FK)
├── IdEstado (FK)
├── NombreProducto
├── Descripcion
├── Precio
└── TiempoPreparacion

Mesas
├── IdMesa (PK)
├── NumeroMesa
├── Capacidad
├── IdEstado (FK)
└── Ubicacion

Ordenes
├── IdOrden (PK)
├── IdMesa (FK)
├── IdUsuario (FK)
├── IdEstado (FK)
├── FechaCreacion
├── FechaActualizacion
├── NumeroComensales
├── Observaciones
└── Total

ProductosOrden
├── IdProductoOrden (PK)
├── IdOrden (FK)
├── IdProducto (FK)
├── Cantidad
├── PrecioUnitario
└── Observaciones

Mensajes
├── IdMensaje (PK)
├── IdEmisor (FK)
├── IdReceptor (FK)
├── Mensaje
├── FechaEnvio
└── Leido
```

## 🎯 Inicio Rápido

### Requisitos Previos
- Python 3.8+
- Node.js 16+
- SQL Server (Docker recomendado)

### Instalación Rápida (Docker + SQL Server)

```bash
# 1. Iniciar SQL Server
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=YourStrong@Passw0rd" \
   -p 1433:1433 --name sqlserver \
   -d mcr.microsoft.com/mssql/server:2022-latest

# 2. Crear base de datos
cd django-backend
sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -i sql/create_database.sql

# 3. Configurar Backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Editar .env con tus credenciales

python manage.py migrate
python manage.py seed_data
python manage.py runserver

# 4. Configurar Frontend (en otra terminal)
cd ..
cp .env.example .env
npm install
npm run dev
```

### Acceso

- **Frontend**: http://localhost:5173
- **API**: http://localhost:8000/api/
- **Admin Django**: http://localhost:8000/admin/

### Credenciales de Prueba

| Usuario | Username | Password | Rol |
|---------|----------|----------|-----|
| Admin | `admin` | `admin123` | Administrador |
| Mesero | `mesero1` | `mesero123` | Mesero |
| Cocina | `cocina1` | `cocina123` | Cocina |

## 📚 Documentación

- [🚀 QUICKSTART.md](./QUICKSTART.md) - Guía de inicio rápido
- [🗄️ SQLSERVER_SETUP.md](./SQLSERVER_SETUP.md) - Configuración de SQL Server
- [⚙️ DJANGO_SETUP.md](./DJANGO_SETUP.md) - Configuración de Django
- [🔗 FRONTEND_INTEGRATION.md](./FRONTEND_INTEGRATION.md) - Integración del Frontend

## 🎨 Capturas de Pantalla

### Dashboard de Administrador
![Admin Dashboard](docs/admin-dashboard.png)

### Panel de Estadísticas
![Stats Panel](docs/stats-panel.png)

### Dashboard de Mesero
![Waiter Dashboard](docs/waiter-dashboard.png)

### Dashboard de Cocina
![Kitchen Dashboard](docs/kitchen-dashboard.png)

## 🔌 API Endpoints

### Autenticación
```
POST /api/usuarios/login/
```

### Usuarios
```
GET    /api/usuarios/
GET    /api/usuarios/activos/
GET    /api/usuarios/{id}/
POST   /api/usuarios/
PATCH  /api/usuarios/{id}/
DELETE /api/usuarios/{id}/
```

### Productos
```
GET    /api/productos/
GET    /api/productos/disponibles/
GET    /api/productos/{id}/
POST   /api/productos/
PATCH  /api/productos/{id}/
DELETE /api/productos/{id}/
```

### Órdenes
```
GET    /api/ordenes/
GET    /api/ordenes/activas/
GET    /api/ordenes/{id}/
GET    /api/ordenes/estadisticas/
POST   /api/ordenes/
PATCH  /api/ordenes/{id}/actualizar_estado/
DELETE /api/ordenes/{id}/
```

### Mensajes
```
GET    /api/mensajes/
GET    /api/mensajes/conversacion/
GET    /api/mensajes/no_leidos/
POST   /api/mensajes/
POST   /api/mensajes/marcar_leidos/
```

[Ver documentación completa de API](./DJANGO_SETUP.md#endpoints-de-la-api)

## 🏗️ Arquitectura

```
┌─────────────────┐
│   React + TS    │  Frontend
│   Tailwind CSS  │
└────────┬────────┘
         │ HTTP/REST
         │
┌────────▼────────┐
│  Django REST    │  Backend
│   Framework     │
└────────┬────────┘
         │ ORM
         │
┌────────▼────────┐
│   SQL Server    │  Database
│   (Relacional)  │
└─────────────────┘
```

## 🔐 Seguridad

⚠️ **Importante**: Esta configuración es para desarrollo. Para producción:

1. **Contraseñas**: Implementar hash con `django.contrib.auth.hashers`
2. **SECRET_KEY**: Usar clave única y segura
3. **DEBUG**: Configurar a `False`
4. **ALLOWED_HOSTS**: Definir hosts específicos
5. **CORS**: Restringir a dominios permitidos
6. **HTTPS**: Usar certificados SSL/TLS
7. **JWT**: Implementar autenticación con tokens

## 🛠️ Desarrollo

### Comandos Útiles

```bash
# Backend
python manage.py makemigrations  # Crear migraciones
python manage.py migrate         # Aplicar migraciones
python manage.py shell          # Shell interactivo
python manage.py seed_data      # Poblar datos de prueba

# Frontend
npm run dev                     # Servidor de desarrollo
npm run build                   # Build para producción
npm run lint                    # Linter
```

### Estructura del Proyecto

```
.
├── django-backend/
│   ├── restaurant/              # App Django
│   │   ├── models.py           # Modelos
│   │   ├── views.py            # ViewSets
│   │   ├── serializers.py      # Serializers
│   │   └── urls.py             # URLs
│   ├── restaurant_project/     # Config
│   │   └── settings.py         # Settings
│   └── sql/                    # Scripts SQL
│       ├── create_database.sql
│       └── seed_data.sql
├── components/                  # Componentes React
│   ├── AdminDashboard.tsx
│   ├── StatsPanel.tsx
│   ├── WaiterDashboard.tsx
│   └── KitchenDashboard.tsx
├── lib/
│   ├── api.ts                  # Cliente API
│   └── mockDatabase.ts         # Mock data
└── hooks/
    └── useApi.ts               # Custom hooks
```

## 🧪 Testing

```bash
# Backend (Django)
python manage.py test

# Frontend (React)
npm run test
```

## 📦 Deployment

### Backend (Django)

```bash
# Recolectar archivos estáticos
python manage.py collectstatic

# Configurar gunicorn o uwsgi
gunicorn restaurant_project.wsgi:application
```

### Frontend (React)

```bash
# Build para producción
npm run build

# Servir con nginx o servidor estático
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Autores

- **Tu Nombre** - *Trabajo inicial*

## 🙏 Agradecimientos

- shadcn/ui por los componentes
- Django REST Framework
- Recharts por las gráficas

---

⭐ Si este proyecto te fue útil, considera darle una estrella!
