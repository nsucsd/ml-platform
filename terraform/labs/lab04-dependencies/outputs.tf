# outputs.tf

output "service_account_email" {
  description = "Email of the ML inference service account"
  value       = google_service_account.ml_inference.email
}

output "service_account_id" {
  description = "Full resource ID of the service account"
  value       = google_service_account.ml_inference.id
}

output "project_number" {
  description = "GCP project number — read from data source"
  value       = data.google_project.current.number
}

output "project_name" {
  description = "GCP project name — read from data source"
  value       = data.google_project.current.name
}

output "bucket_access_granted" {
  description = "Buckets the service account can access"
  value       = local.existing_buckets
}