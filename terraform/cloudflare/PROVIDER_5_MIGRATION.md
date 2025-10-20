# Cloudflare Provider 5.11.0 Migration Notes

## Overview

This document outlines the changes made to support Cloudflare Provider version 5.11.0 and the differences from earlier versions (4.x).

## Key Changes

### 1. Account ID Required

**Change**: Provider 5.x no longer supports looking up accounts by name via `data.cloudflare_accounts`.

**Solution**: You must provide the account ID directly as a variable.

```hcl
# Before (4.x)
data "cloudflare_accounts" "main" {
  name = var.cloudflare_account_name
}

locals {
  account_id = data.cloudflare_accounts.main.accounts[0].id
}

# After (5.x)
locals {
  account_id = var.cloudflare_account_id
}
```

**Action Required**: Add your Cloudflare account ID to `terraform.tfvars`:
```hcl
cloudflare_account_id = "your-account-id-here"
```

To find your account ID:
1. Log in to Cloudflare Dashboard
2. Go to any domain
3. Look in the URL: `dash.cloudflare.com/<account-id>/...`
4. Or check the right sidebar on the Overview page

### 2. Zone Data Source Filter Syntax

**Change**: The zone lookup requires a `filter` argument (not block).

```hcl
# Correct syntax for 5.x
data "cloudflare_zone" "zone" {
  filter = {
    name = var.cloudflare_zone_name
  }
}
```

### 3. Access Group Email Lists

**Change**: Email addresses in access groups must be expanded into separate include blocks.

**Solution**: Use for expressions to create one include block per email.

```hcl
# Correct syntax for 5.x
resource "cloudflare_zero_trust_access_group" "admins" {
  account_id = local.account_id
  name       = "Admins"

  include = [
    for email in var.admin_emails : {
      email = {
        email = email
      }
    }
  ]
}
```

### 4. DNS Records Resource Name

**Change**: `cloudflare_record` renamed to `cloudflare_dns_record`.

```hcl
# Before (4.x)
resource "cloudflare_record" "tunnel" {
  ...
}

# After (5.x)
resource "cloudflare_dns_record" "tunnel" {
  ...
  ttl = 1  # TTL is now required
}
```

### 5. CORS Configuration

**Status**: Not available in provider 5.11.0 for Zero Trust applications.

**Workaround**: Configure CORS settings manually via Cloudflare Dashboard:
1. Go to Zero Trust → Access → Applications
2. Select your application
3. Configure CORS in the application settings

### 6. Cloudflare Tunnel Changes

**Changes**:
- `secret` attribute is auto-generated (cannot be specified)
- Tunnel configuration (ingress rules) must be done via:
  - `cloudflared` CLI with `config.yml`
  - Cloudflare Dashboard
  - Not via Terraform in 5.11.0

**What Terraform Creates**:
- The tunnel itself
- DNS CNAME records pointing to the tunnel

**What You Must Configure Manually**:
- Tunnel secret/credentials (use `cloudflared tunnel token <tunnel-id>`)
- Ingress rules (in `config.yml` for cloudflared)

Example `config.yml`:
```yaml
tunnel: <tunnel-id-from-terraform-output>
credentials-file: /path/to/credentials.json

ingress:
  - hostname: argocd.integratn.tech
    service: http://localhost:8080
  - hostname: grafana.integratn.tech
    service: http://localhost:3000
  - service: http_status:404
```

### 7. DLP Profiles

**Status**: `cloudflare_zero_trust_dlp_profile` resource not available in provider 5.11.0.

**Workaround**: Configure DLP profiles manually via Cloudflare Dashboard.

## Variable Changes

### New Variables

- `cloudflare_account_id` (required) - Your Cloudflare account ID

### Removed Variables

- `cloudflare_account_name` - No longer used (replaced by account_id)

## Validation

To validate your configuration:

```bash
tofu init
tofu validate
tofu plan
```

## Deployment

```bash
# Initialize
tofu init -upgrade

# Review plan
tofu plan

# Apply
tofu apply

# Or use the deploy script
./deploy.sh
```

## Post-Deployment Steps

1. **Get Tunnel ID** (if using tunnel):
   ```bash
   tofu output tunnel_id
   ```

2. **Configure cloudflared**:
   ```bash
   # Get tunnel token
   cloudflared tunnel token <tunnel-id>
   
   # Create config.yml with your ingress rules
   # Start cloudflared
   cloudflared tunnel run
   ```

3. **Verify Access**:
   - Test application access
   - Check Zero Trust logs
   - Verify authentication flows

## Troubleshooting

### Error: "No declaration found for var.cloudflare_account_id"
**Solution**: Add `cloudflare_account_id` to your `terraform.tfvars` file.

### Error: "Unsupported attribute secret"
**Solution**: Remove the `secret` attribute from tunnel resources. It's auto-generated.

### Error: "Unsupported block type config"
**Solution**: Remove the `config` block from tunnel resources. Configure via cloudflared instead.

### CORS not working
**Solution**: Configure CORS manually in Cloudflare Dashboard under Zero Trust → Access → Applications.

## References

- [Cloudflare Provider Documentation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [Cloudflare Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [cloudflared Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)

## Support

For issues specific to this configuration, please check:
1. Terraform/OpenTofu version compatibility
2. Provider version is exactly `~> 5.11.0` in `versions.tf`
3. All required variables are set in `terraform.tfvars`
4. Account ID is correct
