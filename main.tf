provider "google" {}
provider "random" {}

resource "random_pet" "random_id" {
  prefix = "tam-k8s-auth-demo"
}

data "google_folder" "folder" {
  folder = var.folderid
}

output "folder" {
  value = data.google_folder.folder.display_name
}

resource "google_project" "demoproject" {
  name            = "Demo Project"
  project_id      = random_pet.random_id.id
  folder_id       = data.google_folder.folder.id
  billing_account = var.billingaccount
}

resource "google_project_service" "container_api_service" {
  project            = google_project.demoproject.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging_api_service" {
  project = google_project.demoproject.project_id
  service = "logging.googleapis.com"
}

resource "google_project_service" "monitoring_api_service" {
  project = google_project.demoproject.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "stackdriver_api_service" {
  project = google_project.demoproject.project_id
  service = "stackdriver.googleapis.com"
}

