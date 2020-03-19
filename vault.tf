provider helm {
  kubernetes {
    host     = google_container_cluster.container_cluster.endpoint
    username = google_container_cluster.container_cluster.master_auth[0].username
    password = google_container_cluster.container_cluster.master_auth[0].password
    cluster_ca_certificate = base64decode(
      google_container_cluster.container_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "local_file" "vault_clone" {
  content  = ""
  filename = "vault-helm-touch"

  provisioner "local-exec" {
    command = "git clone git@github.com:hashicorp/vault-helm.git"
  }
}

resource "helm_release" "vault" {
  name  = "my-vault"
  chart = "./vault-helm"

  set {
    name  = "server.dev.enabled"
    value = "true"
  }
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name = "vault-auth"
  }
}

resource "kubernetes_cluster_role_binding" "vault" {
  metadata {
    name = "role-tokenreview-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.vault.metadata[0].name
  }
}

data "kubernetes_secret" "vault_k8s_auth_token" {
  metadata {
    name = kubernetes_service_account.vault.default_secret_name
  }
}

output "vault_k8s_auth_ca_crt" {
  value = data.kubernetes_secret.vault_k8s_auth_token.data["ca.crt"]
}

output "vault_k8s_auth_token" {
  value = data.kubernetes_secret.vault_k8s_auth_token.data.token
}
