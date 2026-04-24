variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "subnet_id" {
  description = "GKE subnet ID"
  type        = string
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "min_nodes" {
  description = "Minimum number of nodes per zone"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes per zone"
  type        = number
  default     = 3
}
