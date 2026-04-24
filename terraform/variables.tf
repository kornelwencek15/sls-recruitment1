variable "project_id" {
  description = "GCP project ID where all resources will be created"
  type        = string
}

variable "region" {
  description = "GCP region for all regional resources"
  type        = string
  default     = "europe-west1"
}

variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "devops-test"
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "gke_min_nodes" {
  description = "Minimum number of nodes per zone in the GKE node pool"
  type        = number
  default     = 1
}

variable "gke_max_nodes" {
  description = "Maximum number of nodes per zone in the GKE node pool"
  type        = number
  default     = 3
}

variable "db_tier" {
  description = "Cloud SQL machine tier (e.g. db-g1-small, db-n1-standard-1)"
  type        = string
  default     = "db-g1-small"
}

variable "db_deletion_protection" {
  description = "Prevent accidental Cloud SQL instance deletion. Set to false only in non-production environments."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository in 'owner/repo' format used to scope Workload Identity Federation"
  type        = string
  default     = "kornelwencek15/sls-recruitment1"
}
