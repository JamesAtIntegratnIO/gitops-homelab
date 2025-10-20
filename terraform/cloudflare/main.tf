# Cloudflare Zero Trust Configuration
# Provider version: ~> 5.11.0

# Get the Cloudflare zone
data "cloudflare_zone" "zone" {
  filter = {
    name = var.cloudflare_zone_name
  }
}

# Note: In provider 5.x, cloudflare_accounts requires the account_id directly
# You'll need to provide account_id as a variable instead of looking it up by name
locals {
  account_id = var.cloudflare_account_id
  zone_id    = data.cloudflare_zone.zone.id
}

###################################################
#   Identity Providers                            #
###################################################

# GitHub OAuth Identity Provider
resource "cloudflare_zero_trust_access_identity_provider" "github" {
  count      = var.enable_github_sso ? 1 : 0
  account_id = local.account_id
  name       = "GitHub"
  type       = "github"
  
  config = {
    client_id     = var.github_client_id
    client_secret = var.github_client_secret
  }
}

# Google OAuth Identity Provider
resource "cloudflare_zero_trust_access_identity_provider" "google" {
  count      = var.enable_google_sso ? 1 : 0
  account_id = local.account_id
  name       = "Google"
  type       = "google"
  
  config = {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
  }
}

# One-time PIN (Email) Identity Provider
resource "cloudflare_zero_trust_access_identity_provider" "otp" {
  count      = var.enable_otp ? 1 : 0
  account_id = local.account_id
  name       = "One-time PIN"
  type       = "onetimepin"
  
  config = {}
}

###################################################
#   Access Groups                                 #
###################################################

# Admin Group
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

# Developers Group
resource "cloudflare_zero_trust_access_group" "developers" {
  count      = var.enable_developer_group ? 1 : 0
  account_id = local.account_id
  name       = "Developers"

  include = [
    for email in var.developer_emails : {
      email = {
        email = email
      }
    }
  ]
}

# Family Group
resource "cloudflare_zero_trust_access_group" "family" {
  count      = var.enable_family_group ? 1 : 0
  account_id = local.account_id
  name       = "Family"

  include = [
    for email in var.family_emails : {
      email = {
        email = email
      }
    }
  ]
}

# Internal Network Group
resource "cloudflare_zero_trust_access_group" "internal_network" {
  count      = var.enable_internal_network_group ? 1 : 0
  account_id = local.account_id
  name       = "Internal Network"

  include = [
    for cidr in var.internal_network_cidrs : {
      ip = {
        ip = cidr
      }
    }
  ]
}

###################################################
#   Applications and Policies                     #
###################################################

# Create applications from list
resource "cloudflare_zero_trust_access_application" "apps" {
  for_each = { for app in var.applications : app.name => app }
  
  account_id = local.account_id
  name       = each.value.name
  domain     = each.value.domain
  type       = lookup(each.value, "type", "self_hosted")
  
  session_duration             = lookup(each.value, "session_duration", var.session_duration)
  auto_redirect_to_identity    = lookup(each.value, "auto_redirect_to_identity", true)
  enable_binding_cookie        = lookup(each.value, "enable_binding_cookie", false)
  http_only_cookie_attribute   = lookup(each.value, "http_only_cookie_attribute", true)
  same_site_cookie_attribute   = lookup(each.value, "same_site_cookie_attribute", "strict")
  
  # Note: CORS configuration removed - not supported in provider 5.11.0
  # Configure CORS via Cloudflare Dashboard if needed
  
  # Tags
  tags = lookup(each.value, "tags", [])
}

# Create policies for applications
resource "cloudflare_zero_trust_access_policy" "app_policies" {
  for_each = { for app in var.applications : app.name => app }
  
  account_id = local.account_id
  name       = "${each.value.name} Access Policy"
  decision   = "allow"
  
  # Build include list dynamically
  include = concat(
    # Always include admins
    [{
      group = {
        id = cloudflare_zero_trust_access_group.admins.id
      }
    }],
    # Include developers if specified and group exists
    lookup(each.value, "allow_developers", false) && var.enable_developer_group ? [{
      group = {
        id = cloudflare_zero_trust_access_group.developers[0].id
      }
    }] : [],
    # Include family if specified and group exists
    lookup(each.value, "allow_family", false) && var.enable_family_group ? [{
      group = {
        id = cloudflare_zero_trust_access_group.family[0].id
      }
    }] : [],
    # Include internal network if specified and group exists
    lookup(each.value, "allow_internal_network", false) && var.enable_internal_network_group ? [{
      group = {
        id = cloudflare_zero_trust_access_group.internal_network[0].id
      }
    }] : []
  )
  
  session_duration = lookup(each.value, "session_duration", var.session_duration)
  
  purpose_justification_required = lookup(each.value, "purpose_justification_required", false)
  purpose_justification_prompt   = lookup(each.value, "purpose_justification_prompt", "")
  
  depends_on = [
    cloudflare_zero_trust_access_application.apps
  ]
}

###################################################
#   Cloudflare Tunnel                             #
###################################################

# Note: Tunnel configuration in provider 5.11.0 has changed
# The tunnel is created, but configuration must be done via cloudflared CLI
# or Cloudflare Dashboard. The secret is auto-generated.
resource "cloudflare_zero_trust_tunnel_cloudflared" "homelab" {
  count      = var.enable_tunnel ? 1 : 0
  account_id = local.account_id
  name       = var.tunnel_name
  # Note: secret is auto-generated in provider 5.x
}

# DNS records for tunnel endpoints
# Note: tunnel_ingress_rules configuration must be done via cloudflared config.yml
resource "cloudflare_dns_record" "tunnel" {
  for_each = var.enable_tunnel ? { for rule in var.tunnel_ingress_rules : rule.hostname => rule } : {}
  zone_id  = local.zone_id
  name     = each.value.hostname
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.homelab[0].id}.cfargotunnel.com"
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

###################################################
#   Optional Features                             #
###################################################

resource "cloudflare_zero_trust_device_posture_rule" "os_version" {
  count      = var.enable_device_posture ? 1 : 0
  account_id = local.account_id
  name       = "OS Version Check"
  type       = "os_version"
  
  input = {
    os_distro_name    = "linux"
    os_distro_version = "20.04"
    os_version_extra  = "(20.04)"
  }

  match = [{
    platform = "linux"
  }]
}

# DLP Profile - Not available in provider version 5.11.0
# Uncomment and adjust when DLP resources become available
# resource "cloudflare_zero_trust_dlp_profile" "homelab" {
#   count       = var.enable_dlp ? 1 : 0
#   account_id  = local.account_id
#   name        = "Homelab DLP"
#   type        = "custom"
#   description = "DLP profile for homelab sensitive data"
#
#   dynamic "entry" {
#     for_each = var.dlp_patterns
#     content {
#       name    = entry.value.name
#       enabled = true
#       
#       pattern {
#         regex      = entry.value.regex
#         validation = lookup(entry.value, "validation", "")
#       }
#     }
#   }
# }

###################################################
#   Outputs                                       #
###################################################

output "account_id" {
  description = "Cloudflare Account ID"
  value       = local.account_id
}

output "zone_id" {
  description = "Cloudflare Zone ID"
  value       = local.zone_id
}

output "tunnel_id" {
  description = "Cloudflare Tunnel ID"
  value       = var.enable_tunnel ? cloudflare_zero_trust_tunnel_cloudflared.homelab[0].id : null
}

output "tunnel_cname" {
  description = "Cloudflare Tunnel CNAME target"
  value       = var.enable_tunnel ? "${cloudflare_zero_trust_tunnel_cloudflared.homelab[0].id}.cfargotunnel.com" : null
}

output "admin_group_id" {
  description = "Admin group ID"
  value       = cloudflare_zero_trust_access_group.admins.id
}

output "application_domains" {
  description = "Protected application domains"
  value       = { for name, app in cloudflare_zero_trust_access_application.apps : name => app.domain }
}

output "application_ids" {
  description = "Application IDs for reference"
  value       = { for name, app in cloudflare_zero_trust_access_application.apps : name => app.id }
}
