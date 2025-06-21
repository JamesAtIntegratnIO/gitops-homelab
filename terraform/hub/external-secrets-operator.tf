resource "kubernetes_namespace" "external_secrets" {
  metadata {
    annotations = {
      name = "external-secrets"
    }
    name = "external-secrets"
  }
  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_secret" "eso_onepassword_token" {
  metadata {
    name      = "eso-onepassword-token"
    namespace = kubernetes_namespace.external_secrets.metadata.0.name
  }
  data = {
    token = var.onepassword_token
  }
  depends_on = [kubernetes_namespace.external_secrets]
}

