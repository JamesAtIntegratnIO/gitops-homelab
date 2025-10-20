# Cloudflare Zero Trust Setup

This directory contains Terraform configuration for deploying **Cloudflare Zero Trust** (formerly Cloudflare Access) to secure access to your homelab services.

## 🎯 Overview

Cloudflare Zero Trust provides:
- **Identity-Aware Proxy**: Authenticate users before they reach your applications
- **Zero Trust Network Access**: Never trust, always verify
- **Cloudflare Tunnel**: Secure inbound connections without exposing ports
- **Multi-Factor Authentication**: Integration with various identity providers
- **Granular Access Control**: Policy-based access management
- **Audit Logging**: Complete visibility into access attempts

## 🏗️ Architecture

```
Internet Users
      ↓
Cloudflare Edge (Identity Check)
      ↓
Access Policies (Group/Email/IP)
      ↓
Cloudflare Tunnel (Optional)
      ↓
Your Homelab Services
```

### Components Deployed

1. **Access Organization**: Central configuration for your Zero Trust setup
2. **Identity Providers**: GitHub, Google OAuth, or One-Time PIN
3. **Access Groups**: Admin, Developer, Family, Internal Network
4. **Applications**: Protected services (ArgoCD, Grafana, Proxmox, etc.)
5. **Access Policies**: Who can access what
6. **Cloudflare Tunnel**: Secure inbound connectivity (optional)
7. **Device Posture**: Device compliance checks (optional)
8. **DLP Profiles**: Data Loss Prevention (optional)

## 🚀 Quick Start

### 1. Prerequisites

- Cloudflare account with a domain
- Cloudflare API token with permissions:
  - Account.Cloudflare Tunnel (Edit)
  - Account.Access: Apps and Policies (Edit)
  - Account.Access: Organizations, Identity Providers, and Groups (Edit)
  - Zone.DNS (Edit)

### 2. Create API Token

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/) → My Profile → API Tokens
2. Create Token → Use Custom Token Template
3. Add permissions listed above
4. Save the token securely

### 3. Configure Variables

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 4. Deploy

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply configuration
terraform apply
```

## ⚙️ Configuration Guide

### Basic Setup

Minimum required configuration in `terraform.tfvars`:

```hcl
cloudflare_api_token    = "your-api-token"
cloudflare_account_name = "Your Account Name"
cloudflare_zone_name    = "example.com"
auth_domain_prefix      = "homelab"

admin_emails = [
  "admin@example.com"
]

enable_otp = true  # Email-based OTP authentication
```

### Identity Providers

Configure one or more authentication methods for your users.

#### One-Time PIN (Email)
Simplest option - no setup required:
```hcl
enable_otp = true
```

#### GitHub OAuth
1. Create OAuth App in GitHub Settings → Developer → OAuth Apps
2. Set callback URL: `https://<auth_domain>.cloudflareaccess.com/cdn-cgi/access/callback`
3. Configure:
```hcl
enable_github_sso    = true
github_client_id     = "your-client-id"
github_client_secret = "your-client-secret"
```

#### Google OAuth
1. Create OAuth credentials in Google Cloud Console
2. Add authorized redirect URI: `https://<auth_domain>.cloudflareaccess.com/cdn-cgi/access/callback`
3. Configure:
```hcl
enable_google_sso    = true
google_client_id     = "your-client-id"
google_client_secret = "your-client-secret"
```

### Access Groups

#### Admin Group
Full access to all protected applications:
```hcl
admin_emails = [
  "admin@example.com",
  "owner@example.com"
]
```

#### Developer Group (Optional)
Access to development tools:
```hcl
enable_developer_group = true
developer_emails = [
  "dev@example.com"
]
```

#### Family Group (Optional)
Limited access for family members (media, etc.):
```hcl
enable_family_group = true
family_emails = [
  "family@example.com"
]
```

#### Internal Network Group (Optional)
Bypass authentication from trusted IPs:
```hcl
enable_internal_network_group = true
internal_network_cidrs = [
  "10.0.0.0/8",
  "192.168.1.0/24"
]
```

### Protected Applications

#### Built-in Applications

**ArgoCD**:
```hcl
enable_argocd_access = true
argocd_domain       = "argocd.example.com"
```

**Grafana**:
```hcl
enable_grafana_access = true
grafana_domain       = "grafana.example.com"
```

**Proxmox**:
```hcl
enable_proxmox_access = true
proxmox_domain       = "proxmox.example.com"
```

#### Custom Applications

```hcl
custom_applications = {
  "portainer" = {
    name             = "Portainer"
    domain           = "portainer.example.com"
    enable_cors      = true
    allow_developers = true
  },
  "plex" = {
    name         = "Plex"
    domain       = "plex.example.com"
    allow_family = true
  },
  "home-assistant" = {
    name         = "Home Assistant"
    domain       = "ha.example.com"
    auto_redirect = true
    allow_family  = true
  }
}
```

### Cloudflare Tunnel

Cloudflare Tunnel creates secure outbound-only connections to Cloudflare's edge, eliminating the need to open inbound firewall ports.

#### Setup

1. **Generate tunnel secret**:
```bash
openssl rand -base64 32
```

2. **Configure tunnel**:
```hcl
enable_tunnel = true
tunnel_name   = "homelab-tunnel"
tunnel_secret = "your-base64-secret"

tunnel_ingress_rules = [
  {
    hostname      = "argocd.example.com"
    service       = "https://10.0.5.200:443"
    no_tls_verify = true
  },
  {
    hostname = "grafana.example.com"
    service  = "http://10.0.5.200:3000"
  }
]
```

3. **Install cloudflared on your server**:
```bash
# Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Create tunnel config
sudo mkdir -p /etc/cloudflared
sudo nano /etc/cloudflared/config.yml
```

4. **Tunnel configuration file** (`/etc/cloudflared/config.yml`):
```yaml
tunnel: <tunnel-id-from-terraform-output>
credentials-file: /etc/cloudflared/credentials.json

ingress:
  - hostname: argocd.example.com
    service: https://10.0.5.200:443
    originRequest:
      noTLSVerify: true
  - hostname: grafana.example.com
    service: http://10.0.5.200:3000
  - service: http_status:404
```

5. **Create credentials file** (`/etc/cloudflared/credentials.json`):
```json
{
  "AccountTag": "<account-id>",
  "TunnelSecret": "<base64-secret>",
  "TunnelID": "<tunnel-id>"
}
```

6. **Start tunnel service**:
```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
sudo systemctl status cloudflared
```

## 🔒 Security Best Practices

### Session Duration
Configure appropriate session timeouts:
```hcl
session_duration = "24h"  # or "8h", "12h", etc.
```

### Multi-Factor Authentication
Always enable MFA with your identity provider (GitHub, Google).

### Group-Based Access
Use the principle of least privilege:
- **Admins**: Full access to infrastructure
- **Developers**: Development tools only
- **Family**: Media services only

### IP Whitelisting
For highly sensitive services, combine authentication with IP restrictions:
```hcl
# In your custom policy configuration
include {
  group = [cloudflare_zero_trust_access_group.admins.id]
}
include {
  ip = ["your.home.ip.address/32"]
}
```

### Audit Logs
Monitor access logs in Cloudflare Dashboard:
- Access → Access Logs
- Review authentication attempts
- Set up alerts for suspicious activity

## 📊 Monitoring and Management

### Terraform Outputs

After applying, get important information:
```bash
terraform output auth_domain
terraform output tunnel_id
terraform output admin_group_id
terraform output application_domains
```

### Cloudflare Dashboard

Access your Zero Trust configuration:
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your account
3. Navigate to **Zero Trust**

Key sections:
- **Access → Applications**: View protected apps
- **Access → Access Groups**: Manage user groups
- **Access → Service Auth**: Service-to-service authentication
- **Access → Logs**: Audit trail
- **Networks → Tunnels**: Manage Cloudflare Tunnels

## 🔧 Operations

### Adding New Applications

1. Add to `terraform.tfvars`:
```hcl
custom_applications = {
  "newapp" = {
    name   = "New Application"
    domain = "newapp.example.com"
  }
}
```

2. Apply changes:
```bash
terraform apply
```

### Adding Users

1. Update group emails in `terraform.tfvars`:
```hcl
admin_emails = [
  "admin@example.com",
  "newadmin@example.com"  # New user
]
```

2. Apply:
```bash
terraform apply
```

### Rotating Credentials

**Tunnel Secret**:
```bash
# Generate new secret
NEW_SECRET=$(openssl rand -base64 32)

# Update terraform.tfvars
# Apply changes
terraform apply

# Update cloudflared credentials on server
```

**Identity Provider Credentials**:
1. Rotate in provider (GitHub, Google)
2. Update `terraform.tfvars`
3. Apply changes

## 🐛 Troubleshooting

### Common Issues

#### "Access Denied" Errors
1. Check user email is in appropriate group
2. Verify identity provider is working
3. Check access policy precedence
4. Review audit logs in Cloudflare Dashboard

#### Tunnel Not Connecting
```bash
# Check cloudflared status
sudo systemctl status cloudflared

# View logs
sudo journalctl -u cloudflared -f

# Verify tunnel ID and secret
cat /etc/cloudflared/config.yml
cat /etc/cloudflared/credentials.json
```

#### DNS Not Resolving
1. Verify DNS records created by Terraform
2. Check Cloudflare proxy status (orange cloud)
3. Wait for DNS propagation (up to 5 minutes)

#### Infinite Redirect Loops
1. Ensure application doesn't have its own authentication
2. Check CORS settings for web apps
3. Verify `auto_redirect_to_identity = true`

### Debug Commands

```bash
# Test DNS resolution
dig argocd.example.com

# Test connectivity
curl -I https://argocd.example.com

# Check tunnel connectivity
cloudflared tunnel info <tunnel-id>

# View terraform state
terraform show
terraform state list
```

## 📚 Additional Resources

### Documentation in This Directory
- **[PROVIDER_5_MIGRATION.md](./PROVIDER_5_MIGRATION.md)** - Migration guide for Cloudflare Provider 5.x
- **[QUICK_START.md](./QUICK_START.md)** - Quick reference for common operations (if exists)

### External Resources
- [Cloudflare Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Terraform Cloudflare Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [Zero Trust Best Practices](https://www.cloudflare.com/learning/security/glossary/what-is-zero-trust/)

## 🎯 Example Use Cases

### Home Lab Access
- Secure remote access to lab services
- No VPN required
- Identity-based authentication

### Family Media Server
- Share Plex/Jellyfin with family
- Separate access controls
- No complex firewall rules

### Development Environment
- Secure access to dev tools
- Team collaboration
- Audit logging

### IoT and Smart Home
- Protect Home Assistant, ESPHome
- Secure camera feeds
- Family-safe access

---

**Note**: Always test changes in a non-production environment first. Cloudflare Zero Trust free tier includes 50 users, which is more than sufficient for most homelabs.
