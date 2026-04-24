resource "google_artifact_registry_repository" "main" {
  repository_id = var.name_prefix
  format        = "DOCKER"
  location      = var.region
  description   = "Docker images for ${var.name_prefix}"
}
