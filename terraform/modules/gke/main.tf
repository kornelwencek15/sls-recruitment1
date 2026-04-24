resource "google_service_account" "nodes" {
  account_id   = "${var.name_prefix}-gke-nodes"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_container_cluster" "main" {
  name               = "${var.name_prefix}-cluster"
  location           = var.region

  network    = var.network_id
  subnetwork = var.subnet_id

  # Node pool is managed separately for independent lifecycle control.
  # node_config here only applies to the temporary default pool that GKE requires
  # during cluster creation — it is deleted immediately after.
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    disk_size_gb = 32
    machine_type = var.machine_type
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Private nodes have no public IPs; Cloud NAT handles egress.
  # The control plane remains publicly reachable so CI/CD can run kubectl.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "main" {
  name     = "${var.name_prefix}-nodes"
  cluster  = google_container_cluster.main.name
  location = var.region

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = 32
    service_account = google_service_account.nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
