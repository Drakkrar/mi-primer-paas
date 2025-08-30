# Mi Primer PaaS - Flask en Azure

Una aplicación web básica construida con Python Flask, diseñada específicamente para practicar el despliegue en la nube, especificamente un App Service de Microsoft azure. [Azure | App Service](https://learn.microsoft.com/en-us/azure/app-service/overview).

## 📋 Descripción

Esta es una plantilla minimalista de Flask que incluye:
- Una página de inicio con interfaz web
- Endpoints de API REST para monitoreo y pruebas
- Configuración lista para producción con Gunicorn
- Documentación completa para despliegue en Azure

## 🛠️ Instalación y uso local

### Prerrequisitos
- Python 3.9 o superior
- pip (gestor de paquetes de Python)

### Configuración del entorno local

1. **Clonar o descargar el proyecto**:
   ```bash
   git clone https://github.com/Drakkrar/mi-primer-paas.git
   cd mi-primer-paas
   ```

2. **Crear un entorno virtual** (recomendado):
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # o en Windows: venv\Scripts\activate
   ```

3. **Instalar dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configurar variables de entorno** (opcional):
   ```bash
   export FLASK_ENV=development  # Para modo desarrollo
   export PORT=5000             # Puerto local (por defecto)
   ```

5. **Ejecutar la aplicación**:
   ```bash
   python app.py
   ```

6. **Acceder a la aplicación**:
   - Abrir navegador en: `http://localhost:5000`
   - Health check: `http://localhost:5000/health`
   - API info: `http://localhost:5000/api/info`

## 🌐 Endpoints disponibles

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/` | GET | Página principal |
| `/health` | GET | Estado de salud de la aplicación |
| `/api/info` | GET | Información de la aplicación |
| `/test` | GET | Endpoint de prueba |

## 📦 Estructura del proyecto

```
miprimerpaas/
├── app.py                 # Aplicación principal de Flask
├── requirements.txt       # Dependencias de Python
├── startup.sh            # Script de inicio para Azure
├── deploy.sh             # Script automatizado para despliegue ZIP
├── run_local.sh          # Script para desarrollo local
├── templates/
│   └── index.html        # Plantilla HTML principal
├── docs/
│   └── deployment.md     # Documentación completa de despliegue
└── README.md             # Este archivo
```

## � Despliegue rápido en Azure

**Método ZIP (Recomendado para pruebas rápidas):**
```bash
# Usando el script automatizado
./deploy.sh

# O manualmente
zip -r mi-app.zip app.py requirements.txt startup.sh templates/
az webapp deploy --resource-group mi-primer-paas-rg --name mi-primer-paas-webapp --src-path mi-app.zip --type zip
```

**Otros métodos:** Ver documentación completa en `docs/deployment.md`

## �🔧 Desarrollo

Para contribuir o modificar la aplicación:

1. Realiza cambios en `app.py` para la lógica del servidor
2. Modifica `templates/index.html` para cambios en la interfaz  
3. Actualiza `requirements.txt` si agregas nuevas dependencias
4. Prueba localmente con `./run_local.sh`
5. Despliega rápidamente con `./deploy.sh`

## 📝 Notas

- La aplicación está configurada para ejecutarse en el puerto que especifique la variable de entorno `PORT`
- En modo desarrollo, Flask recargará automáticamente los cambios
- Los logs y errores se mostrarán en la consola

## 🆘 Solución de problemas

**Error de importación de Flask**:
```bash
pip install --upgrade Flask
```

**Puerto ocupado**:
```bash
export PORT=8000  # Usar otro puerto
```

**Problemas con el entorno virtual**:
```bash
deactivate
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

**Autor**: [Drakkrar](https://github.com/Drakkrar)

**Versión**: 1.0.0  

**Licencia**: Unlicense (Public Domain)
