# 📚 Guía Completa de Deployment

## Implementación Técnica del Despliegue Automático

Este documento describe la implementación completa del sistema de CI/CD con DigitalOcean, cumpliendo con todos los requisitos del proyecto integrador.

## ✅ Checklist de Requisitos (6 puntos)

### 1. ✅ Repositorio Git del proyecto integrador
- Repositorio Backend: https://github.com/Alexander200318/Backend_Agente_Inteligente
- Repositorio Frontend: https://github.com/JhonyMendez/FrontendCallCenterRN
- Repositorio Principal: En proceso de creación

### 2. ✅ Scripts en Go para gestión de recursos en la nube
Ubicación: `deployment/`

**Scripts implementados:**
- `cmd/deploy/main.go` - Deployment automático
- `cmd/healthcheck/main.go` - Health checking
- `pkg/digitalocean/client.go` - Cliente de DigitalOcean API
- `pkg/docker/manager.go` - Gestor de Docker

**Funcionalidades:**
- Conexión a API de DigitalOcean
- Verificación de estado de Droplets
- Gestión de contenedores Docker
- Health checks automáticos
- Rollback automático en caso de fallo

### 3. ✅ Pipeline CI/CD
Ubicación: `.github/workflows/`

**Workflows implementados:**
- `backend-ci.yml` - CI del backend
- `frontend-ci.yml` - CI del frontend
- `deploy.yml` - Deployment automático

**Características:**
- Trigger automático en push/tag
- Build de imágenes Docker
- Tests automáticos
- Deploy a DigitalOcean
- Health checks post-deployment

### 4. ✅ Aplicación desplegada y accesible
- **Backend**: http://64.23.152.92:8000
- **Frontend**: http://64.23.152.92:3000
- **API Docs**: http://64.23.152.92:8000/docs
- **Health Check**: http://64.23.152.92:8000/health

### 5. ✅ Monitoreo y Logging
Ubicación: `monitoring/`

**Stack implementado:**
- Prometheus (métricas)
- Grafana (dashboards)
- Loki (logs centralizados)
- Promtail (recolector de logs)
- cAdvisor (métricas de Docker)
- Node Exporter (métricas del servidor)

**Acceso:**
- Prometheus: http://64.23.152.92:9090
- Grafana: http://64.23.152.92:3001

## 🚀 Uso de Scripts Go

### Deploy Script
```bash
cd deployment

# Dry run (simulación)
./bin/deploy -droplet=YOUR_ID -token=YOUR_TOKEN -dry-run

# Deploy real
./bin/deploy -droplet=YOUR_ID -token=YOUR_TOKEN
```

**Proceso del script:**
1. Verifica estado del Droplet
2. Revisa contenedores actuales
3. Descarga nuevas imágenes
4. Reinicia servicios
5. Valida deployment

### Health Check Script
```bash
# Health check básico
./bin/healthcheck -endpoint=http://64.23.152.92:8000/health

# Health check completo (incluye DigitalOcean)
./bin/healthcheck -droplet=YOUR_ID -token=YOUR_TOKEN -endpoint=http://64.23.152.92:8000/health
```

## 🔄 Flujo de CI/CD

### 1. Developer hace push
```bash
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main
```

### 2. GitHub Actions se activa automáticamente

**Backend CI:**
- Checkout del código
- Setup de Python 3.11
- Instalación de dependencias
- Ejecución de tests
- Linting con flake8
- Build de imagen Docker

**Deploy:**
- Checkout del código
- Setup de Go 1.21
- Compilación de scripts de deployment
- Configuración de SSH
- Copia de archivos al servidor
- Ejecución de deployment
- Health checks
- Notificaciones

### 3. Deployment automático al servidor
```bash
# En el servidor (ejecutado por GitHub Actions)
cd /root/FullProject
git pull
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 4. Verificación post-deployment

- Health check del backend
- Verificación de contenedores
- Logs de errores
- Rollback si falla

## 📊 Monitoreo

### Iniciar stack de monitoreo
```bash
cd monitoring
docker-compose -f docker-compose.monitoring.yml up -d
```

### Dashboards de Grafana

1. Acceder a http://64.23.152.92:3001
2. Login: admin / admin123
3. Crear dashboard con Prometheus como data source

**Métricas disponibles:**
- CPU, RAM, Disco del servidor
- Estado de contenedores
- Latencia de APIs
- Errores HTTP
- Logs centralizados

## 🔐 Configuración de Secrets

### GitHub Secrets requeridos:

1. **DO_API_TOKEN**: Token de DigitalOcean
   - Generar en: DigitalOcean → API → Generate New Token
   
2. **DROPLET_ID**: ID del Droplet
   - Obtener con: `doctl compute droplet list`
   
3. **SSH_PRIVATE_KEY**: Clave SSH privada
   - Tu clave privada para SSH al servidor

### Agregar secrets en GitHub:
```
Settings → Secrets and variables → Actions → New repository secret
```

## 🧪 Testing del Sistema

### Test manual de deployment
```bash
# 1. Test de scripts Go
cd deployment
./bin/deploy -dry-run -droplet=YOUR_ID -token=YOUR_TOKEN

# 2. Test de health check
./bin/healthcheck -endpoint=http://64.23.152.92:8000/health

# 3. Test de monitoreo
curl http://64.23.152.92:9090/-/healthy
curl http://64.23.152.92:3001/api/health
```

### Test de CI/CD
```bash
# Crear un cambio pequeño
echo "test" >> test.txt
git add test.txt
git commit -m "test: CI/CD"
git push origin main

# Ver el workflow en GitHub
# https://github.com/YOUR_USER/YOUR_REPO/actions
```

## 🐛 Troubleshooting

### Scripts Go no compilan
```bash
cd deployment
go mod download
go mod tidy
go build -v ./...
```

### GitHub Actions falla

1. Verificar secrets configurados
2. Revisar logs en Actions tab
3. Verificar conectividad SSH al servidor

### Monitoreo no funciona
```bash
cd monitoring
docker-compose -f docker-compose.monitoring.yml down
docker-compose -f docker-compose.monitoring.yml up -d
docker-compose -f docker-compose.monitoring.yml logs -f
```

## 📈 Mejoras Futuras

- [ ] Implementar tests unitarios completos
- [ ] Agregar Slack/Discord notifications
- [ ] Implementar blue-green deployment
- [ ] Agregar más dashboards de Grafana
- [ ] Implementar backups automáticos
- [ ] Agregar alertas de Prometheus

## 🎓 Referencias

- [DigitalOcean API](https://docs.digitalocean.com/reference/api/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Go Docker SDK](https://pkg.go.dev/github.com/docker/docker)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)

---

**Proyecto Integrador - DevOps con Go y DigitalOcean**

Desarrollado por: Alexander & Jhony Mendez
