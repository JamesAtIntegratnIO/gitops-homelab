resource "kubernetes_namespace" "op_connect" {
  metadata {
    annotations = {
      name = "op-connect"
    }
    name = "op-connect"
  }
  depends_on = [time_sleep.wait_for_cluster]
}

resource "kubernetes_secret" "op_credentials" {
  metadata {
    name      = "op-credentials"
    namespace = kubernetes_namespace.op_connect.metadata.0.name
  }
  data = {
    "1password-credentials.json" = var.onepassword_credentials
  }
  depends_on = [kubernetes_namespace.op_connect]
}

resource "kubernetes_secret" "onepassword_token" {
  metadata {
    name      = "onepassword-token"
    namespace = kubernetes_namespace.op_connect.metadata.0.name
  }
  data = {
    token = var.onepassword_token
  }
  depends_on = [kubernetes_namespace.op_connect]
}