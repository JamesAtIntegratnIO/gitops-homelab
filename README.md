# GitOps Homelab Infrastructure

A comprehensive homelab infrastructure project that combines **Terraform**, **Talos Kubernetes**, **ArgoCD**, and **GitOps** practices to deploy and manage multiple Kubernetes clusters on Proxmox virtualization platform.

## 🏗️ Architecture Overview

This project implements a complete GitOps-driven infrastructure with the following components:

- **Infrastructure as Code**: Terraform manages Proxmox VMs and Talos Kubernetes clusters
- **GitOps Control Plane**: ArgoCD-based GitOps workflow for application and configuration management
- **Multi-Cluster Setup**: Hub and spoke architecture with specialized clusters
- **Automated Deployment**: Nix flake environment with custom tooling and scripts

## 📁 Repository Structure

```
gitops-homelab/
├── terraform/              # Infrastructure as Code
│   ├── hub/                # Control plane cluster
│   ├── spokes/             # Spoke clusters (media, monitoring, etc.)
│   └── modules/            # Reusable Terraform modules
├── gitops/                 # GitOps configurations
│   ├── bootstrap/          # ArgoCD bootstrap configurations
│   ├── clusters/           # Cluster-specific configurations
│   ├── environments/       # Environment-specific configurations
│   └── workloads/          # Application workloads
├── hack/                   # Utility scripts and tools
├── flake.nix              # Nix development environment
└── secrets.env            # Environment variables (encrypted)
```

## 🚀 Getting Started

### Prerequisites

- **Proxmox VE**: Running Proxmox cluster for VM deployment
- **Nix**: For development environment (with flakes enabled)
- **1Password Connect**: For secrets management
- **Cloudflare**: For DNS management
- **Git SSH Access**: For GitOps repository access

### Development Environment Setup

This project uses Nix flakes for reproducible development environments:

```bash
# Enable direnv (if not already enabled)
echo "use flake" > .envrc
direnv allow

# Or manually enter the development shell
nix develop
```

The development environment includes:
- Terraform/OpenTofu
- kubectl, helm, kustomize
- ArgoCD CLI
- Talos CLI
- k9s, kubecm
- Custom utility scripts

### Configuration

1. **Set up secrets**: Copy and configure `secrets.env` with your credentials
2. **Configure Terraform variables**: Update `terraform.tfvars` files in respective directories
3. **Configure GitOps repositories**: Update repository URLs in ArgoCD configurations

## 🏭 Infrastructure Components

### Terraform Modules

#### Cluster Module (`terraform/modules/cluster/`)
- **Purpose**: Deploys Talos Kubernetes clusters on Proxmox VMs
- **Features**:
  - Multi-node cluster deployment
  - Automatic Talos OS installation and configuration
  - Control plane and worker node management
  - Generates kubeconfig and talosconfig files

#### Cloudflare Module (`terraform/modules/cloudflare/`)
- **Purpose**: Manages DNS records for cluster services
- **Features**:
  - Automated DNS record creation
  - Support for A, CNAME, and other record types
  - Cloudflare proxy configuration

### Cluster Deployments

#### Hub Cluster (`terraform/hub/`)
- **Role**: Control plane cluster running ArgoCD
- **Services**: 
  - ArgoCD for GitOps
  - External Secrets Operator
  - 1Password Connect integration
  - Cloudflare DNS management

#### Spoke Clusters (`terraform/spokes/`)

**Media Cluster** (`terraform/spokes/media-cluster/`)
- **Purpose**: Media server and streaming applications
- **Configuration**: Optimized for media workloads

**Monitoring Cluster** (`terraform/spokes/monitoring-cluster/`)
- **Purpose**: Observability and monitoring stack
- **Services**: Prometheus, Grafana, AlertManager
- **Features**: Cross-cluster monitoring capabilities

**Kratix Test Cluster** (`terraform/spokes/kratix-test-cluster/`)
- **Purpose**: Platform engineering and service composition testing
- **Framework**: Kratix for platform abstraction

## 🔄 GitOps Workflow

### Bootstrap Process

The GitOps bootstrap follows a hierarchical approach:

1. **Control Plane Bootstrap** (`gitops/bootstrap/control-plane/`)
   - Deploys ArgoCD ApplicationSets
   - Sets up cluster management workflows
   - Configures cross-cluster connectivity

2. **Workload Bootstrap** (`gitops/bootstrap/workloads/`)
   - Manages application deployments across clusters
   - Team-based namespace management

### Configuration Hierarchy

The GitOps configuration follows this precedence order:

```
Global Defaults → Environment → Cluster → Application
```

- **Environments** (`gitops/environments/`): Environment-specific configurations (dev, staging, prod)
- **Clusters** (`gitops/clusters/`): Cluster-specific overrides and configurations
- **Workloads** (`gitops/workloads/`): Application-specific deployments

### ApplicationSets

The project uses ArgoCD ApplicationSets for automated application management:

- **Cluster ApplicationSet**: Manages cluster-level configurations
- **Addon ApplicationSets**: Deploys infrastructure addons (cert-manager, external-dns, etc.)
- **Workload ApplicationSets**: Manages application workloads across clusters

## 🛠️ Operations and Management

### Custom Tooling

The Nix flake provides several custom tools:

#### Cluster Management
```bash
# Deploy all clusters
yolo

# Scale down namespace (disable ArgoCD sync + scale to 0)
scale-down-namespace <namespace>

# Scale up namespace (re-enable ArgoCD sync + scale up)
scale-up-namespace <namespace>

# Get secret data in readable format
get_secret_data <namespace> <secret-name>
```

#### Infrastructure Deployment
```bash
# Deploy hub cluster
cd terraform/hub && ./deploy.sh

# Deploy specific spoke cluster
cd terraform/spokes/media-cluster && ./deploy.sh
```

### Secrets Management

The project integrates with 1Password Connect for secure secret management:

- **External Secrets Operator**: Syncs secrets from 1Password to Kubernetes
- **ArgoCD Integration**: Secure Git repository access
- **Service Authentication**: API keys and credentials management

### Monitoring and Observability

- **Cluster Monitoring**: Dedicated monitoring cluster with Prometheus stack
- **GitOps Monitoring**: ArgoCD application health and sync status
- **Infrastructure Monitoring**: Proxmox and Talos system metrics

## 🔧 Customization

### Adding New Clusters

1. Create new directory in `terraform/spokes/`
2. Copy configuration from existing spoke cluster
3. Update `terraform.tfvars` with cluster-specific values
4. Add cluster configuration to `gitops/clusters/`
5. Deploy using `./deploy.sh`

### Adding New Applications

1. Create application configuration in `gitops/workloads/`
2. Define Helm values and manifests
3. Configure ApplicationSet to include new application
4. Commit and push changes (ArgoCD will sync automatically)

### Environment Management

Environments are managed through the `gitops/environments/` directory:
- **default/**: Base configuration for all environments
- **dev/**: Development environment overrides
- **staging/**: Staging environment configuration
- **prod/**: Production environment settings

## 🏷️ Key Features

- **Declarative Infrastructure**: Everything defined as code
- **GitOps Driven**: All changes through Git workflows
- **Multi-Cluster Management**: Centralized control of multiple Kubernetes clusters
- **Automated Deployment**: Single command cluster deployment
- **Secret Management**: Secure 1Password integration
- **Reproducible Environments**: Nix-based development environment
- **Comprehensive Tooling**: Custom scripts for common operations

## 📚 Additional Resources

- **Terraform Documentation**: Auto-generated documentation in module directories
- **GitOps Bridge**: Based on [GitOps Bridge](https://github.com/gitops-bridge-dev/gitops-bridge) patterns
- **Talos Kubernetes**: [Official Talos Documentation](https://www.talos.dev/)
- **ArgoCD**: [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test in development environment
4. Submit pull request with clear description

## ⚠️ Security Notes

- **Secrets**: Never commit secrets to the repository
- **Access Control**: Use proper RBAC for cluster access
- **Network Security**: Configure appropriate network policies
- **Regular Updates**: Keep all components updated for security patches

---

This homelab infrastructure provides a solid foundation for learning and experimenting with modern cloud-native technologies while maintaining production-ready practices and patterns.