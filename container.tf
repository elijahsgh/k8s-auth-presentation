resource "local_file" "dockerfile" {
  content  = <<EOF
FROM python:3-alpine
RUN pip install requests
WORKDIR /serve
COPY simple-vault.py /serve
ENTRYPOINT ["python3", "simple-vault.py"]
EOF
  filename = "docker/Dockerfile"

  provisioner "local-exec" {
    command     = "gcloud auth configure-docker; docker build . -t ${data.google_container_registry_repository.container_registry.repository_url}/pyproject:latest; docker push ${data.google_container_registry_repository.container_registry.repository_url}/pyproject:latest"
    working_dir = "docker"
  }
}

data "google_container_registry_repository" "container_registry" {
  project = google_project.demoproject.project_id
}

output "container_registry" {
  value = data.google_container_registry_repository.container_registry.repository_url
}
