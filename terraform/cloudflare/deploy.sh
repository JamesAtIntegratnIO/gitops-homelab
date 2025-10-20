#!/usr/bin/env bash

###################################################
#                                                 #
#   _____ _                 _ __ _                #
#  / ____| |               | / _| |               #
# | |    | | ___  _   _  __| | |_| | __ _ _ __   #
# | |    | |/ _ \| | | |/ _` |  _| |/ _` | '__|  #
# | |____| | (_) | |_| | (_| | | | | (_| | |     #
#  \_____|_|\___/ \__,_|\__,_|_| |_|\__,_|_|     #
#                                                 #
#   ______           _____                _       #
#  |___  /          |_   _|              | |      #
#     / / ___ _ __ ___| |_ __ _   _ ___| |_      #
#    / / / _ \ '__/ _ \ | '__| | | / __| __|     #
#   / /_|  __/ | | (_) | | |  | |_| \__ \ |_     #
#  /_____\___|_|  \___/\_/_|   \__,_|___/\__|    #
#                                                 #
#   _____      _                                  #
#  /  ___|    | |                                 #
#  \ `--.  ___| |_ _   _ _ __                     #
#   `--. \/ _ \ __| | | | '_ \                    #
#  /\__/ /  __/ |_| |_| | |_) |                   #
#  \____/ \___|\__|\__,_| .__/                    #
#                       | |                       #
#                       |_|                       #
###################################################

set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -n "${DEBUG:-}" ]] && set -x

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "###################################################"
    echo "#   Cloudflare Zero Trust Deployment              #"
    echo "###################################################"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v terraform &> /dev/null && ! command -v tofu &> /dev/null; then
        missing_tools+=("terraform/tofu")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install missing tools and try again."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

check_config() {
    print_info "Checking configuration..."
    
    if [ ! -f "$SCRIPTDIR/terraform.tfvars" ]; then
        print_error "terraform.tfvars not found"
        echo ""
        echo "Please create terraform.tfvars from the example:"
        echo "  cp terraform.tfvars.example terraform.tfvars"
        echo "  nano terraform.tfvars"
        echo ""
        exit 1
    fi
    
    # Check for required variables
    local required_vars=("cloudflare_api_token" "cloudflare_account_name" "admin_emails")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^[[:space:]]*$var[[:space:]]*=" "$SCRIPTDIR/terraform.tfvars"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing required variables in terraform.tfvars:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        exit 1
    fi
    
    print_success "Configuration check passed"
}

init_terraform() {
    print_info "Initializing Terraform..."
    
    if command -v tofu &> /dev/null; then
        TFCMD="tofu"
    else
        TFCMD="terraform"
    fi
    
    cd "$SCRIPTDIR"
    $TFCMD init -upgrade
    
    print_success "Terraform initialized"
}

plan_deployment() {
    print_info "Planning deployment..."
    echo ""
    
    cd "$SCRIPTDIR"
    $TFCMD plan -out=tfplan
    
    echo ""
    print_warning "Please review the plan above carefully"
    read -p "Do you want to proceed with deployment? (yes/no): " -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        print_info "Deployment cancelled"
        rm -f tfplan
        exit 0
    fi
}

apply_deployment() {
    print_info "Applying deployment..."
    echo ""
    
    cd "$SCRIPTDIR"
    $TFCMD apply tfplan
    
    rm -f tfplan
    
    print_success "Deployment completed successfully!"
}

show_outputs() {
    echo ""
    print_header
    print_info "Deployment Outputs"
    echo ""
    
    cd "$SCRIPTDIR"
    $TFCMD output
    
    echo ""
    print_info "Important Next Steps:"
    echo ""
    echo "1. Visit your Cloudflare Dashboard to verify configuration:"
    echo "   https://dash.cloudflare.com/"
    echo ""
    echo "2. If you enabled Cloudflare Tunnel, install cloudflared:"
    echo "   - Download: https://github.com/cloudflare/cloudflared/releases"
    echo "   - See README.md for configuration instructions"
    echo ""
    echo "3. Test access to your protected applications:"
    
    if [ -f "$SCRIPTDIR/terraform.tfvars" ]; then
        # Extract domains from applications list
        while IFS= read -r domain; do
            [ -n "$domain" ] && echo "   - https://$domain"
        done < <(grep -oP '(?<=domain\s=\s")[^"]+' "$SCRIPTDIR/terraform.tfvars")
    fi
    
    echo ""
    echo "4. Monitor access logs in Cloudflare Dashboard:"
    echo "   Zero Trust → Access → Logs"
    echo ""
}

# Main execution
main() {
    print_header
    
    check_prerequisites
    check_config
    init_terraform
    plan_deployment
    apply_deployment
    show_outputs
    
    print_success "All done! Your Zero Trust setup is ready."
}

# Run main function
main "$@"
