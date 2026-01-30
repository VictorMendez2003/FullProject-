# 🚀 CallCenter AI - Sistema de Chatbot Institucional

Sistema completo de chatbot inteligente con arquitectura microservicios, CI/CD automatizado y monitoreo en tiempo real.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Arquitectura](#arquitectura)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Deployment Automático](#deployment-automático)
- [Monitoreo](#monitoreo)
- [Scripts Go](#scripts-go)
- [CI/CD](#cicd)

## ✨ Características

### Backend (FastAPI)
- 🤖 Chatbot inteligente con Groq AI (LLaMA 3.1)
- 🔐 Autenticación JWT con roles (SuperAdmin, Admin, Funcionario)
- 📊 Base de datos MySQL + MongoDB + Redis
- 🔍 RAG (Retrieval Augmented Generation) con ChromaDB
- ⚡ Rate limiting y seguridad avanzada
- 📝 Logging completo con rotación

### Frontend (React Native + Expo)
- 📱 Aplicación multiplataforma (Web, iOS, Android)
- 🎨 UI moderna y responsive
- 🔄 Gestión de estado con Context API
- 🌐 Conexión en tiempo real con backend

### DevOps
- 🐳 Containerización con Docker
- 🔄 CI/CD con GitHub Actions
- 🛠️ Scripts de deployment en Go
- 📊 Monitoreo con Prometheus + Grafana
- 📝 Logging con Loki + Promtail

## 🚀 Instalación Rápida
```bash
# 1. Clonar el repositorio
git clone https://github.com/Alexander200318/FullProject.git
cd FullProject

# 2. Configurar variables de entorno
cp Backend_Agente_Inteligente/.env.example Backend_Agente_Inteligente/.env

# 3. Iniciar todos los servicios
docker-compose up -d

# 4. Verificar estado
docker-compose ps
```

## 🛠️ Deployment Automático con Go

### Scripts Disponibles
```bash
cd deployment

# Deploy completo
./bin/deploy -droplet=YOUR_DROPLET_ID -token=YOUR_DO_TOKEN

# Health check
./bin/healthcheck -endpoint=http://64.23.152.92:8000/health
```

## 📊 Monitoreo
```bash
cd monitoring
docker-compose -f docker-compose.monitoring.yml up -d
```

**Dashboards:**
- Prometheus: http://64.23.152.92:9090
- Grafana: http://64.23.152.92:3001 (admin/admin123)

## 🔄 CI/CD

El proyecto incluye workflows de GitHub Actions para:
- Tests automáticos
- Build de imágenes Docker
- Deployment a DigitalOcean
- Health checks

## 🌐 URLs

- Backend: http://64.23.152.92:8000
- API Docs: http://64.23.152.92:8000/docs
- Frontend: http://64.23.152.92:3000

## 👥 Autores

- Alexander - [@Alexander200318](https://github.com/Alexander200318)
- Jhony Mendez - [@JhonyMendez](https://github.com/JhonyMendez)

# Test CI/CD

## ✅ CI/CD Totalmente Configurado
Sistema de deployment automático con GitHub Actions funcionando.
