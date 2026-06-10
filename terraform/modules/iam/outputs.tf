# terraform/modules/iam/outputs.tf

output "service_account_email" {
  description = "Service account email"
  value       = google_service_account.ml_inference.email
}

output "service_account_id" {
  description = "Service account resource ID"
  value       = google_service_account.ml_inference.id
}