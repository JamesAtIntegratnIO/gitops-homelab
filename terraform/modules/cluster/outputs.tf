output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this
  sensitive = true
}

output "cluster_name" {
  value = var.cluster_name
}
