# Terraform Modules Documentation

This directory contains reusable Terraform modules for the GitOps homelab infrastructure.

## 📁 Module Structure

### Cluster Module (`cluster/`)

The core module responsible for deploying Talos Kubernetes clusters on Proxmox.

#### Files Overview
- `proxmox-nodes.tf` - VM provisioning and configuration
- `talos.tf` - Talos machine configuration and bootstrap
- `versions.tf` - Provider requirements and versions
- `variables.tf` - Input variables and configuration options
- `outputs.tf` - Output values (kubeconfig, talosconfig)
- `templates/` - Talos configuration templates

#### Key Features
- **Multi-node Support**: Deploy control plane and worker nodes
- **VM Customization**: CPU, memory, storage, and network configuration
- **Template Cloning**: Uses pre-built Talos VM templates
- **Network Configuration**: VLAN support and static IP assignment
- **GPU Passthrough**: Optional NVIDIA GPU support
- **Flexible Node Roles**: Control plane and worker node designation

#### Usage Example
```hcl
module "cluster" {
  source = "./modules/cluster"

  cluster_name        = "my-cluster"
  cluster_endpoint_ip = "10.0.5.100"
  ip_base            = "10.0.5.0"
  cidr               = 24
  gateway            = "10.0.0.1"
  
  nodes = {
    "10.0.5.101" = {
      name         = "control-1"
      controlplane = true
      cpu_cores    = 4
      memory       = 8192
      networks = [{
        vlan = 25
      }]
    }
    "10.0.5.102" = {
      name      = "worker-1"
      cpu_cores = 2
      memory    = 4096
    }
  }
}
```

### Cloudflare Module (`cloudflare/`)

Manages DNS records in Cloudflare for cluster services and ingress.

#### Files Overview
- `main.tf` - Cloudflare resource definitions
- `variables.tf` - Input variables
- `versions.tf` - Provider requirements

#### Key Features
- **Automated DNS Management**: Creates A, CNAME, and other records
- **Wildcard Support**: Supports wildcard domains for ingress
- **Proxy Configuration**: Cloudflare proxy and CDN settings
- **TTL Management**: Configurable TTL values

#### Usage Example
```hcl
module "cloudflare" {
  source = "./modules/cloudflare"

  cloudflare_zone_name = "example.com"
  cloudflare_records = {
    "api" = {
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
}
```

## 🔧 Module Variables

### Common Variables Across Modules

#### Network Configuration
- `ip_base` - Base IP address for the cluster network
- `cidr` - Network CIDR block
- `gateway` - Default gateway IP
- `nameservers` - List of DNS servers

#### Cluster Configuration
- `cluster_name` - Name of the Kubernetes cluster
- `cluster_endpoint_ip` - Kubernetes API server endpoint IP
- `allow_scheduling_on_controlplane` - Allow pods on control plane nodes

#### Proxmox Configuration
- `proxmox_image` - Talos ISO image path
- `proxmox_storage` - Storage backend for VMs
- `vm_template` - VM template name for cloning

#### Node Configuration
The `nodes` variable is a map of IP addresses to node configurations:
```hcl
nodes = {
  "IP_ADDRESS" = {
    name             = string               # VM name
    controlplane     = optional(bool)       # Control plane node flag
    cpu_sockets      = optional(number)     # CPU sockets
    cpu_cores        = optional(number)     # CPU cores per socket
    memory           = optional(number)     # RAM in MB
    disk_size        = optional(string)     # Disk size (e.g., "100G")
    target_node_name = optional(string)     # Proxmox node name
    create_vm        = optional(bool)       # Whether to create VM
    nvidia           = optional(bool)       # GPU passthrough
    networks = optional(list(object({       # Network interfaces
      model    = optional(string)           # NIC model
      bridge   = optional(string)           # Bridge name
      vlan     = optional(string)           # VLAN ID
      macaddr  = optional(string)           # MAC address
      firewall = optional(bool)             # Firewall enabled
    })))
  }
}
```

## 🚀 Module Outputs

### Cluster Module Outputs
- `kubeconfig` - Kubernetes configuration for cluster access
- `talosconfig` - Talos configuration for node management
- `cluster_name` - Name of the deployed cluster

### Cloudflare Module Outputs
- DNS records are created automatically (no explicit outputs)

## 🔄 Module Dependencies

### Required Providers
- `proxmox` (Telmate/proxmox) - Proxmox VE management
- `talos` (siderolabs/talos) - Talos Linux configuration
- `kubernetes` (hashicorp/kubernetes) - Kubernetes resources
- `cloudflare` (cloudflare/cloudflare) - DNS management

### External Dependencies
- Pre-existing Talos VM templates in Proxmox
- Proxmox user with appropriate permissions
- Cloudflare zone and API access
- Network infrastructure (VLANs, routing)

## 🏗️ Module Design Principles

### Modularity
- Each module has a single responsibility
- Modules are composable and reusable
- Clear input/output interfaces

### Flexibility
- Optional variables with sensible defaults
- Support for various deployment scenarios
- Configurable resource specifications

### Best Practices
- Immutable infrastructure patterns
- GitOps-ready configurations
- Security-first design
- Documentation as code

## 🔍 Advanced Configuration

### Custom VM Templates
Create custom Talos templates with specific configurations:
```bash
# Download Talos ISO
wget https://github.com/siderolabs/talos/releases/download/v1.8.1/talos-amd64.iso

# Create VM template in Proxmox
qm create 9999 --name talos-1.8.1-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9999 talos-amd64.iso local-zfs
qm set 9999 --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-9999-disk-0
qm set 9999 --boot c --bootdisk scsi0
qm template 9999
```

### Multi-Network Configuration
Configure multiple network interfaces per node:
```hcl
networks = [
  {
    model   = "virtio"
    bridge  = "vmbr0"
    vlan    = "25"
    macaddr = "02:00:00:00:00:01"
  },
  {
    model   = "virtio"
    bridge  = "vmbr1"
    vlan    = "100"
    macaddr = "02:00:00:00:00:02"
  }
]
```

### GPU Passthrough
Enable NVIDIA GPU passthrough for workloads:
```hcl
nodes = {
  "10.0.5.102" = {
    name   = "gpu-worker"
    nvidia = true
    # Additional GPU-specific configuration
  }
}
```

This modular approach ensures consistent deployments across different cluster types while maintaining flexibility for specific use cases.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->