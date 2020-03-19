resource "google_container_cluster" "container_cluster" {
  name               = "container-cluster"
  project            = google_project.demoproject.project_id
  location           = var.projectzone
  initial_node_count = 4

  node_config {
    preemptible = true
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.container_cluster.name} --zone ${var.projectzone} --project ${google_project.demoproject.project_id}"
  }
}

provider "kubernetes" {
  host     = google_container_cluster.container_cluster.endpoint
  username = google_container_cluster.container_cluster.master_auth[0].username
  password = google_container_cluster.container_cluster.master_auth[0].password
  cluster_ca_certificate = base64decode(
    google_container_cluster.container_cluster.master_auth[0].cluster_ca_certificate,
  )
}

output "k8s_endpoint" {
  value = google_container_cluster.container_cluster.endpoint
}
