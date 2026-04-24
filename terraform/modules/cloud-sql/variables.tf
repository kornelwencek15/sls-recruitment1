variable "region" {
  description = "GCP region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
}

variable "network_id" {
  description = "VPC network ID for private IP allocation"
  type        = string
}

variable "private_service_access_range_name" {
  description = "Name of the allocated IP range used for Cloud SQL private IP (from the vpc module)"
  type        = string
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-g1-small"
}

variable "deletion_protection" {
  description = "Prevent accidental instance deletion"
  type        = bool
  default     = false
}

variable "app_sa_email" {
  description = "Application service account email used to create the IAM database user"
  type        = string
}
