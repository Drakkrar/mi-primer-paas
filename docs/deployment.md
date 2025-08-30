# 🚀 Guía de Despliegue en Azure Web App

Esta guía detalla el proceso completo para empaquetar y desplegar la aplicación Flask en Azure Web App.

## 📋 Prerrequisitos

### Herramientas necesarias:
- **Azure CLI** (instalado y configurado)
- **Git** (para despliegue desde repositorio)
- **Python 3.9+** (para pruebas locales)
- **Cuenta de Azure** con suscripción activa

### Instalación de Azure CLI:
**NOTA:** Este script puede cambiar con nuevas actualizaciones si Microsoft asi lo necesita. [Microsoft Azure | Instalacion de la CLI](https://learn.microsoft.com/es-es/cli/azure/install-azure-cli?view=azure-cli-latest)
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Windows (PowerShell)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

## 🏗️ Preparación del código

### 1. Verificar estructura del proyecto
```
miprimerpaas/
├── app.py              # ✅ Aplicación principal
├── requirements.txt    # ✅ Dependencias
├── startup.sh         # ✅ Script de inicio
└── templates/         # ✅ Plantillas HTML
```

### 2. Verificar archivos críticos

**requirements.txt** - Debe incluir todas las dependencias:
```
Flask==2.3.3
Werkzeug==2.3.7
gunicorn==21.2.0
```

**startup.sh** - Script de inicio para Azure (ya incluido):
```bash
#!/bin/bash
exec gunicorn --bind 0.0.0.0:$PORT --workers 4 app:app
```

## ☁️ Despliegue en Azure Web App

### Método 1: Despliegue directo con Azure CLI

#### 1. Autenticarse en Azure
```bash
az login
```

#### 2. Crear grupo de recursos
```bash
az group create --name mi-primer-paas-rg --location "East US"
```

#### 3. Crear plan de App Service (Linux)
```bash
az appservice plan create \
    --name mi-primer-paas-plan \
    --resource-group mi-primer-paas-rg \
    --sku B1 \
    --is-linux
```

#### 4. Crear Web App con Python
```bash
az webapp create \
    --resource-group mi-primer-paas-rg \
    --plan mi-primer-paas-plan \
    --name mi-primer-paas-webapp \
    --runtime "PYTHON|3.9" \
    --deployment-local-git
```

#### 5. Configurar comando de inicio
```bash
az webapp config set \
    --resource-group mi-primer-paas-rg \
    --name mi-primer-paas-webapp \
    --startup-file "startup.sh"
```

#### 6. Desplegar código
```bash
# Inicializar repositorio git (si no existe)
git init
git add .
git commit -m "Initial commit"

# Obtener URL de Git remoto
git remote add azure $(az webapp deployment source config-local-git \
    --name mi-primer-paas-webapp \
    --resource-group mi-primer-paas-rg \
    --query url --output tsv)

# Obtener credenciales de despliegue
az webapp deployment list-publishing-credentials \
    --name mi-primer-paas-webapp \
    --resource-group mi-primer-paas-rg

# Push al repositorio de Azure
git push azure main
```

### Método 2: Despliegue mediante ZIP

Este es el método **más rápido y sencillo** para desplegar tu aplicación Flask directamente desde un archivo ZIP.

#### 1. Preparar el código para empaquetado
```bash
# Asegurar que todos los archivos están listos
ls -la
# Debes ver: app.py, requirements.txt, startup.sh, templates/
```

#### 2. Crear archivo ZIP con el código
```bash
# Crear ZIP con todos los archivos necesarios (excluyendo archivos innecesarios)
zip -r mi-primer-paas.zip . -x "*.git*" "venv/*" "__pycache__/*" "*.pyc" ".env" "docs/*" "README.md" "run_local.sh"

# O usar una versión más específica incluyendo solo lo necesario
zip -r mi-primer-paas.zip app.py requirements.txt startup.sh templates/ .gitignore
```

#### 3. Verificar contenido del ZIP
```bash
# Ver contenido del archivo ZIP
unzip -l mi-primer-paas.zip
```

El ZIP debe contener:
```
mi-primer-paas.zip
├── app.py
├── requirements.txt
├── startup.sh
├── templates/
│   └── index.html
└── .gitignore
```

#### 4. Desplegar usando az webapp deploy
```bash
# Desplegar directamente desde ZIP
az webapp deploy \
    --resource-group mi-primer-paas-rg \
    --name mi-primer-paas-webapp \
    --src-path mi-primer-paas.zip \
    --type zip
```

#### 5. Verificar el despliegue
```bash
# Ver el estado del despliegue
az webapp deployment list \
    --resource-group mi-primer-paas-rg \
    --name mi-primer-paas-webapp

# Acceder a la aplicación
az webapp browse \
    --resource-group mi-primer-paas-rg \
    --name mi-primer-paas-webapp
```

#### Ventajas del despliegue por ZIP:
- ✅ **Rápido**: No requiere configurar Git
- ✅ **Simple**: Un solo comando para desplegar
- ✅ **Control**: Decides exactamente qué archivos incluir
- ✅ **Reproducible**: Mismo ZIP = mismo despliegue
- ✅ **Ideal para CI/CD**: Fácil de automatizar

#### Script automatizado para despliegue ZIP:
```bash
#!/bin/bash
# deploy.sh - Script automatizado para despliegue ZIP

echo "📦 Creando paquete de despliegue..."

# Variables
RESOURCE_GROUP="mi-primer-paas-rg"
WEBAPP_NAME="mi-primer-paas-webapp"
ZIP_NAME="deploy-$(date +%Y%m%d-%H%M%S).zip"

# Crear ZIP con archivos necesarios
zip -r $ZIP_NAME app.py requirements.txt startup.sh templates/ -q

echo "✅ Paquete creado: $ZIP_NAME"
echo "🚀 Desplegando a Azure..."

# Desplegar
az webapp deploy \
    --resource-group $RESOURCE_GROUP \
    --name $WEBAPP_NAME \
    --src-path $ZIP_NAME \
    --type zip

if [ $? -eq 0 ]; then
    echo "✅ Despliegue exitoso!"
    echo "🌐 URL: https://$WEBAPP_NAME.azurewebsites.net"
    
    # Limpiar archivo ZIP
    rm $ZIP_NAME
    echo "🧹 Archivo temporal eliminado"
else
    echo "❌ Error en el despliegue"
    exit 1
fi
```

#### Usando el script automatizado (Recomendado)
Hemos incluido un script `deploy.sh` que automatiza todo el proceso:

```bash
# Hacer el script ejecutable (solo la primera vez)
chmod +x deploy.sh

# Desplegar con nombres por defecto
./deploy.sh

# O especificar nombres personalizados
./deploy.sh mi-webapp-personalizada mi-grupo-recursos
```

**El script automatizado:**
- ✅ Verifica la autenticación con Azure
- ✅ Valida que la Web App existe
- ✅ Comprueba archivos necesarios
- ✅ Crea ZIP con archivos correctos
- ✅ Despliega automáticamente
- ✅ Verifica que la aplicación responde
- ✅ Muestra URLs útiles
- ✅ Limpia archivos temporales

#### Comparación de métodos de despliegue:

| Método | Velocidad | Complejidad | Mejor para |
|--------|-----------|-------------|------------|
| **ZIP** | ⚡ Muy rápido | 🟢 Simple | Despliegues rápidos, testing |
| **Git local** | 🐌 Lento | 🟡 Medio | Desarrollo continuo |
| **GitHub** | 🐌 Lento | 🟡 Medio | CI/CD, equipos |

### Método 3: Despliegue desde GitHub

#### 1. Subir código a GitHub
```bash
git init
git add .
git commit -m "Flask app para Azure"
git branch -M main
git remote add origin https://github.com/tu-usuario/mi-primer-paas.git
git push -u origin main
```

#### 2. Configurar despliegue continuo
```bash
az webapp deployment source config \
    --name mi-primer-paas-webapp \
    --resource-group mi-primer-paas-rg \
    --repo-url https://github.com/tu-usuario/mi-primer-paas \
    --branch main \
    --manual-integration
```

## ⚙️ Configuraciones importantes para Azure Linux Web App

### 1. Comando de inicio (Startup Command)
En el portal de Azure o por CLI:
```bash
startup.sh
```
O directamente:
```bash
gunicorn --bind 0.0.0.0:$PORT --workers 4 app:app
```

## 🔍 Verificación del despliegue

### 1. Obtener URL de la aplicación
```bash
az webapp show \
    --name mi-primer-paas-webapp \
    --resource-group mi-primer-paas-rg \
    --query defaultHostName --output tsv
```

### 2. Probar endpoints
```bash
# Página principal
curl https://mi-primer-paas-webapp.azurewebsites.net/

# Health check
curl https://mi-primer-paas-webapp.azurewebsites.net/health

# API info
curl https://mi-primer-paas-webapp.azurewebsites.net/api/info
```

### 3. Ver logs de la aplicación
```bash
# Logs en tiempo real
az webapp log tail \
    --name mi-primer-paas-webapp \
    --resource-group mi-primer-paas-rg

# Descargar logs
az webapp log download \
    --name mi-primer-paas-webapp \
    --resource-group mi-primer-paas-rg
```

## 🛠️ Consideraciones específicas para Azure Linux Web App

### Port Binding
- Azure asigna automáticamente un puerto a través de la variable `$PORT`
- La aplicación debe escuchar en `0.0.0.0:$PORT`
- Por defecto, Azure usa el puerto 8000

### Servidor WSGI
- **Gunicorn** es el servidor recomendado para producción
- Configuración optimizada en `startup.sh`:
  - 4 workers para balance de carga
  - Timeout de 120 segundos
  - Keep-alive configurado

### Sistema de archivos
- Directorio de trabajo: `/home/site/wwwroot`
- Solo `/home` es persistente entre reinicios
- Use storage externo para archivos persistentes

### Limitaciones
- No se puede usar `sudo`
- No acceso a servicios del sistema
- Memoria limitada según el plan elegido

## 🔧 Troubleshooting

### Problemas comunes:

**Error 502/503:**
```bash
# Verificar logs
az webapp log tail -n mi-primer-paas-webapp -g mi-primer-paas-rg
```

**Módulos de Python no encontrados:**
```bash
# Verificar requirements.txt está en la raíz
# Verificar el startup command
az webapp config show -n mi-primer-paas-webapp -g mi-primer-paas-rg
```

**Puerto incorrecto:**
- Asegurar que la app usa `os.environ.get('PORT')`
- Verificar que Gunicorn usa `--bind 0.0.0.0:$PORT`

**Problemas específicos del despliegue ZIP:**
```bash
# ZIP corrupto o incompleto
unzip -t mi-primer-paas.zip  # Verificar integridad

# Archivos faltantes en el ZIP
unzip -l mi-primer-paas.zip  # Listar contenido

# Recrear ZIP con archivos correctos
zip -r mi-primer-paas.zip app.py requirements.txt startup.sh templates/
```

**Error de autenticación en Azure:**
```bash
# Renovar login
az logout
az login

# Verificar suscripción activa
az account show
```

**Web App no responde después del despliegue:**
```bash
# Reiniciar la Web App
az webapp restart --name mi-primer-paas-webapp --resource-group mi-primer-paas-rg

# Verificar configuración del comando de inicio
az webapp config show --name mi-primer-paas-webapp --resource-group mi-primer-paas-rg --query linuxFxVersion
```

## ✅ Lista de verificación pre-despliegue

**Para despliegue ZIP:**
- [ ] Archivos necesarios: `app.py`, `requirements.txt`, `startup.sh`, `templates/`
- [ ] `startup.sh` con permisos de ejecución (`chmod +x startup.sh`)
- [ ] ZIP no contiene archivos innecesarios (`.git`, `venv`, `__pycache__`)
- [ ] Azure CLI instalado y autenticado (`az login`)
- [ ] Web App creada y configurada en Azure
- [ ] Script `deploy.sh` ejecutable (opcional pero recomendado)

**General:**
- [ ] `requirements.txt` actualizado con todas las dependencias
- [ ] App configurada para usar `$PORT` environment variable
- [ ] Código testeado localmente
- [ ] Recursos de Azure creados (Resource Group, App Service Plan, Web App)
- [ ] Comando de inicio configurado en Azure
- [ ] Variables de entorno configuradas (si las necesita)
