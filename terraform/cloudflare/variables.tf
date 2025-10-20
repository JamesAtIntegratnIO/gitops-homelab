# Cloudflare Zero Trust Variables

###################################################
#   ___                           _               #
#  / _ \                         | |              #
# / /_\ \ ___ ___ ___  _   _ _ __ | |_             #
# |  _  |/ __/ __/ _ \| | | | '_ \| __|            #
# | | | | (_| (_| (_) | |_| | | | | |_             #
# \_| |_/\___\___\___/ \__,_|_| |_|\__|            #
#                                                 #
###################################################

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID (get from Cloudflare Dashboard)"
  type        = string
}

variable "cloudflare_zone_name" {
  description = "Cloudflare zone name (e.g., example.com)"
  type        = string
  default     = "integratn.tech"
}

###################################################
#                                                 #
#    ___                   _          _   _       #
#   / _ \ _ __ __ _ __ _ _ (_)______ _| |_(_)___ _ __  #
#  | | | | '__/ _` / _` | '_ \|_ / _` | __| / _ \ '_ \ #
#  | |_| | | | (_| | (_| | | | |/ / (_| | |_| | (_) | | | |#
#   \___/|_|  \__, |\__,_|_| |_/___\__,_|\__|_|\___/|_| |_|#
#             |___/                                   #
###################################################

variable "organization_name" {
  description = "Cloudflare Access organization name"
  type        = string
  default     = "Homelab"
}

variable "auth_domain_prefix" {
  description = "Auth domain prefix (becomes <prefix>.cloudflareaccess.com)"
  type        = string
}

variable "login_background_color" {
  description = "Login page background color"
  type        = string
  default     = "#1a1a1a"
}

variable "login_text_color" {
  description = "Login page text color"
  type        = string
  default     = "#ffffff"
}

variable "login_logo_path" {
  description = "Login page logo path (URL)"
  type        = string
  default     = ""
}

variable "login_header_text" {
  description = "Login page header text"
  type        = string
  default     = "Homelab Services"
}

variable "login_footer_text" {
  description = "Login page footer text"
  type        = string
  default     = "Secure Access via Cloudflare Zero Trust"
}

###################################################
#                                                 #
#   _____    _           _   _ _                  #
#  |_   _|  | |         | | (_) |                 #
#    | |  __| | ___ _ __ | |_ _| |_ _   _         #
#    | | / _` |/ _ \ '_ \| __| | __| | | |        #
#   _| || (_| |  __/ | | | |_| | |_| |_| |        #
#   \___/\__,_|\___|_| |_|\__|_|\__|\__, |        #
#                                    __/ |        #
#                                   |___/         #
###################################################

variable "enable_github_sso" {
  description = "Enable GitHub SSO"
  type        = bool
  default     = false
}

variable "github_client_id" {
  description = "GitHub OAuth client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_google_sso" {
  description = "Enable Google SSO"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_otp" {
  description = "Enable One-Time PIN authentication"
  type        = bool
  default     = true
}

###################################################
#                                                 #
#    _____                                        #
#   |  __ \                                       #
#   | |  \/_ __ ___  _   _ _ __  ___             #
#   | | __| '__/ _ \| | | | '_ \/ __|            #
#   | |_\ \ | | (_) | |_| | |_) \__ \            #
#    \____/_|  \___/ \__,_| .__/|___/            #
#                         | |                    #
#                         |_|                    #
###################################################

variable "admin_emails" {
  description = "List of admin email addresses"
  type        = list(string)
}

variable "enable_developer_group" {
  description = "Enable developer group"
  type        = bool
  default     = false
}

variable "developer_emails" {
  description = "List of developer email addresses"
  type        = list(string)
  default     = []
}

variable "enable_family_group" {
  description = "Enable family group"
  type        = bool
  default     = false
}

variable "family_emails" {
  description = "List of family member email addresses"
  type        = list(string)
  default     = []
}

variable "enable_internal_network_group" {
  description = "Enable internal network IP-based group"
  type        = bool
  default     = false
}

variable "internal_network_cidrs" {
  description = "List of internal network CIDR blocks"
  type        = list(string)
  default     = []
}

###################################################
#                                                 #
#   ___  ______ ___  _ _           _   _          #
#  / _ \ | ___ \  _ \| (_)         | | (_)         #
# / /_\ \| |_/ / |_) | |_  ___ __ _| |_ _  ___  _ __  #
# |  _  ||  __/|  __/| | |/ __/ _` | __| |/ _ \| '_ \ #
# | | | || |   | |   | | | (_| (_| | |_| | (_) | | | |#
# \_| |_/\_|   \_|   |_|_|\___\__,_|\__|_|\___/|_| |_|#
#                                                 #
###################################################

variable "session_duration" {
  description = "Default session duration for access policies (e.g., '24h', '12h')"
  type        = string
  default     = "24h"
}

variable "applications" {
  description = "List of applications to protect with Zero Trust"
  type = list(object({
    name                           = string
    domain                         = string
    type                           = optional(string, "self_hosted")
    session_duration               = optional(string)
    auto_redirect_to_identity      = optional(bool, true)
    enable_binding_cookie          = optional(bool, false)
    http_only_cookie_attribute     = optional(bool, true)
    same_site_cookie_attribute     = optional(string, "strict")
    enable_cors                    = optional(bool, false)
    tags                           = optional(list(string), [])
    allow_developers               = optional(bool, false)
    allow_family                   = optional(bool, false)
    allow_internal_network         = optional(bool, false)
    purpose_justification_required = optional(bool, false)
    purpose_justification_prompt   = optional(string, "")
  }))
  default = []
}

###################################################
#                                                 #
#   _____                       _                 #
#  |_   _|                     | |                #
#    | |_   _ _ __  _ __   ___| |                 #
#    | | | | | '_ \| '_ \ / _ \ |                 #
#    | | |_| | | | | | | |  __/ |                 #
#    \_/\__,_|_| |_|_| |_|\___|_|                 #
#                                                 #
###################################################

variable "enable_tunnel" {
  description = "Enable Cloudflare Tunnel"
  type        = bool
  default     = false
}

variable "tunnel_name" {
  description = "Cloudflare Tunnel name"
  type        = string
  default     = "homelab-tunnel"
}

variable "tunnel_secret" {
  description = "Cloudflare Tunnel secret (base64 encoded 32-byte value)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tunnel_ingress_rules" {
  description = "List of tunnel ingress rules"
  type = list(object({
    hostname      = string
    service       = string
    no_tls_verify = optional(bool, false)
  }))
  default = []
}

###################################################
#                                                 #
#    ___   ___  ______                            #
#   |__ \ / _ \ |  _  \                           #
#      ) | | | || | | |                           #
#     / /| | | || | | |                           #
#    / /_| |_| || |/ /                            #
#   |____|\___/ |___/                             #
#                                                 #
###################################################

variable "enable_device_posture" {
  description = "Enable device posture checks"
  type        = bool
  default     = false
}

variable "enable_dlp" {
  description = "Enable Data Loss Prevention (DLP)"
  type        = bool
  default     = false
}

variable "dlp_patterns" {
  description = "DLP patterns to detect sensitive data"
  type = list(object({
    name  = string
    regex = string
  }))
  default = []
}
