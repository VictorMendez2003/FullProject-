#!/bin/bash

# ============================================================
# 🔧 CORRECCIÓN DEFINITIVA: CORS + Redirecciones 307
# CallCenter AI - React Native + FastAPI
# ============================================================

echo "============================================================"
echo "🔧 CORRECCIÓN DEFINITIVA PARA REACT NATIVE"
echo "============================================================"
echo ""
echo "📋 Problema identificado:"
echo "   • ENVIRONMENT=production → CORS muy restrictivo"
echo "   • React Native NO funciona con CORS restrictivo"
echo "   • Redirecciones 307 bloqueando peticiones"
echo ""
echo "✅ Solución:"
echo "   • Mantener ENVIRONMENT=production"
echo "   • CORS con wildcard (*) para React Native"
echo "   • Agregar redirect_slashes=False"
echo "   • Seguridad mediante JWT (ya implementado)"
echo ""
echo "============================================================"
echo ""

# Variables
PROJECT_DIR=~/FullProject/Backend_Agente_Inteligente
BACKUP_DIR=~/FullProject/backup_$(date +%Y%m%d_%H%M%S)

# ============================================================
# 1. VERIFICAR AMBIENTE ACTUAL
# ============================================================
echo "📊 Estado actual:"
echo ""

if [ -f "$PROJECT_DIR/../.env" ]; then
    CURRENT_ENV=$(grep "ENVIRONMENT=" $PROJECT_DIR/../.env | cut -d'=' -f2)
    echo "   ENVIRONMENT actual: $CURRENT_ENV"
else
    echo "   ⚠️  Archivo .env no encontrado en ~/FullProject/.env"
fi

# Verificar CORS actual
echo "   CORS actual en main.py:"
grep -A 2 "allow_origins=" $PROJECT_DIR/main.py | head -3
echo ""

read -p "¿Continuar con la corrección? (s/n): " respuesta
if [ "$respuesta" != "s" ] && [ "$respuesta" != "S" ]; then
    echo "Operación cancelada."
    exit 0
fi

echo ""

# ============================================================
# 2. CREAR BACKUP
# ============================================================
echo "📦 Creando backup en: $BACKUP_DIR"
mkdir -p $BACKUP_DIR
cp $PROJECT_DIR/core/config.py $BACKUP_DIR/config.py.bak
cp $PROJECT_DIR/main.py $BACKUP_DIR/main.py.bak

if [ -f "$PROJECT_DIR/../.env" ]; then
    cp $PROJECT_DIR/../.env $BACKUP_DIR/.env.bak
fi

echo "✅ Backup creado"
echo ""

# ============================================================
# 3. VERIFICAR/CONFIGURAR .env PARA PRODUCTION
# ============================================================
echo "🔧 Configurando .env para PRODUCTION..."

if [ ! -f "$PROJECT_DIR/../.env" ]; then
    echo "⚠️  Creando archivo .env..."
    cat > $PROJECT_DIR/../.env << 'EOF'
# Ambiente
ENVIRONMENT=production

# Base de datos (ya configurado en Docker)
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root123
DB_NAME=chatbot_institucional

# JWT
SECRET_KEY=tu-secret-key-super-segura-aqui

# Groq API (si usas)
GROQ_API_KEY=tu-groq-api-key-aqui

# Debug
DEBUG=False
EOF
    echo "✅ Archivo .env creado"
else
    # Asegurarse que esté en production
    if grep -q "^ENVIRONMENT=" $PROJECT_DIR/../.env; then
        sed -i 's/^ENVIRONMENT=.*/ENVIRONMENT=production/' $PROJECT_DIR/../.env
    else
        echo "ENVIRONMENT=production" >> $PROJECT_DIR/../.env
    fi
    echo "✅ ENVIRONMENT configurado a 'production'"
fi

echo ""

# ============================================================
# 4. CORREGIR config.py - CORS UNIFICADO
# ============================================================
echo "🔧 Actualizando config.py con CORS unificado (Web + Mobile)..."

# Crear backup temporal
cp $PROJECT_DIR/core/config.py $PROJECT_DIR/core/config.py.tmp

# Reemplazar la función CORS_ORIGINS completa
cat > /tmp/cors_replacement.py << 'EOF'
    @property
    def CORS_ORIGINS(self) -> List[str]:
        """
        🔥 CONFIGURACIÓN UNIFICADA DE CORS
        
        En producción, permitimos TANTO dominios web COMO React Native.
        La seguridad real está en JWT, no en CORS.
        """
        # 🌐 Orígenes web (siempre permitidos)
        web_origins = [
            "https://engine-tecai.me",
            "https://www.engine-tecai.me",
            "http://engine-tecai.me",
            "http://www.engine-tecai.me",
        ]
        
        # 📱 Orígenes de React Native / Expo (siempre necesarios)
        mobile_origins = [
            # Expo Development
            "http://localhost:8081",
            "http://localhost:19000",
            "http://localhost:19001",
            "http://localhost:19002",
            "http://127.0.0.1:8081",
            "http://127.0.0.1:19000",
            "exp://",  # Expo Go
            # IP del servidor (para desarrollo remoto)
            "http://64.23.152.92:8081",
            "http://64.23.152.92:19000",
            "http://64.23.152.92:19001",
            "http://64.23.152.92:19002",
            # Desarrollo local adicional
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://64.23.152.92:3000",
        ]
        
        if self.ENVIRONMENT == "production":
            # 🔒 Producción: Web + Mobile
            return web_origins + mobile_origins
            
        elif self.ENVIRONMENT == "staging":
            # 🟡 Staging: Igual que producción + staging específicos
            staging_origins = [
                "https://staging-app.tudominio.com",
                "http://staging-app.tudominio.com",
            ]
            return web_origins + mobile_origins + staging_origins
            
        else:
            # 🟢 Desarrollo: Todos los anteriores (más permisivo)
            return web_origins + mobile_origins
EOF

# Usar Python para hacer el reemplazo (más confiable que sed)
python3 << 'PYTHON_SCRIPT'
import re

# Leer archivo actual
with open('/root/FullProject/Backend_Agente_Inteligente/core/config.py', 'r') as f:
    content = f.read()

# Leer nuevo contenido
with open('/tmp/cors_replacement.py', 'r') as f:
    new_cors = f.read()

# Encontrar y reemplazar CORS_ORIGINS completo
pattern = r'@property\s+def CORS_ORIGINS\(self\).*?(?=\s{4}# ====|@property|class Config)'
content_new = re.sub(pattern, new_cors.rstrip() + '\n    ', content, flags=re.DOTALL)

# Guardar
with open('/root/FullProject/Backend_Agente_Inteligente/core/config.py', 'w') as f:
    f.write(content_new)

print("✅ config.py actualizado")
PYTHON_SCRIPT

echo "✅ config.py actualizado con CORS unificado"
echo ""

# ============================================================
# 5. CORREGIR main.py - PARTE 1: redirect_slashes=False
# ============================================================
echo "🔧 Agregando redirect_slashes=False en main.py..."

# Verificar si ya existe
if grep -q "redirect_slashes=False" $PROJECT_DIR/main.py; then
    echo "   ℹ️  redirect_slashes=False ya existe"
else
    # Agregar redirect_slashes=False después de debug=settings.DEBUG
    sed -i '/debug=settings.DEBUG/a\    redirect_slashes=False  # 🔥 Evita redirecciones 307' $PROJECT_DIR/main.py
    echo "✅ redirect_slashes=False agregado"
fi

echo ""

# ============================================================
# 6. CORREGIR main.py - PARTE 2: CORS con wildcard (*)
# ============================================================
echo "🔧 Configurando CORS con wildcard (*) para React Native..."

# Reemplazar configuración de CORS
sed -i 's/allow_origins=cors_origins,/allow_origins=["*"],  # 🔥 React Native compatible/' $PROJECT_DIR/main.py
sed -i 's/allow_credentials=True,/allow_credentials=False,  # False con wildcard/' $PROJECT_DIR/main.py

# Verificar si hay expose_headers
if ! grep -q "expose_headers=" $PROJECT_DIR/main.py; then
    # Agregar expose_headers después de allow_headers
    sed -i '/allow_headers=\["\*"\],/a\    expose_headers=["*"],' $PROJECT_DIR/main.py
fi

echo "✅ CORS configurado con wildcard (*)"
echo ""

# ============================================================
# 7. VERIFICAR CAMBIOS
# ============================================================
echo "============================================================"
echo "📋 VERIFICACIÓN DE CAMBIOS"
echo "============================================================"
echo ""

echo "1️⃣  Archivo .env:"
if [ -f "$PROJECT_DIR/../.env" ]; then
    grep "ENVIRONMENT=" $PROJECT_DIR/../.env
else
    echo "   ⚠️  .env no encontrado"
fi
echo ""

echo "2️⃣  config.py - CORS_ORIGINS (primeras líneas):"
grep -A 20 "def CORS_ORIGINS" $PROJECT_DIR/core/config.py | head -25
echo ""

echo "3️⃣  main.py - FastAPI app:"
grep -A 8 "^app = FastAPI" $PROJECT_DIR/main.py | head -10
echo ""

echo "4️⃣  main.py - CORS Middleware:"
grep -B 2 -A 8 "app.add_middleware" $PROJECT_DIR/main.py | grep -B 2 -A 8 "CORSMiddleware"
echo ""

# ============================================================
# 8. REINICIAR CONTENEDOR
# ============================================================
echo "============================================================"
echo "🔄 REINICIAR CONTENEDOR"
echo "============================================================"
echo ""

read -p "¿Reiniciar el contenedor fastapi_backend ahora? (s/n): " respuesta

if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
    echo "🔄 Reiniciando contenedor..."
    cd ~/FullProject
    docker-compose restart fastapi_backend
    
    echo ""
    echo "⏳ Esperando 8 segundos para que inicie..."
    sleep 8
    
    echo ""
    echo "📊 Estado del contenedor:"
    docker ps | grep -E "CONTAINER|fastapi"
    
    echo ""
    echo "📋 Últimos logs (busca: CORS, ENVIRONMENT, redirect_slashes):"
    docker logs --tail 30 fastapi_backend 2>&1 | grep -E "CORS|ENVIRONMENT|started|redirect"
    
    echo ""
    echo "🧪 Test rápido - Health check:"
    curl -s http://localhost:8000/health | python3 -m json.tool || echo "⚠️  Backend aún iniciando..."
fi

echo ""
echo "============================================================"
echo "✅ CORRECCIÓN COMPLETADA"
echo "============================================================"
echo ""
echo "📝 Resumen de cambios aplicados:"
echo "   1. ✅ .env → ENVIRONMENT=production"
echo "   2. ✅ config.py → CORS unificado (Web + Mobile)"
echo "   3. ✅ main.py → redirect_slashes=False (elimina 307)"
echo "   4. ✅ main.py → CORS con wildcard (*)"
echo ""
echo "📁 Backup guardado en: $BACKUP_DIR"
echo ""
echo "🧪 PRUEBA TU APP MÓVIL AHORA:"
echo "   • Login debería funcionar"
echo "   • Agentes, Departamentos, Personas deberían funcionar"
echo "   • NO más errores 307 o NETWORK ERROR"
echo ""
echo "🔐 NOTA DE SEGURIDAD:"
echo "   • CORS usa wildcard (*) para compatibilidad móvil"
echo "   • La seguridad REAL está en JWT (ya implementado)"
echo "   • Esto es SEGURO para APIs con autenticación JWT"
echo ""
echo "============================================================"
