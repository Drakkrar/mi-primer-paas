#!/bin/bash

# deploy.sh - Script automatizado para despliegue ZIP en Azure Web App
# Uso: ./deploy.sh [nombre-webapp] [grupo-recursos]

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con color
print_message() {
    echo -e "${BLUE}🚀${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Variables por defecto (pueden ser sobrescritas por parámetros)
RESOURCE_GROUP=${2:-"mi-primer-paas-rg"}
WEBAPP_NAME=${1:-"mi-primer-paas-webapp"}
ZIP_NAME="deploy-$(date +%Y%m%d-%H%M%S).zip"

print_message "Iniciando despliegue en Azure Web App"
echo "  📱 Web App: $WEBAPP_NAME"
echo "  📁 Grupo de recursos: $RESOURCE_GROUP"
echo ""

# Verificar que Azure CLI está instalado
if ! command -v az &> /dev/null; then
    print_error "Azure CLI no está instalado. Instalalo primero:"
    echo "  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Verificar que el usuario está logueado en Azure
print_message "Verificando autenticación con Azure..."
if ! az account show &> /dev/null; then
    print_error "No estás autenticado en Azure. Ejecuta: az login"
    exit 1
fi

print_success "Autenticación verificada"

# Verificar que la Web App existe
print_message "Verificando que la Web App existe..."
if ! az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
    print_error "La Web App '$WEBAPP_NAME' no existe en el grupo '$RESOURCE_GROUP'"
    print_warning "Crea la Web App primero o verifica los nombres"
    exit 1
fi

print_success "Web App encontrada"

# Verificar archivos necesarios
print_message "Verificando archivos necesarios..."
required_files=("app.py" "requirements.txt" "startup.sh")
missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    print_error "Archivos faltantes: ${missing_files[*]}"
    exit 1
fi

print_success "Todos los archivos necesarios están presentes"

# Crear ZIP con archivos necesarios
print_message "Creando paquete de despliegue..."

# Archivos a incluir
include_files=(
    "app.py"
    "requirements.txt" 
    "startup.sh"
    "templates/"
)

# Crear el comando zip
zip_cmd="zip -r $ZIP_NAME"
for file in "${include_files[@]}"; do
    if [ -e "$file" ]; then
        zip_cmd="$zip_cmd $file"
    fi
done

# Ejecutar creación del ZIP silenciosamente
eval "$zip_cmd" -q

if [ $? -eq 0 ]; then
    print_success "Paquete creado: $ZIP_NAME"
    
    # Mostrar contenido del ZIP
    print_message "Contenido del paquete:"
    unzip -l $ZIP_NAME | grep -E '^\s*[0-9]' | awk '{print "  📄 " $4}'
else
    print_error "Error creando el paquete ZIP"
    exit 1
fi

# Desplegar en Azure
print_message "Desplegando en Azure Web App..."

az webapp deploy \
    --resource-group $RESOURCE_GROUP \
    --name $WEBAPP_NAME \
    --src-path $ZIP_NAME \
    --type zip \
    --async false

if [ $? -eq 0 ]; then
    print_success "¡Despliegue exitoso!"
    
    # Mostrar información útil
    echo ""
    print_message "Información del despliegue:"
    echo "  🌐 URL: https://$WEBAPP_NAME.azurewebsites.net"
    echo "  🔍 Health Check: https://$WEBAPP_NAME.azurewebsites.net/health"
    echo "  📊 API Info: https://$WEBAPP_NAME.azurewebsites.net/api/info"
    echo ""
    
    # Verificar que la aplicación responde
    print_message "Verificando que la aplicación responde..."
    sleep 10  # Esperar a que la app se inicie
    
    if curl -s "https://$WEBAPP_NAME.azurewebsites.net/health" > /dev/null; then
        print_success "¡La aplicación está respondiendo correctamente!"
    else
        print_warning "La aplicación puede estar arrancando. Verifica en unos minutos."
    fi
    
    # Limpiar archivo ZIP
    rm $ZIP_NAME
    print_success "Archivo temporal eliminado"
    
    echo ""
    print_success "🎉 ¡Despliegue completado exitosamente!"
    
else
    print_error "Error en el despliegue"
    
    # Mostrar logs para debugging
    print_message "Obteniendo logs de la aplicación..."
    az webapp log tail --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --timeout 30
    
    # No eliminar ZIP en caso de error para debugging
    print_warning "Archivo ZIP conservado para debugging: $ZIP_NAME"
    exit 1
fi
