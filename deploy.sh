#!/bin/bash

# =============================================
# Script de Deploy Automático para kitchON
# Hostinger - Ubuntu Server
# =============================================

set -e

echo "🚀 Iniciando deploy de kitchON en Hostinger..."

# Variables
APP_DIR="/home/usuario/kitchon"  # Cambiar por tu usuario
REPO_URL="https://github.com/manceraoscar38-lab/KitchON.git"
BACKEND_DIR="$APP_DIR/src/back"
FRONTEND_DIR="$APP_DIR"

# 1. Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependencias
echo "📥 Instalando dependencias..."
sudo apt install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    nodejs \
    npm \
    git \
    mysql-server \
    curl \
    wget \
    nano \
    supervisor

# 3. Crear directorio de la app
echo "📁 Creando directorios..."
mkdir -p $APP_DIR
cd $APP_DIR

# 4. Clonar repositorio
echo "📂 Clonando repositorio..."
if [ -d ".git" ]; then
    git pull origin main
else
    git clone $REPO_URL .
fi

# 5. Configurar Backend
echo "⚙️  Configurando Backend..."
cd $BACKEND_DIR

# Crear entorno virtual
python3.11 -m venv venv
source venv/bin/activate

# Instalar requerimientos
pip install -r requirements.txt
pip install gunicorn

# Crear archivo .env para producción
cat > .env << EOF
SECRET_KEY=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
DEBUG=False
ALLOWED_HOSTS=tu-dominio.com,www.tu-dominio.com,127.0.0.1

DB_ENGINE=django.db.backends.mysql
DB_NAME=restaurant_db
DB_USER=kitchon_user
DB_PASSWORD=$(openssl rand -base64 16)
DB_HOST=127.0.0.1
DB_PORT=3306

CORS_ALLOWED_ORIGINS=https://tu-dominio.com,https://www.tu-dominio.com
CSRF_TRUSTED_ORIGINS=https://tu-dominio.com,https://www.tu-dominio.com
EOF

echo "✅ .env creado. Edítalo con tus datos:"
echo "nano $BACKEND_DIR/.env"

# 6. Configurar Base de Datos
echo "🗄️  Configurando MySQL..."
sudo mysql_secure_installation --skip-validate-password

# Crear base de datos y usuario
sudo mysql -u root -p << MYSQL_EOF
CREATE DATABASE IF NOT EXISTS restaurant_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kitchon_user'@'127.0.0.1' IDENTIFIED BY 'tu-password-aqui';
GRANT ALL PRIVILEGES ON restaurant_db.* TO 'kitchon_user'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT;
MYSQL_EOF

# Ejecutar migraciones SQL
mysql -u kitchon_user -p restaurant_db < sql/create_database_mysql.sql
mysql -u kitchon_user -p restaurant_db < sql/seed_data_mysql.sql

# Ejecutar migraciones Django
python manage.py migrate --fake-initial
python manage.py collectstatic --noinput

# 7. Configurar Supervisor para Backend
echo "🔧 Configurando Supervisor..."
sudo tee /etc/supervisor/conf.d/kitchon-backend.conf > /dev/null << EOF
[program:kitchon-backend]
directory=$BACKEND_DIR
command=$BACKEND_DIR/venv/bin/gunicorn restaurant_project.wsgi:application --bind 127.0.0.1:8000 --workers 4
autostart=true
autorestart=true
stderr_logfile=$APP_DIR/logs/backend.err.log
stdout_logfile=$APP_DIR/logs/backend.out.log
environment=PATH="$BACKEND_DIR/venv/bin"
EOF

# 8. Configurar Frontend
echo "🎨 Construyendo Frontend..."
cd $FRONTEND_DIR
npm install
npm run build

# 9. Configurar Nginx
echo "🌐 Configurando Nginx..."
sudo apt install -y nginx

sudo tee /etc/nginx/sites-available/kitchon > /dev/null << 'EOF'
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;
    client_max_body_size 100M;

    # Frontend
    location / {
        root /home/usuario/kitchon/dist;
        try_files $uri $uri/ /index.html;
    }

    # API Backend
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /static {
        alias /home/usuario/kitchon/src/back/staticfiles;
    }

    # Media files
    location /media {
        alias /home/usuario/kitchon/src/back/media;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/kitchon /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# 10. Configurar SSL con Let's Encrypt
echo "🔒 Configurando SSL..."
sudo apt install -y certbot python3-certbot-nginx
sudo certbot certonly --nginx -d tu-dominio.com -d www.tu-dominio.com

# 11. Actualizar Nginx con SSL
sudo tee /etc/nginx/sites-available/kitchon > /dev/null << 'EOF'
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tu-dominio.com www.tu-dominio.com;
    client_max_body_size 100M;

    ssl_certificate /etc/letsencrypt/live/tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tu-dominio.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        root /home/usuario/kitchon/dist;
        try_files $uri $uri/ /index.html;
    }

    # API Backend
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /static {
        alias /home/usuario/kitchon/src/back/staticfiles;
    }

    # Media files
    location /media {
        alias /home/usuario/kitchon/src/back/media;
    }
}
EOF

sudo nginx -t
sudo systemctl restart nginx

# 12. Crear logs directory
mkdir -p $APP_DIR/logs

# 13. Recargar Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start kitchon-backend

echo ""
echo "✅ ¡Despliegue completado!"
echo ""
echo "📝 PRÓXIMOS PASOS:"
echo "1. Editar $BACKEND_DIR/.env con tus datos reales"
echo "2. Editar /etc/nginx/sites-available/kitchon y reemplazar 'tu-dominio.com'"
echo "3. Ejecutar: sudo certbot certonly --nginx -d tu-dominio.com"
echo "4. Verificar: sudo systemctl status nginx"
echo "5. Ver logs: tail -f $APP_DIR/logs/backend.out.log"
echo ""
echo "🌐 Tu aplicación estará en: https://tu-dominio.com"
echo ""
