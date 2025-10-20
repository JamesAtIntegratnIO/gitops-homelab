# Identity Provider Setup Guide

## Overview

This Terraform configuration manages identity providers in Cloudflare Zero Trust. You create OAuth applications in GitHub/Google (one-time manual step), then Terraform configures them in Cloudflare automatically.

## What Terraform Does

When you run `tofu apply`, Terraform will:

1. ✅ **Create identity provider configurations** in Cloudflare Zero Trust
2. ✅ **Configure OAuth settings** using your provided credentials
3. ✅ **Enable/disable providers** based on your variables
4. ✅ **Update provider settings** when you change configuration
5. ✅ **Handle provider lifecycle** (create, update, delete)

## What You Need to Do

You need to create OAuth applications in GitHub/Google manually (one-time setup), then provide the credentials to Terraform.

---

## Setup Instructions by Provider

### 1. One-Time PIN (Email) - Easiest Option

**No external setup required!** Just enable in `terraform.tfvars`:

```hcl
enable_otp = true
```

**How it works**:
- Users enter their email address
- Cloudflare sends a PIN code to their email
- Users enter the PIN to authenticate
- No OAuth application setup needed

**When to use**:
- Quick testing and prototyping
- Small user base
- Don't want to manage OAuth apps

---

### 2. GitHub OAuth

#### Step 1: Create OAuth App in GitHub (One-Time)

1. Go to **GitHub.com** → Settings → Developer settings → OAuth Apps
   - Direct link: https://github.com/settings/developers

2. Click **"New OAuth App"**

3. Fill in the application details:
   ```
   Application name: Homelab Zero Trust
   Homepage URL: https://your-domain.com
   Application description: Cloudflare Zero Trust for Homelab
   Authorization callback URL: https://<auth_domain>.cloudflareaccess.com/cdn-cgi/access/callback
   ```
   
   **Example callback URL**: 
   - If `auth_domain_prefix = "homelab"` → `https://homelab.cloudflareaccess.com/cdn-cgi/access/callback`

4. Click **"Register application"**

5. On the next page:
   - Copy the **Client ID** (looks like: `Iv1.abc123xyz...`)
   - Click **"Generate a new client secret"**
   - Copy the **Client secret** (you'll only see this once!)

#### Step 2: Configure Terraform (Automatic)

Add to your `terraform.tfvars`:

```hcl
# Enable GitHub SSO
enable_github_sso    = true
github_client_id     = "Iv1.abc123xyz..."           # From GitHub OAuth App
github_client_secret = "your-secret-here"           # From GitHub OAuth App
```

#### Step 3: Deploy

```bash
tofu apply
```

Terraform will:
- ✅ Create the GitHub identity provider in Cloudflare
- ✅ Configure OAuth settings
- ✅ Enable GitHub authentication for your applications

**That's it!** Users can now authenticate with their GitHub accounts.

---

### 3. Google OAuth

#### Step 1: Create OAuth Credentials in Google Cloud (One-Time)

1. Go to **Google Cloud Console**: https://console.cloud.google.com/

2. Create or select a project:
   - Click project dropdown at top
   - Click "New Project"
   - Name it: `Homelab Zero Trust`
   - Click "Create"

3. Enable Google+ API (required for OAuth):
   - Go to "APIs & Services" → "Library"
   - Search for "Google+ API"
   - Click "Enable"

4. Create OAuth credentials:
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - If prompted, configure OAuth consent screen:
     - User Type: External (for personal use)
     - App name: `Homelab Zero Trust`
     - User support email: Your email
     - Developer contact: Your email
     - Save and continue (skip optional fields)
   
5. Configure OAuth Client:
   ```
   Application type: Web application
   Name: Homelab Zero Trust
   Authorized redirect URIs: 
     https://<auth_domain>.cloudflareaccess.com/cdn-cgi/access/callback
   ```
   
   **Example redirect URI**:
   - If `auth_domain_prefix = "homelab"` → `https://homelab.cloudflareaccess.com/cdn-cgi/access/callback`

6. Click **"Create"**

7. Copy the credentials:
   - **Client ID** (looks like: `123456789-abc.apps.googleusercontent.com`)
   - **Client Secret** (looks like: `GOCSPX-...`)

#### Step 2: Configure Terraform (Automatic)

Add to your `terraform.tfvars`:

```hcl
# Enable Google SSO
enable_google_sso    = true
google_client_id     = "123456789-abc.apps.googleusercontent.com"
google_client_secret = "GOCSPX-abc123..."
```

#### Step 3: Deploy

```bash
tofu apply
```

Terraform will:
- ✅ Create the Google identity provider in Cloudflare
- ✅ Configure OAuth settings
- ✅ Enable Google authentication for your applications

**Done!** Users can now authenticate with their Google accounts.

---

## Using Multiple Providers

You can enable multiple identity providers simultaneously:

```hcl
# Enable all three
enable_otp        = true
enable_github_sso = true
enable_google_sso = true

github_client_id     = "Iv1.abc123xyz..."
github_client_secret = "secret1"

google_client_id     = "123456789.apps.googleusercontent.com"
google_client_secret = "GOCSPX-secret2"
```

**Users will see a login page with all enabled options:**
- "Sign in with GitHub"
- "Sign in with Google"  
- "Send me a code" (OTP)

---

## Verification After Deployment

### 1. Check Terraform Output

```bash
tofu output
```

Should show your auth domain and configured providers.

### 2. Check Cloudflare Dashboard

1. Go to Cloudflare Dashboard → Zero Trust → Settings → Authentication
2. You should see your configured identity providers:
   - GitHub (if enabled)
   - Google (if enabled)
   - One-time PIN (if enabled)

### 3. Test Authentication

1. Navigate to one of your protected applications
2. You'll be redirected to Cloudflare authentication
3. Try logging in with each enabled provider
4. Check authentication works correctly

---

## Troubleshooting

### GitHub OAuth Not Working

**Error: "Redirect URI mismatch"**
- **Cause**: Callback URL in GitHub doesn't match
- **Fix**: Check your `auth_domain_prefix` in tfvars matches GitHub OAuth app callback URL

**Error: "Application suspended"**
- **Cause**: Too many failed authentication attempts
- **Fix**: Check GitHub OAuth app is not suspended

### Google OAuth Not Working

**Error: "Redirect URI mismatch"**
- **Cause**: Authorized redirect URI in Google Cloud doesn't match
- **Fix**: Verify the redirect URI matches exactly (including https://)

**Error: "Access blocked: Authorization Error"**
- **Cause**: OAuth consent screen not configured
- **Fix**: Complete OAuth consent screen setup in Google Cloud Console

**Error: "Google+ API not enabled"**
- **Cause**: Required API is not enabled in Google Cloud project
- **Fix**: Enable Google+ API in APIs & Services → Library

### General Issues

**Terraform apply fails with "config" error**
- **Check**: Ensure you're using provider version ~5.11.0
- **Fix**: Run `tofu init -upgrade`

**Users can't authenticate**
- **Check**: Identity provider appears in Cloudflare Dashboard
- **Check**: Provider is included in access policies
- **Check**: User's email is in an access group

---

## Updating Credentials

If you need to rotate OAuth credentials:

### GitHub

1. Generate new secret in GitHub OAuth app
2. Update `github_client_secret` in `terraform.tfvars`
3. Run `tofu apply`
4. Terraform will update Cloudflare configuration automatically

### Google

1. Generate new credentials in Google Cloud Console
2. Update `google_client_id` and `google_client_secret` in `terraform.tfvars`
3. Run `tofu apply`
4. Terraform will update Cloudflare configuration automatically

---

## Summary: The Terraform Advantage

### Without Terraform 😰
- Manual configuration in Cloudflare Dashboard
- Click through multiple screens for each provider
- Risk of misconfiguration
- Hard to replicate setup
- Manual updates when credentials change

### With Terraform 😎
- **One command**: `tofu apply`
- **Version controlled**: All settings in tfvars
- **Reproducible**: Same config every time
- **Automated updates**: Change tfvars and apply
- **Documentation as code**: Settings are self-documenting

---

## Best Practices

1. **Store secrets securely**: Consider using a secrets manager
   ```bash
   # Example with 1Password
   github_client_secret = "op://vault/item/password"
   ```

2. **Use all three providers** for flexibility:
   - GitHub/Google for regular users
   - OTP as backup if OAuth is down

3. **Test authentication** after deployment:
   ```bash
   tofu apply
   # Test login immediately after
   ```

4. **Document your OAuth apps**: Keep track of which apps are for which environment

5. **Rotate credentials periodically**: Good security practice

---

## Resources

- [GitHub OAuth Apps Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Cloudflare Zero Trust Identity Providers](https://developers.cloudflare.com/cloudflare-one/identity/idp-integration/)
- [Terraform Cloudflare Provider - Identity Providers](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zero_trust_access_identity_provider)
