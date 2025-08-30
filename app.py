from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    """Página principal"""
    return render_template('index.html', 
                         message="¡Hola desde Flask en Azure!",
                         timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

@app.route('/health')
def health_check():
    """Endpoint de salud para monitoreo"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    })

@app.route('/api/info')
def app_info():
    """Información de la aplicación"""
    return jsonify({
        "app_name": "Mi Primer PaaS",
        "description": "Aplicación Flask básica para práctica de despliegue en Azure",
        "environment": os.getenv('FLASK_ENV', 'production'),
        "python_version": "3.9+",
        "framework": "Flask"
    })

@app.route('/test')
def test():
    """Endpoint de prueba"""
    return jsonify({
        "message": "Test endpoint funcionando correctamente",
        "status": "success",
        "timestamp": datetime.now().isoformat()
    })

if __name__ == '__main__':
    # Para desarrollo local
    port = int(os.environ.get('PORT', 5000))
    debug = os.getenv('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)
