resource "proxmox_vm_qemu" "nodes" {
  for_each    = { for idx, node in var.nodes : idx => node if node.create_vm == true }
  name        = each.value.name
  target_node = each.value.target_node_name


  agent                  = 1
  agent_timeout          = 90
  define_connection_info = false
  os_type                = "cloud-init"
  clone                  = "talos-1.7.5-template"
  qemu_os                = "l26"
  # ipconfig0              = "ip=${each.key}/${var.cidr},gw=${var.gateway}"

  onboot  = false
  cpu     = "host,flags=+aes"
  sockets = each.value.cpu_sockets
  cores   = each.value.cpu_cores
  memory  = each.value.memory
  scsihw  = "virtio-scsi-pci"

  # cluster-names are only allowed to have `-` while tags are only allowed to have `_`
  tags = join(",", concat([replace(var.cluster_name, "-", "_"),
    each.value.controlplane ? "controlplane" : "worker"], 
    [for s in var.tags : replace(s, "-", "_")]))

  vga {
    memory = 0
    type   = "virtio"
  }
  serial {
    id   = 0
    type = "socket"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = each.value.macaddr
  }

  boot = "order=scsi0;ide2;net0"

  disks {
    scsi {
      scsi0 {
        cdrom {
          iso = var.proxmox_image
        }
      }
    }
    ide {
      ide2 {
        disk {
          size    = each.value.disk_size
          storage = var.proxmox_storage
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      boot,
      network,
      desc,
      numa,
      agent,
      ipconfig0,
      ipconfig1,
      define_connection_info,
    ]
  }
}
