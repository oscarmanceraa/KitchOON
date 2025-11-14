FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    mariadb-client-compat \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

# Copiar código
COPY . .

# Crear directorios necesarios
RUN mkdir -p staticfiles media logs

# Exponer puerto
EXPOSE 8000

CMD ["gunicorn", "restaurant_project.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "4"]
