#!/bin/bash

# Script de inicio para Azure Web App (Linux)
# Este script se ejecuta automáticamente cuando se inicia el contenedor

echo "Iniciando aplicación Flask en Azure Web App..."

# Instalar dependencias si no están instaladas
if [ ! -d "venv" ]; then
    echo "Creando entorno virtual..."
    python -m venv venv
fi

# Activar entorno virtual
source venv/bin/activate

# Instalar/actualizar dependencias
echo "Instalando dependencias..."
pip install --no-cache-dir -r requirements.txt

# Configurar variables de entorno para producción
export FLASK_ENV=production

# Obtener el puerto de Azure (por defecto 8000)
export PORT=${PORT:-8000}

echo "Iniciando servidor Gunicorn en puerto $PORT..."

# Iniciar la aplicación con Gunicorn
# --bind 0.0.0.0:$PORT : Escuchar en todas las interfaces en el puerto especificado
# --workers 4 : Usar 4 procesos worker para manejar peticiones
# --timeout 120 : Timeout de 120 segundos para peticiones
# --keep-alive 2 : Keep-alive de 2 segundos
# --max-requests 1000 : Reiniciar worker después de 1000 peticiones
exec gunicorn --bind 0.0.0.0:$PORT \
              --workers 4 \
              --timeout 120 \
              --keep-alive 2 \
              --max-requests 1000 \
              --preload \
              app:app
