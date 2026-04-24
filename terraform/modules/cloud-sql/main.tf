resource "random_password" "db" {
  length  = 32
  special = false
}

resource "google_sql_database_instance" "main" {
  name             = "${var.name_prefix}-postgres"
  database_version = "POSTGRES_15"
  region           = var.region

  deletion_protection = var.deletion_protection

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled       = false
      private_network    = var.network_id
      allocated_ip_range = var.private_service_access_range_name
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }

    insights_config {
      query_insights_enabled = true
    }
  }
}

resource "google_sql_database" "app" {
  name     = "devops_db"
  instance = google_sql_database_instance.main.name
}

# Password user kept for admin access (migrations, manual inspection)
resource "google_sql_user" "admin" {
  name     = "postgres"
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}

# IAM user for the application — authenticates via Workload Identity, no password
resource "google_sql_user" "app_iam" {
  name     = trimsuffix(var.app_sa_email, ".gserviceaccount.com")
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
