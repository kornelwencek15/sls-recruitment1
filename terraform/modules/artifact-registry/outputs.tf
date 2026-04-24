output "repository_url" {
  description = "Full Artifact Registry repository URL (use as Docker image prefix)"
  value       = "${google_artifact_registry_repository.main.location}-docker.pkg.dev/${google_artifact_registry_repository.main.project}/${google_artifact_registry_repository.main.repository_id}"
}

output "repository_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.main.repository_id
}
