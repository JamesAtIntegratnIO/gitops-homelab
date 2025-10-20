# Cloudflare Zero Trust - Quick Reference

## 🚀 Quick Setup

```bash
# 1. Copy and configure
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Deploy
./deploy.sh
```

## 📋 Common Commands

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Destroy (careful!)
terraform destroy

# Show current state
terraform show

# List resources
terraform state list
```

## 🔑 Key Configuration

### Minimum Required
```hcl
cloudflare_api_token    = "your-token"
cloudflare_account_name = "Account Name"
auth_domain_prefix      = "homelab"
admin_emails            = ["admin@example.com"]
enable_otp              = true
```

### Add Application
```hcl
custom_applications = {
  "app" = {
    name   = "My App"
    domain = "app.example.com"
  }
}
```

### Add User
```hcl
admin_emails = [
  "existing@example.com",
  "new@example.com"  # Add here
]
```

## 🔐 Access Policies

### Who Can Access What

| Service | Admin | Developer | Family |
|---------|-------|-----------|--------|
| ArgoCD | ✓ | ✗ | ✗ |
| Grafana | ✓ | ✓* | ✗ |
| Proxmox | ✓ | ✗ | ✗ |
| Media | ✓ | ✓ | ✓* |

*Optional - configure in `custom_applications`

## 🌐 Cloudflare Tunnel

### Generate Secret
```bash
openssl rand -base64 32
```

### Install cloudflared
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```

### Config (`/etc/cloudflared/config.yml`)
```yaml
tunnel: <tunnel-id>
credentials-file: /etc/cloudflared/credentials.json

ingress:
  - hostname: app.example.com
    service: https://10.0.5.200:443
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```

### Start Service
```bash
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl status cloudflared
```

## 🐛 Troubleshooting

### Access Denied
1. Check email in group
2. Verify identity provider
3. Review access logs
4. Check policy order

### Tunnel Issues
```bash
# Check status
sudo systemctl status cloudflared

# View logs
sudo journalctl -u cloudflared -f

# Restart
sudo systemctl restart cloudflared
```

### DNS Not Working
```bash
# Check DNS
dig app.example.com

# Verify in Cloudflare
# Dashboard → DNS → Records
```

## 📊 Monitoring

### Cloudflare Dashboard
- **Applications**: Zero Trust → Access → Applications
- **Groups**: Zero Trust → Access → Access Groups  
- **Logs**: Zero Trust → Logs → Access
- **Tunnels**: Zero Trust → Networks → Tunnels

### Check Terraform State
```bash
terraform state list
terraform state show cloudflare_zero_trust_access_application.argocd
```

## 🔄 Common Tasks

### Add New Service
1. Add to `terraform.tfvars`:
   ```hcl
   custom_applications = {
     "new-app" = {
       name = "New App"
       domain = "new.example.com"
     }
   }
   ```
2. `terraform apply`
3. Test access

### Update User Email
1. Edit `terraform.tfvars`
2. `terraform apply`
3. User will receive access on next login

### Rotate Credentials
1. Update in provider (GitHub/Google)
2. Update `terraform.tfvars`
3. `terraform apply`

## 🎯 Best Practices

✓ **Use MFA** - Enable on identity provider
✓ **Least Privilege** - Only grant necessary access
✓ **Session Timeout** - Keep sessions short (8-24h)
✓ **Monitor Logs** - Review access attempts regularly
✓ **IP Whitelist** - Combine with IP restrictions when possible
✓ **Test Changes** - Always review `terraform plan` before applying

## 📚 Useful Links

- [Cloudflare Dashboard](https://dash.cloudflare.com/)
- [Zero Trust Docs](https://developers.cloudflare.com/cloudflare-one/)
- [Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Terraform Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)

## 🆘 Getting Help

1. Check README.md for detailed documentation
2. Review Terraform error messages
3. Check Cloudflare status page
4. Consult Cloudflare documentation
5. Review access logs in dashboard

---

**Security Note**: Never commit `terraform.tfvars` or tunnel credentials to git!
