package main

import (
"flag"
"fmt"
"os"
"time"

"github.com/Alexander200318/fullproject-deployment/pkg/digitalocean"
"github.com/Alexander200318/fullproject-deployment/pkg/docker"
"github.com/joho/godotenv"
"github.com/sirupsen/logrus"
)

var (
dropletID = flag.Int("droplet", 0, "ID del Droplet de DigitalOcean")
token     = flag.String("token", "", "Token de API de DigitalOcean")
dryRun    = flag.Bool("dry-run", false, "Simular deployment sin ejecutar")
)

func main() {
flag.Parse()

// Configurar logger
logger := logrus.New()
logger.SetFormatter(&logrus.TextFormatter{
FullTimestamp: true,
ForceColors:   true,
})

logger.Info("🚀 Iniciando proceso de deployment automático")
logger.Info("=" + string(make([]byte, 60)))

// Cargar variables de entorno
if err := godotenv.Load(); err != nil {
logger.Warn("⚠️  No se encontró archivo .env, usando variables de sistema")
}

// Obtener token
apiToken := *token
if apiToken == "" {
apiToken = os.Getenv("DO_API_TOKEN")
}
if apiToken == "" {
logger.Fatal("❌ Token de DigitalOcean no proporcionado")
}

// Obtener Droplet ID
dropletIDValue := *dropletID
if dropletIDValue == 0 {
logger.Fatal("❌ Droplet ID no proporcionado")
}

if *dryRun {
logger.Info("🔍 Modo DRY-RUN activado - No se ejecutarán cambios reales")
}

// Crear clientes
doClient := digitalocean.NewClient(apiToken, logger)
dockerManager := docker.NewManager(logger)

// Paso 1: Verificar estado del Droplet
logger.Info("\n📡 PASO 1: Verificando estado del Droplet")
healthy, err := doClient.CheckDropletHealth(dropletIDValue)
if err != nil {
logger.Fatalf("❌ Error verificando Droplet: %v", err)
}
if !healthy {
logger.Fatal("❌ Droplet no está saludable")
}

// Paso 2: Verificar estado de contenedores
logger.Info("\n🐳 PASO 2: Verificando contenedores actuales")
if err := dockerManager.CheckHealth(); err != nil {
logger.Warnf("⚠️  Advertencia: %v", err)
}

if *dryRun {
logger.Info("\n✅ DRY-RUN completado - No se realizaron cambios")
return
}

// Paso 3: Pull de nuevas imágenes
logger.Info("\n📦 PASO 3: Descargando nuevas imágenes")
if err := dockerManager.PullImages(); err != nil {
logger.Fatalf("❌ Error descargando imágenes: %v", err)
}

// Paso 4: Reiniciar servicios
logger.Info("\n🔄 PASO 4: Reiniciando servicios")
if err := dockerManager.RestartServices(); err != nil {
logger.Fatalf("❌ Error reiniciando servicios: %v", err)
}

// Paso 5: Verificar deployment
logger.Info("\n✅ PASO 5: Verificando deployment")
time.Sleep(10 * time.Second) // Esperar a que los servicios inicien

if err := dockerManager.CheckHealth(); err != nil {
logger.Errorf("❌ Deployment falló: %v", err)
logger.Info("🔙 Intentando rollback...")
// Aquí podrías implementar lógica de rollback
os.Exit(1)
}

logger.Info("\n" + string(make([]byte, 60)))
logger.Info("✅ DEPLOYMENT COMPLETADO EXITOSAMENTE")
logger.Info(fmt.Sprintf("⏱️  Tiempo total: %v", time.Now().Format("15:04:05")))
}
