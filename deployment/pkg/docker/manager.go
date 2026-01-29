package docker

import (
"fmt"
"os/exec"
"strings"

"github.com/sirupsen/logrus"
)

// Manager gestiona operaciones de Docker
type Manager struct {
logger *logrus.Logger
}

// NewManager crea un nuevo gestor de Docker
func NewManager(logger *logrus.Logger) *Manager {
return &Manager{logger: logger}
}

// PullImages descarga las imágenes más recientes
func (m *Manager) PullImages() error {
m.logger.Info("📦 Descargando imágenes de Docker...")

cmd := exec.Command("docker-compose", "pull")
output, err := cmd.CombinedOutput()
if err != nil {
m.logger.Errorf("❌ Error: %v\n%s", err, output)
return err
}

m.logger.Info("✅ Imágenes descargadas")
return nil
}

// RestartServices reinicia los servicios
func (m *Manager) RestartServices() error {
m.logger.Info("🔄 Reiniciando servicios...")

cmd := exec.Command("docker-compose", "up", "-d", "--force-recreate")
output, err := cmd.CombinedOutput()
if err != nil {
m.logger.Errorf("❌ Error: %v\n%s", err, output)
return err
}

m.logger.Info("✅ Servicios reiniciados")
return nil
}

// GetContainerStatus obtiene el estado de los contenedores
func (m *Manager) GetContainerStatus() (map[string]string, error) {
m.logger.Info("📊 Obteniendo estado de contenedores...")

cmd := exec.Command("docker", "ps", "--format", "{{.Names}}:{{.Status}}")
output, err := cmd.Output()
if err != nil {
return nil, err
}

status := make(map[string]string)
lines := strings.Split(string(output), "\n")

for _, line := range lines {
if line == "" {
continue
}
parts := strings.Split(line, ":")
if len(parts) == 2 {
status[parts[0]] = parts[1]
}
}

m.logger.Infof("✅ Estado obtenido: %d contenedores", len(status))
return status, nil
}

// CheckHealth verifica la salud de los contenedores
func (m *Manager) CheckHealth() error {
status, err := m.GetContainerStatus()
if err != nil {
return err
}

for name, state := range status {
if !strings.Contains(state, "Up") {
return fmt.Errorf("contenedor %s no está corriendo: %s", name, state)
}
m.logger.Infof("✅ %s: %s", name, state)
}

return nil
}
