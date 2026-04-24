output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.main.id
}

output "network_self_link" {
  description = "VPC network self-link"
  value       = google_compute_network.main.self_link
}

output "gke_subnet_id" {
  description = "GKE subnet ID"
  value       = google_compute_subnetwork.gke.id
}

output "private_service_access_range_name" {
  description = "Name of the allocated IP range for Cloud SQL private IP"
  value       = google_compute_global_address.private_service_access.name
}

# Exposing the connection ID allows other modules to declare an implicit
# dependency on the VPC peering being established before Cloud SQL is created.
output "private_service_access_id" {
  description = "ID of the private service networking connection"
  value       = google_service_networking_connection.private_service_access.id
}
