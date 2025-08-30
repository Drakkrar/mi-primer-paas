#!/bin/bash

# Script para configurar y ejecutar la aplicación en entorno local

echo "🚀 Configurando entorno local de Flask..."

# Crear entorno virtual si no existe
if [ ! -d "venv" ]; then
    echo "📦 Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar entorno virtual
echo "🔧 Activando entorno virtual..."
source venv/bin/activate

# Instalar dependencias
echo "📚 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements.txt

# Configurar variables de entorno para desarrollo
export FLASK_ENV=development
export PORT=5000

echo "✅ Configuración completada!"
echo "🌐 Iniciando servidor Flask en http://localhost:5000"
echo "🛑 Presiona Ctrl+C para detener el servidor"
echo ""

# Iniciar la aplicación
python app.py
