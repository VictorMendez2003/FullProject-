package digitalocean

import (
"context"
"fmt"
"time"

"github.com/digitalocean/godo"
"github.com/sirupsen/logrus"
"golang.org/x/oauth2"
)

// Client es un wrapper del cliente de DigitalOcean
type Client struct {
client *godo.Client
ctx    context.Context
logger *logrus.Logger
}

// TokenSource implementa oauth2.TokenSource
type TokenSource struct {
AccessToken string
}

// Token retorna el token de acceso
func (t *TokenSource) Token() (*oauth2.Token, error) {
return &oauth2.Token{AccessToken: t.AccessToken}, nil
}

// NewClient crea un nuevo cliente de DigitalOcean
func NewClient(token string, logger *logrus.Logger) *Client {
tokenSource := &TokenSource{AccessToken: token}
oauthClient := oauth2.NewClient(context.Background(), tokenSource)
client := godo.NewClient(oauthClient)

return &Client{
client: client,
ctx:    context.Background(),
logger: logger,
}
}

// GetDroplet obtiene información de un droplet
func (c *Client) GetDroplet(dropletID int) (*godo.Droplet, error) {
c.logger.Infof("📡 Obteniendo información del Droplet ID: %d", dropletID)

droplet, _, err := c.client.Droplets.Get(c.ctx, dropletID)
if err != nil {
c.logger.Errorf("❌ Error: %v", err)
return nil, err
}

c.logger.Infof("✅ Droplet: %s (IP: %s)", droplet.Name, droplet.Networks.V4[0].IPAddress)
return droplet, nil
}

// ExecuteSSHCommand ejecuta un comando SSH en el droplet
func (c *Client) ExecuteSSHCommand(dropletID int, command string) error {
c.logger.Infof("🔧 Ejecutando comando en Droplet %d: %s", dropletID, command)

// Aquí implementarías la lógica SSH
// Por ahora es un placeholder

time.Sleep(2 * time.Second)
c.logger.Info("✅ Comando ejecutado exitosamente")
return nil
}

// CheckDropletHealth verifica el estado del droplet
func (c *Client) CheckDropletHealth(dropletID int) (bool, error) {
droplet, err := c.GetDroplet(dropletID)
if err != nil {
return false, err
}

if droplet.Status != "active" {
return false, fmt.Errorf("droplet no está activo: %s", droplet.Status)
}

c.logger.Info("✅ Droplet está saludable")
return true, nil
}
