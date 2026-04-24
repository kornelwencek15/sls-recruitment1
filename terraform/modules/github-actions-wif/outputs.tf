output "wif_provider" {
  description = "Full Workload Identity Federation provider resource name"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "sa_email" {
  description = "GitHub Actions service account email (app pipeline: push image, deploy to GKE)"
  value       = google_service_account.github_actions.email
}

output "terraform_sa_email" {
  description = "Terraform service account email (ops pipeline: plan and apply infrastructure)"
  value       = google_service_account.terraform.email
}
