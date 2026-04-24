locals {
  required_apis = [
    "container.googleapis.com",           # GKE
    "sqladmin.googleapis.com",            # Cloud SQL
    "servicenetworking.googleapis.com",   # Private service access (VPC peering for Cloud SQL)
    "artifactregistry.googleapis.com",    # Artifact Registry
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",      # Workload Identity Federation
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  service            = each.value
  disable_on_destroy = false
}
