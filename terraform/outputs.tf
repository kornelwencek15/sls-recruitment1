output "get_credentials_command" {
  description = "Run this to configure kubectl for the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${module.gke.location} --project ${var.project_id}"
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL (use as Docker image prefix)"
  value       = module.artifact_registry.repository_url
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name for the Auth Proxy — set as CLOUD_SQL_CONNECTION_NAME in GitHub Actions secrets"
  value       = module.cloud_sql.connection_name
}

output "app_sa_email" {
  description = "Application service account email — set as GCP_APP_SA_EMAIL in GitHub Actions secrets"
  value       = google_service_account.app.email
}

output "wif_provider" {
  description = "Workload Identity Federation provider — set as GCP_WIF_PROVIDER in GitHub Actions secrets"
  value       = module.github_actions_wif.wif_provider
}

output "github_actions_sa_email" {
  description = "GitHub Actions service account email — set as GCP_SA_EMAIL in GitHub Actions secrets"
  value       = module.github_actions_wif.sa_email
}

output "terraform_sa_email" {
  description = "Terraform ops service account email — set as GCP_TERRAFORM_SA_EMAIL in GitHub Actions secrets"
  value       = module.github_actions_wif.terraform_sa_email
}

# Admin-only: for running migrations or manual DB inspection
output "db_admin_password" {
  description = "postgres user password (admin access only, never used by the application)"
  value       = module.cloud_sql.admin_password
  sensitive   = true
}
