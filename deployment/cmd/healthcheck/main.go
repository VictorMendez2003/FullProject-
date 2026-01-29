package main

import (
"flag"
"fmt"
"net/http"
"os"
"time"

"github.com/Alexander200318/fullproject-deployment/pkg/digitalocean"
"github.com/Alexander200318/fullproject-deployment/pkg/docker"
"github.com/joho/godotenv"
"github.com/sirupsen/logrus"
)

var (
dropletID = flag.Int("droplet", 0, "ID del Droplet")
token     = flag.String("token", "", "Token de API")
endpoint  = flag.String("endpoint", "http://localhost:8000/health", "Endpoint de health check")
)

func main() {
flag.Parse()

logger := logrus.New()
logger.SetFormatter(&logrus.TextFormatter{
FullTimestamp: true,
ForceColors:   true,
})

logger.Info("🏥 Health Check Iniciado")

// Cargar .env
godotenv.Load()

// Obtener token
apiToken := *token
if apiToken == "" {
apiToken = os.Getenv("DO_API_TOKEN")
}

// Health Check del Backend
logger.Info("🔍 Verificando Backend API...")
resp, err := http.Get(*endpoint)
if err != nil {
logger.Errorf("❌ Backend no responde: %v", err)
} else if resp.StatusCode != 200 {
logger.Errorf("❌ Backend retornó status: %d", resp.StatusCode)
} else {
logger.Info("✅ Backend saludable")
}

// Health Check de Docker
logger.Info("🐳 Verificando contenedores Docker...")
dockerManager := docker.NewManager(logger)
if err := dockerManager.CheckHealth(); err != nil {
logger.Errorf("❌ Contenedores con problemas: %v", err)
} else {
logger.Info("✅ Todos los contenedores saludables")
}

// Health Check de DigitalOcean (si se proporciona token y droplet)
if apiToken != "" && *dropletID != 0 {
logger.Info("☁️  Verificando Droplet...")
doClient := digitalocean.NewClient(apiToken, logger)
if healthy, err := doClient.CheckDropletHealth(*dropletID); err != nil || !healthy {
logger.Errorf("❌ Droplet con problemas: %v", err)
} else {
logger.Info("✅ Droplet saludable")
}
}

logger.Info(fmt.Sprintf("⏱️  Health check completado: %s", time.Now().Format("2006-01-02 15:04:05")))
}
