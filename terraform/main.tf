module "vpc" {
  source      = "./modules/vpc"
  region      = var.region
  name_prefix = var.name_prefix

  depends_on = [google_project_service.apis]
}

module "gke" {
  source       = "./modules/gke"
  project_id   = var.project_id
  region       = var.region
  name_prefix  = var.name_prefix
  network_id   = module.vpc.network_id
  subnet_id    = module.vpc.gke_subnet_id
  machine_type = var.gke_machine_type
  min_nodes    = var.gke_min_nodes
  max_nodes    = var.gke_max_nodes

  depends_on = [google_project_service.apis]
}

# Service account used by the application pods.
# Bound to the Kubernetes ServiceAccount via Workload Identity —
# no key file, no static credentials.
resource "google_service_account" "app" {
  account_id   = "${var.name_prefix}-app"
  display_name = "${var.name_prefix} Application"
}

resource "google_project_iam_member" "app_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_project_iam_member" "app_cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.app.email}"
}

# Allows the Kubernetes ServiceAccount "<namespace>/<name>" to impersonate this GCP SA
resource "google_service_account_iam_member" "app_wif" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.name_prefix}/${var.name_prefix}]"
}

module "cloud_sql" {
  source                            = "./modules/cloud-sql"
  region                            = var.region
  name_prefix                       = var.name_prefix
  network_id                        = module.vpc.network_id
  private_service_access_range_name = module.vpc.private_service_access_range_name
  app_sa_email                      = google_service_account.app.email
  db_tier                           = var.db_tier
  deletion_protection               = var.db_deletion_protection

  depends_on = [module.vpc, google_project_service.apis]
}

module "artifact_registry" {
  source      = "./modules/artifact-registry"
  region      = var.region
  name_prefix = var.name_prefix

  depends_on = [google_project_service.apis]
}

module "github_actions_wif" {
  source            = "./modules/github-actions-wif"
  project_id        = var.project_id
  github_repository = var.github_repository

  depends_on = [google_project_service.apis]
}
