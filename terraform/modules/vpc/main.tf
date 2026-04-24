resource "google_compute_network" "main" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  name          = "${var.name_prefix}-gke-subnet"
  network       = google_compute_network.main.id
  region        = var.region
  ip_cidr_range = "10.10.0.0/24"

  # Secondary ranges are required for VPC-native (alias IP) GKE clusters
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# Cloud NAT allows private GKE nodes (no public IPs) to reach the internet
resource "google_compute_router" "main" {
  name    = "${var.name_prefix}-router"
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_router_nat" "main" {
  name                               = "${var.name_prefix}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Private service access: reserves an IP range in our VPC so Google can assign
# Cloud SQL a private IP that is directly reachable from GKE pods
resource "google_compute_global_address" "private_service_access" {
  name          = "${var.name_prefix}-private-service-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_service_access" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access.name]
}
