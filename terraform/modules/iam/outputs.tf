# terraform/modules/iam/outputs.tf

output "service_account_email" {
  description = "Service account email"
  value       = google_service_account.ml_inference.email
}

output "service_account_id" {
  description = "Service account resource ID"
  value       = google_service_account.ml_inference.id
}

# ADD to terraform/modules/iam/outputs.tf

output "kubernetes_service_account_name" {
  description = "Kubernetes service account name"
  value       = kubernetes_service_account.ml_inference.metadata[0].name
}

output "kubernetes_namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_service_account.ml_inference.metadata[0].namespace
}