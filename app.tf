resource "kubernetes_pod" "test" {
  metadata {
    name = "test"
  }

  spec {
    automount_service_account_token = true
    container {
      image = "nginx:alpine"
      name  = "pyproject"
    }
  }
}
