# Terraform Infrastructure for GitOps Homelab

This Terraform project implements a comprehensive multi-cluster Kubernetes infrastructure using **Talos Linux** on **Proxmox VE**. It provides a complete **GitOps-ready** environment with **ArgoCD**, **1Password Connect**, **External Secrets**, and **Cloudflare DNS** integration.

## 📊 Infrastructure Overview

The project deploys multiple specialized Kubernetes clusters in a **hub-and-spoke architecture**:
- **Hub Cluster**: Control plane running ArgoCD, External Secrets, and GitOps components
- **Spoke Clusters**: Specialized workload clusters (media, monitoring, platform engineering)
- **Modular Design**: Reusable Terraform modules for consistent deployments
- **Automated Deployment**: One-command cluster provisioning with `deploy.sh` scripts

## 🏗️ Architecture Components

### Core Infrastructure
- **Proxmox VMs**: High-performance virtual machines with customizable CPU, memory, and storage
- **Talos Linux**: Immutable, secure Kubernetes OS with API-driven configuration
- **VM Templates**: Pre-built Talos images for rapid cluster deployment
- **Network Configuration**: VLAN support, static IPs, and custom MAC addresses

### GitOps Integration
- **ArgoCD Bootstrap**: Automated GitOps control plane setup
- **External Secrets Operator**: 1Password Connect integration for secure secret management
- **Cluster Registration**: Automatic spoke cluster registration with hub
- **Application Sets**: Dynamic application deployment across clusters

### DNS and Networking
- **Cloudflare Integration**: Automated DNS record management
- **Ingress Ready**: Pre-configured DNS for cluster services
- **Multi-Network Support**: VLAN segmentation and network policies

## 📁 Project Structure

```
terraform/
├── hub/                    # Control plane cluster
│   ├── cluster.tf         # Hub cluster configuration
│   ├── deploy.sh          # Automated deployment script
│   └── terraform.tfvars   # Hub-specific variables
├── spokes/                # Spoke clusters
│   ├── media-cluster/     # Media server cluster
│   ├── monitoring-cluster/  # Observability cluster
│   └── kratix-test-cluster/ # Platform engineering cluster
└── modules/               # Reusable Terraform modules
    ├── cluster/           # Core cluster deployment module
    └── cloudflare/        # DNS management module
```

## 🔧 Prerequisites

### Infrastructure Requirements
- **Proxmox VE 8.0+**: Virtualization platform with sufficient resources
- **Network Setup**: VLAN support and static IP ranges configured
- **Storage**: ZFS or other high-performance storage backend
- **Templates**: Talos Linux VM templates pre-deployed in Proxmox

### Access and Credentials
- **Proxmox API Access**: User account with `TerraformProv` role
- **1Password Connect**: Server and credentials for secret management
- **Cloudflare API**: API key for DNS record management
- **Git SSH Access**: SSH keys for GitOps repository access

### Development Tools
- **OpenTofu/Terraform**: Infrastructure as Code tool
- **Talos CLI**: For cluster management and troubleshooting
- **kubectl**: Kubernetes command-line tool
- **Nix (Recommended)**: For reproducible development environment

### Resource Requirements

| Cluster Type | Min CPU | Min RAM | Min Storage | Nodes |
|--------------|---------|---------|-------------|-------|
| Hub Cluster | 6 cores | 8GB | 96GB | 3 |
| Media Cluster | 4 cores | 8GB | 100GB+ | 1-3 |
| Monitoring | 6 cores | 12GB | 64GB | 3 |
| Platform/Test | 2 cores | 4GB | 32GB | 1-2 |

## ⚙️ Configuration

### Environment Setup

1. **Configure secrets** in `secrets.env`:
```bash
PM_USER="terraform-prov@pve"
PM_PASS="your-proxmox-password"
TF_VAR_cloudflare_api_key="your-cloudflare-api-key"
TF_VAR_onepassword_credentials="your-1password-credentials"
TF_VAR_onepassword_token="your-1password-token"
```

2. **Proxmox User and Role Setup**:
```bash
# Create role with minimal required privileges
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

# Create user and assign role
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

### Cluster Configuration

Each cluster is configured via `terraform.tfvars` with the following key parameters:

#### Node Configuration
```hcl
nodes = {
  "10.0.5.101" = {
    name             = "talos-controlplane-1"
    controlplane     = true
    cpu_cores        = 4
    memory           = 8192
    disk_size        = "100G"
    target_node_name = "pve1"
    networks = [{
      vlan = 25
      macaddr = "02:00:00:00:00:01"
    }]
  }
}
```

#### Network Configuration
```hcl
ip_base             = "10.0.5.0"      # Base IP for cluster
cidr                = 24              # Network CIDR
gateway             = "10.0.0.1"      # Default gateway
cluster_endpoint_ip = "10.0.5.100"    # Kubernetes API endpoint
nameservers         = ["1.1.1.1", "10.0.0.1"]
```

#### GitOps Configuration
```hcl
gitops_addons_org      = "https://github.com/jamesatintegratnio"
gitops_addons_repo     = "gitops-homelab"
gitops_addons_basepath = "gitops/"
gitops_addons_path     = "bootstrap/control-plane/addons"
gitops_addons_revision = "main"
```

### State Management

The project uses **PostgreSQL backend** for Terraform state management:
- **Hub Cluster**: `postgres://10.0.3.1/terraform_state`
- **Media Cluster**: `postgres://10.0.3.1/terraform_media_cluster`
- **Monitoring Cluster**: Local state file (fallback)

### DNS Configuration

Cloudflare DNS records are automatically managed:
```hcl
cloudflare_records = {
  "cluster-api" = {
    name    = "api.cluster.example.com"
    type    = "A"
    content = "10.0.5.100"
    proxied = false
    ttl     = 1
  }
  "wildcard-apps" = {
    name    = "*.apps.cluster.example.com"
    type    = "A"
    content = "10.0.5.200"
    proxied = false
    ttl     = 1
  }
}
```

## 🚀 Deployment Guide

### Quick Start - Deploy All Clusters
```bash
# From project root - deploys hub + all spoke clusters
yolo
```

### Individual Cluster Deployment

#### 1. Deploy Hub Cluster (Control Plane)
```bash
cd terraform/hub
./deploy.sh
```

#### 2. Deploy Spoke Clusters
```bash
# Media cluster
cd terraform/spokes/media-cluster
./deploy.sh

# Monitoring cluster
cd terraform/spokes/monitoring-cluster
./deploy.sh

# Platform engineering cluster
cd terraform/spokes/kratix-test-cluster
./deploy.sh
```

### Manual Deployment Steps

For more control or troubleshooting:

```bash
# Navigate to desired cluster directory
cd terraform/hub  # or terraform/spokes/media-cluster

# Initialize Terraform
tofu init --upgrade

# Review deployment plan
tofu plan

# Apply configuration
tofu apply

# Access cluster
export KUBECONFIG=./kubeconfig
kubectl get nodes
```

### Post-Deployment Access

#### ArgoCD Access
```bash
# Get ArgoCD admin password
kubectl get secrets argocd-initial-admin-secret -n argocd \
  --template="{{index .data.password | base64decode}}"

# Access ArgoCD UI
echo "ArgoCD URL: https://$(kubectl get ingress -n argocd argo-cd-argocd-server -o jsonpath='{.spec.rules[0].host}')"
```

#### Cluster Context Management
```bash
# Add cluster to kubeconfig with kubecm
kubecm add kubeconfig -f kubeconfig -c
kubecm switch admin@cluster-name

# Or manually export
export KUBECONFIG=./kubeconfig
```

## 🛠️ Cluster Management

### Talos Administration
```bash
# Apply talos configuration
export TALOSCONFIG=./talosconfig
talosctl config endpoint <node-ip>

# Check cluster health
talosctl health
talosctl get nodes

# Bootstrap cluster (first deployment only)
talosctl bootstrap -n <control-plane-ip>

# Upgrade Talos (when new versions available)
talosctl upgrade --image=ghcr.io/siderolabs/talos:v1.8.1
```

### Kubernetes Operations
```bash
# Cluster status
kubectl get nodes -o wide
kubectl get pods -A

# Resource usage
kubectl top nodes
kubectl top pods -A

# Troubleshooting
kubectl describe node <node-name>
kubectl logs -n kube-system -l app=cilium
```

### GitOps Management
```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Sync specific application
argocd app sync <app-name>

# Check application status
argocd app get <app-name>
```

### Secret Management
```bash
# Check External Secrets Operator
kubectl get externalsecrets -A
kubectl get secretstores -A

# Manually sync secret
kubectl annotate externalsecret <secret-name> force-sync=$(date +%s) --overwrite
```

## 🏢 Cluster Specifications

### Hub Cluster (`terraform/hub/`)
**Purpose**: GitOps control plane and cluster management
- **ArgoCD**: Application lifecycle management
- **External Secrets Operator**: 1Password Connect integration
- **Cluster API**: Multi-cluster management
- **DNS**: Cloudflare integration for service discovery

### Media Cluster (`terraform/spokes/media-cluster/`)
**Purpose**: Media server and streaming applications
- **Storage Optimization**: High-capacity storage configuration
- **Network Performance**: Optimized for media streaming
- **GPU Support**: NVIDIA GPU passthrough capability (optional)
- **Example Services**: Plex, Jellyfin, Sonarr, Radarr

### Monitoring Cluster (`terraform/spokes/monitoring-cluster/`)
**Purpose**: Observability and monitoring stack
- **Prometheus Stack**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation
- **Cross-cluster Monitoring**: Observes all clusters in the homelab

### Kratix Test Cluster (`terraform/spokes/kratix-test-cluster/`)
**Purpose**: Platform engineering and service composition
- **Kratix Platform**: Service composition and abstraction
- **Development Environment**: Testing new platform capabilities
- **Resource Efficiency**: Minimal resource allocation for testing

## 🔧 Module Documentation

### Cluster Module (`modules/cluster/`)

**Features**:
- Multi-node Talos cluster deployment
- Control plane and worker node management
- VM template cloning with customization
- Network configuration with VLAN support
- Automatic kubeconfig and talosconfig generation

**Key Variables**:
```hcl
variable "nodes" {
  type = map(object({
    name             = string
    controlplane     = optional(bool, false)
    cpu_cores        = optional(number, 2)
    memory           = optional(number, 1024)
    disk_size        = optional(string, "32G")
    target_node_name = optional(string, "pve2")
    networks         = optional(list(object({
      vlan    = optional(string, "-1")
      macaddr = optional(string, null)
    })))
    create_vm = optional(bool, true)
    nvidia    = optional(bool, false)
  }))
}
```

### Cloudflare Module (`modules/cloudflare/`)

**Features**:
- Automated DNS record management
- Support for A, CNAME, and other record types
- Cloudflare proxy configuration
- Wildcard domain support

## 🚨 Troubleshooting

### Common Issues

#### Stuck Namespace on Destroy
```bash
# Remove finalizers from stuck namespace
kubectl get namespace "stuck-namespace" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/stuck-namespace/finalize -f -
```

#### Talos Static IP Issues
Talos has challenges with static IPs on first boot. Workarounds:
1. **DHCP Reservations**: Configure static DHCP reservations in your router
2. **MAC Address Generation**: Use [MAC generator](https://www.hellion.org.uk/cgi-bin/randmac.pl?scope=local&type=unicast) for consistent addresses
3. **Post-boot Configuration**: Apply network configuration after initial boot

#### VM Template Issues
```bash
# Recreate Talos template if corrupted
qm destroy 9999  # Assuming template ID 9999
# Re-import fresh Talos image
```

#### GitOps Sync Issues
```bash
# Check ArgoCD application health
kubectl get applications -n argocd
argocd app get <app-name>

# Force refresh and sync
argocd app refresh <app-name>
argocd app sync <app-name>
```

### Monitoring and Observability

#### Key Metrics to Monitor
- **Cluster Health**: Node status, resource utilization
- **Application Health**: ArgoCD sync status, pod health
- **Storage**: Disk usage, I/O performance
- **Network**: Bandwidth utilization, latency

#### Useful Commands
```bash
# Check cluster resource usage
kubectl top nodes
kubectl top pods -A

# Examine system pods
kubectl get pods -n kube-system
kubectl get pods -n argocd

# Check storage
kubectl get pv,pvc -A
```

## 🔒 Security Considerations

### Network Security
- **VLAN Segmentation**: Isolate cluster traffic
- **Firewall Rules**: Restrict inter-cluster communication
- **Network Policies**: Kubernetes-native network controls

### Secret Management
- **1Password Integration**: Centralized secret management
- **External Secrets Operator**: Automatic secret rotation
- **RBAC**: Role-based access control for cluster resources

### Infrastructure Security
- **Talos Hardening**: Immutable OS with minimal attack surface
- **API Security**: Secure Kubernetes API configuration
- **Certificate Management**: Automated certificate lifecycle

## 📊 Performance Optimization

### Resource Allocation
- **CPU**: Adequate allocation for control plane components
- **Memory**: Sufficient RAM for container workloads
- **Storage**: High-performance storage for etcd and applications

### Network Performance
- **MTU Configuration**: Optimize for your network infrastructure
- **CNI Selection**: Cilium for advanced networking features
- **Load Balancing**: Proper ingress controller configuration

This Terraform infrastructure provides a robust foundation for a production-ready homelab environment with enterprise-grade capabilities and GitOps best practices.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.37.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.10.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.31.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.1-rc3 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.11.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge | homelab |
| <a name="module_cloudflare"></a> [cloudflare](#module\_cloudflare) | ./modules/cloudflare | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.op_connect](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace) | resource |
| [kubernetes_secret.docker-config](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/secret) | resource |
| [kubernetes_secret.onepassword_token](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/secret) | resource |
| [kubernetes_secret.op_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/secret) | resource |
| [time_sleep.wait_for_cluster](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `number` | n/a | yes |
| <a name="input_cloudflare_api_key"></a> [cloudflare\_api\_key](#input\_cloudflare\_api\_key) | n/a | `string` | n/a | yes |
| <a name="input_cloudflare_records"></a> [cloudflare\_records](#input\_cloudflare\_records) | n/a | <pre>map(object({<br>    name    = string<br>    value   = string<br>    type    = string<br>    ttl     = number<br>    proxied = bool<br>  }))</pre> | n/a | yes |
| <a name="input_cloudflare_zone_name"></a> [cloudflare\_zone\_name](#input\_cloudflare\_zone\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_endpoint_ip"></a> [cluster\_endpoint\_ip](#input\_cluster\_endpoint\_ip) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_extra_manifests"></a> [extra\_manifests](#input\_extra\_manifests) | n/a | `list(string)` | `[]` | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | n/a | `string` | n/a | yes |
| <a name="input_gitops_addons_basepath"></a> [gitops\_addons\_basepath](#input\_gitops\_addons\_basepath) | n/a | `string` | `""` | no |
| <a name="input_gitops_addons_org"></a> [gitops\_addons\_org](#input\_gitops\_addons\_org) | n/a | `string` | `"https://github.com/jamesatintegratnio"` | no |
| <a name="input_gitops_addons_path"></a> [gitops\_addons\_path](#input\_gitops\_addons\_path) | n/a | `string` | `"bootstrap/control-plane/addons"` | no |
| <a name="input_gitops_addons_repo"></a> [gitops\_addons\_repo](#input\_gitops\_addons\_repo) | n/a | `string` | `"gitops-bridge-argocd-control-plane"` | no |
| <a name="input_gitops_addons_revision"></a> [gitops\_addons\_revision](#input\_gitops\_addons\_revision) | n/a | `string` | `"homelab"` | no |
| <a name="input_install_disk"></a> [install\_disk](#input\_install\_disk) | n/a | `string` | `"/dev/sda"` | no |
| <a name="input_ip_base"></a> [ip\_base](#input\_ip\_base) | n/a | `string` | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | n/a | `list(string)` | `[]` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | n/a | <pre>map(object({<br>    name             = string<br>    cpu_sockets      = number<br>    cpu_cores        = number<br>    memory           = number<br>    target_node_name = string<br>    disk_size        = string<br>    macaddr          = string<br><br>    controlplane = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_onepassword_credentials"></a> [onepassword\_credentials](#input\_onepassword\_credentials) | n/a | `string` | n/a | yes |
| <a name="input_onepassword_token"></a> [onepassword\_token](#input\_onepassword\_token) | n/a | `string` | n/a | yes |
| <a name="input_proxmox_image"></a> [proxmox\_image](#input\_proxmox\_image) | n/a | `string` | `"local:iso/talos-metal-qemu-1.7.5.iso"` | no |
| <a name="input_proxmox_storage"></a> [proxmox\_storage](#input\_proxmox\_storage) | n/a | `string` | `"local-zfs"` | no |
| <a name="input_skip_cluster_wait"></a> [skip\_cluster\_wait](#input\_skip\_cluster\_wait) | n/a | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->