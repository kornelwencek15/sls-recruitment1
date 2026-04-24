output "connection_name" {
  description = "Cloud SQL connection name used by the Auth Proxy (project:region:instance)"
  value       = google_sql_database_instance.main.connection_name
}

output "instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.main.name
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.app.name
}

# Exposed for admin access only (migrations, manual inspection) — never used by the app
output "admin_password" {
  description = "Admin (postgres) user password"
  value       = random_password.db.result
  sensitive   = true
}
