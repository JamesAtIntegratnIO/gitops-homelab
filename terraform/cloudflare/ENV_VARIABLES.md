# Environment Variables Reference

## Overview

The `secrets.env` file in the repository root contains all sensitive credentials needed for Terraform deployments. These are exported as environment variables and automatically picked up by Terraform.

## File Location

```
/home/boboysdadda/projects/gitops-homelab/secrets.env
```

## Usage

### Load Environment Variables

```bash
# Source the secrets file before running Terraform
source secrets.env

# Or for OpenTofu
source secrets.env && tofu apply
```

### Verify Variables Are Set

```bash
# Check if Cloudflare token is set
echo $TF_VAR_cloudflare_api_token

# List all TF_VAR_ environment variables
env | grep TF_VAR_
```

## Cloudflare Zero Trust Variables

### Required Variables

#### `TF_VAR_cloudflare_api_token`
- **Description**: Cloudflare API token with proper permissions
- **Required**: Yes
- **Get from**: https://dash.cloudflare.com/profile/api-tokens
- **Permissions needed**:
  - Account.Cloudflare Tunnel (Edit)
  - Account.Access: Apps and Policies (Edit)
  - Account.Access: Organizations, Identity Providers, and Groups (Edit)
  - Zone.DNS (Edit)

**Example**:
```bash
TF_VAR_cloudflare_api_token="abc123xyz789..."
```

### Optional Variables

#### GitHub OAuth (if using GitHub SSO)

**`TF_VAR_github_client_id`**
- **Description**: GitHub OAuth application client ID
- **Required**: Only if `enable_github_sso = true`
- **Get from**: GitHub Settings → Developer Settings → OAuth Apps
- **Format**: `Iv1.abc123xyz...`

**`TF_VAR_github_client_secret`**
- **Description**: GitHub OAuth application client secret
- **Required**: Only if `enable_github_sso = true`
- **Get from**: GitHub OAuth app page (shown once during creation)

**Setup Steps**:
1. Go to https://github.com/settings/developers
2. Click "New OAuth App"
3. Set callback URL: `https://<auth_domain>.cloudflareaccess.com/cdn-cgi/access/callback`
4. Copy client ID and secret
5. Add to `secrets.env`

**Example**:
```bash
TF_VAR_github_client_id="Iv1.abc123xyz..."
TF_VAR_github_client_secret="secret123..."
```

#### Google OAuth (if using Google SSO)

**`TF_VAR_google_client_id`**
- **Description**: Google OAuth 2.0 client ID
- **Required**: Only if `enable_google_sso = true`
- **Get from**: Google Cloud Console → APIs & Services → Credentials
- **Format**: `123456789-abc.apps.googleusercontent.com`

**`TF_VAR_google_client_secret`**
- **Description**: Google OAuth 2.0 client secret
- **Required**: Only if `enable_google_sso = true`
- **Get from**: Google Cloud Console credentials page

**Setup Steps**:
1. Go to https://console.cloud.google.com/apis/credentials
2. Create OAuth 2.0 Client ID
3. Application type: Web application
4. Add redirect URI: `https://<auth_domain>.cloudflareaccess.com/cdn-cgi/access/callback`
5. Copy client ID and secret
6. Add to `secrets.env`

**Example**:
```bash
TF_VAR_google_client_id="123456789-abc.apps.googleusercontent.com"
TF_VAR_google_client_secret="GOCSPX-abc123..."
```

#### Cloudflare Tunnel (if using tunnel)

**`TF_VAR_tunnel_secret`**
- **Description**: Base64-encoded 32-byte secret for Cloudflare Tunnel
- **Required**: Only if `enable_tunnel = true`
- **Generate with**: `openssl rand -base64 32`

**Example**:
```bash
# Generate a new tunnel secret
TUNNEL_SECRET=$(openssl rand -base64 32)

# Add to secrets.env
TF_VAR_tunnel_secret="$TUNNEL_SECRET"
```

## Security Best Practices

### File Permissions

Ensure `secrets.env` is not world-readable:

```bash
chmod 600 secrets.env
```

### Git Ignore

The file should already be in `.gitignore`:

```bash
# Check if secrets.env is ignored
git check-ignore secrets.env
# Should output: secrets.env
```

### Secrets Management

Consider using a secrets manager for production:

#### 1Password CLI
```bash
# Store secrets in 1Password
op item create --category=password \
  --title="Cloudflare API Token" \
  --vault="Homelab" \
  password="your-token-here"

# Retrieve in scripts
export TF_VAR_cloudflare_api_token=$(op read "op://Homelab/Cloudflare API Token/password")
```

#### SOPS (Secrets OPerationS)
```bash
# Encrypt secrets.env
sops -e secrets.env > secrets.enc.env

# Decrypt and source
sops -d secrets.enc.env | source /dev/stdin
```

#### HashiCorp Vault
```bash
# Store secret
vault kv put secret/cloudflare api_token="your-token"

# Retrieve in scripts
export TF_VAR_cloudflare_api_token=$(vault kv get -field=api_token secret/cloudflare)
```

## Example Workflow

### Initial Setup

1. **Copy and edit secrets file**:
```bash
cd /home/boboysdadda/projects/gitops-homelab
nano secrets.env
```

2. **Set proper permissions**:
```bash
chmod 600 secrets.env
```

3. **Add required tokens**:
   - Get Cloudflare API token
   - (Optional) Set up GitHub/Google OAuth
   - (Optional) Generate tunnel secret

### Deploy Cloudflare Zero Trust

```bash
# Load environment variables
source secrets.env

# Navigate to cloudflare terraform directory
cd terraform/cloudflare

# Initialize and deploy
tofu init
tofu plan
tofu apply
```

### Update Secrets

```bash
# Edit secrets file
nano secrets.env

# Reload environment variables
source secrets.env

# Apply changes
cd terraform/cloudflare
tofu apply
```

## Troubleshooting

### Variables Not Found

**Error**: `variable "cloudflare_api_token" was not set`

**Solution**: Source the secrets file before running Terraform:
```bash
source secrets.env
```

### Wrong Token Format

**Error**: `Error: Invalid API token`

**Solution**: Verify your API token:
- Has correct permissions
- Is not expired
- Has no extra whitespace or quotes

```bash
# Test token
curl -H "Authorization: Bearer $TF_VAR_cloudflare_api_token" \
  https://api.cloudflare.com/client/v4/user/tokens/verify
```

### Environment Not Persisting

If variables disappear when opening new terminal:

**Solution 1**: Add to shell profile
```bash
# Add to ~/.bashrc or ~/.zshrc
source /home/boboysdadda/projects/gitops-homelab/secrets.env
```

**Solution 2**: Use direnv
```bash
# Install direnv
sudo apt install direnv

# Create .envrc
echo "source secrets.env" > .envrc

# Allow direnv
direnv allow
```

## Complete Example secrets.env

```bash
###################################################
# Cloudflare Zero Trust
###################################################

# Required
TF_VAR_cloudflare_api_token="your-cloudflare-api-token-here"

# Optional: GitHub OAuth
TF_VAR_github_client_id="Iv1.abc123xyz..."
TF_VAR_github_client_secret="github_secret_here"

# Optional: Google OAuth
TF_VAR_google_client_id="123456789-abc.apps.googleusercontent.com"
TF_VAR_google_client_secret="GOCSPX-abc123..."

# Optional: Cloudflare Tunnel
TF_VAR_tunnel_secret="base64-encoded-secret-here"
```

## References

- [Terraform Environment Variables](https://www.terraform.io/docs/cli/config/environment-variables.html)
- [Cloudflare API Tokens](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
