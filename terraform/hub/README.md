# Hub Cluster - GitOps Control Plane

The Hub Cluster serves as the **central control plane** for the entire GitOps homelab infrastructure. It hosts ArgoCD, External Secrets Operator, and manages all spoke clusters in the environment.

## 🎯 Purpose and Role

### Primary Functions
- **GitOps Control Plane**: ArgoCD for application lifecycle management
- **Secret Management**: 1Password Connect and External Secrets Operator
- **Multi-Cluster Management**: Registration and management of spoke clusters
- **DNS Management**: Cloudflare integration for service discovery
- **Certificate Management**: Automated TLS certificate provisioning

### Cluster Characteristics
- **High Availability**: 3-node control plane for production readiness
- **Resource Optimized**: Efficient resource allocation for management workloads
- **Network Segmented**: Isolated VLAN for security
- **Persistent Storage**: Dedicated storage for ArgoCD and other stateful services

## 🏗️ Infrastructure Configuration

### Node Architecture
```
Control Plane Nodes (3x):
├── talos-controlplane-1 (10.0.5.101)
├── talos-controlplane-2 (10.0.5.102)
└── talos-controlplane-3 (10.0.5.103)

Cluster Endpoint: 10.0.5.100 (VIP)
Network: 10.0.5.0/24 (VLAN 25)
```

### Resource Allocation
| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Control Plane Node | 2-4 cores | 4-8GB | 32GB+ |
| ArgoCD | 0.5 cores | 1GB | 10GB |
| External Secrets | 0.1 cores | 128MB | - |
| 1Password Connect | 0.1 cores | 64MB | - |

## 📂 File Structure

```
hub/
├── cluster.tf          # Main cluster configuration
├── deploy.sh           # Automated deployment script
├── external-secrets-operator.tf  # Secret management setup
├── outputs.tf          # Cluster outputs
├── terraform.tfvars    # Hub-specific configuration
├── variables.tf        # Input variables
└── versions.tf         # Provider requirements
```

## ⚙️ Configuration Details

### Core Cluster Settings
```hcl
# Network Configuration
ip_base             = "10.0.5.0"
cidr                = 24
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.5.100"
nameservers         = ["1.1.1.1", "10.0.0.1"]

# Cluster Identity
cluster_name = "cp-cluster"
allow_scheduling_on_controlplane = true
```

### Node Configuration
```hcl
nodes = {
  "10.0.5.101" = {
    name         = "talos-controlplane-1"
    controlplane = true
    create_vm    = false  # Pre-existing VMs
    networks = [{
      vlan = 25           # Management VLAN
    }]
  }
  # Additional control plane nodes...
}
```

### GitOps Configuration
```hcl
gitops_addons_org      = "https://github.com/jamesatintegratnio"
gitops_addons_repo     = "gitops-homelab"
gitops_addons_basepath = "gitops/"
gitops_addons_path     = "bootstrap/control-plane/addons"
gitops_addons_revision = "main"
```

## 🚀 Deployment Process

### Quick Deployment
```bash
cd terraform/hub
./deploy.sh
```

### Manual Deployment
```bash
# Initialize and apply
tofu init --upgrade
tofu plan
tofu apply

# Verify deployment
export KUBECONFIG=./kubeconfig
kubectl get nodes
kubectl get pods -n argocd
```

### Post-Deployment Verification
```bash
# Check cluster health
kubectl get nodes -o wide
kubectl get pods -A

# Verify ArgoCD
kubectl get applications -n argocd
kubectl get ingress -n argocd

# Check External Secrets
kubectl get externalsecrets -A
kubectl get secretstores -A
```

## 🔐 Security Configuration

### 1Password Connect Integration
The hub cluster integrates with 1Password Connect for secure secret management:

```yaml
# External Secrets Store Configuration
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: onepassword-connect
spec:
  provider:
    onepassword:
      connectHost: "http://op-connect:8080"
      vaults:
        homelab: 1
      auth:
        secretRef:
          connectToken:
            name: op-credentials
            key: token
```

### Secret Management Workflow
1. **Secrets Storage**: Secrets stored in 1Password vault
2. **External Secrets**: Operator syncs secrets to Kubernetes
3. **ArgoCD Integration**: Applications use synced secrets
4. **Automatic Rotation**: External Secrets handles rotation

## 🌐 Network and DNS

### Cloudflare DNS Records
Automatically managed DNS records for cluster services:
```hcl
cloudflare_records = {
  "argocd" = {
    name    = "argocd.integratn.tech"
    type    = "A"
    content = "10.0.5.200"
    proxied = false
    ttl     = 1
  }
  "api" = {
    name    = "api.cp-cluster.integratn.tech"
    type    = "A"
    content = "10.0.5.100"
    proxied = false
    ttl     = 1
  }
}
```

### Ingress Configuration
- **ArgoCD UI**: `https://argocd.integratn.tech`
- **Kubernetes API**: `https://api.cp-cluster.integratn.tech:6443`
- **Grafana**: `https://grafana.integratn.tech`

## 🔄 GitOps Workflow

### ArgoCD Applications
The hub cluster manages several ArgoCD applications:

#### Control Plane Applications
- **External Secrets Operator**: Secret management
- **Cert Manager**: Certificate automation
- **Ingress Controller**: Traffic routing
- **Monitoring Stack**: Observability tools

#### Cluster Management Applications
- **Cluster ApplicationSet**: Manages spoke cluster configurations
- **Addon ApplicationSet**: Deploys infrastructure addons
- **Workload ApplicationSet**: Manages application workloads

### Application Deployment Flow
```
Git Repository → ArgoCD → Kubernetes Resources
     ↓              ↓            ↓
Configuration → Sync Status → Running Applications
```

## 🔧 Operations and Maintenance

### Regular Tasks

#### Health Monitoring
```bash
# Check cluster status
kubectl get nodes
kubectl top nodes

# Monitor ArgoCD
kubectl get applications -n argocd
argocd app list

# Check secrets sync
kubectl get externalsecrets -A
```

#### Updates and Maintenance
```bash
# Update Talos
talosctl upgrade --image=ghcr.io/siderolabs/talos:v1.8.1

# Update applications
argocd app sync --all

# Backup ArgoCD configuration
kubectl get applications -n argocd -o yaml > argocd-backup.yaml
```

### Troubleshooting

#### Common Issues

**ArgoCD Sync Failures**
```bash
# Check application status
argocd app get <app-name>

# Force refresh and sync
argocd app refresh <app-name>
argocd app sync <app-name>
```

**External Secrets Issues**
```bash
# Check secret store connectivity
kubectl describe secretstore onepassword-connect

# Force secret refresh
kubectl annotate externalsecret <secret-name> force-sync=$(date +%s) --overwrite
```

**Network Connectivity**
```bash
# Test cluster endpoint
curl -k https://10.0.5.100:6443/healthz

# Check DNS resolution
nslookup argocd.integratn.tech
```

## 📊 Monitoring and Observability

### Key Metrics
- **Cluster Health**: Node status, resource utilization
- **ArgoCD Health**: Application sync status, sync frequency
- **Secret Sync**: External Secrets sync status
- **DNS Health**: Cloudflare record status

### Monitoring Stack
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notification

## 🔄 Backup and Recovery

### ArgoCD Backup
```bash
# Backup ArgoCD applications
argocd admin export > argocd-backup.yaml

# Backup repositories and settings
kubectl get configmap argocd-cmd-params-cm -n argocd -o yaml > argocd-config-backup.yaml
```

### Disaster Recovery
1. **Infrastructure**: Redeploy using Terraform
2. **ArgoCD**: Restore from backup
3. **Secrets**: Re-sync from 1Password
4. **Applications**: ArgoCD auto-sync handles restoration

## 🎯 Best Practices

### Security
- Regular secret rotation through External Secrets
- Network segmentation with VLANs
- RBAC for ArgoCD applications
- TLS everywhere with cert-manager

### Operations
- Monitor ArgoCD sync status
- Regular cluster health checks
- Automated backups
- Documentation as code

### Development
- GitOps workflow for all changes
- Infrastructure as Code
- Immutable infrastructure patterns
- Observability-first approach

The Hub Cluster serves as the foundation of the GitOps homelab, providing centralized management and control for the entire infrastructure while maintaining security, scalability, and operational excellence.