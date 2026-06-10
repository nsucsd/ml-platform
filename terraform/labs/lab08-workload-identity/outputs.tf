# terraform/labs/lab08-workload-identity/outputs.tf

output "kubernetes_namespace" {
  description = "Kubernetes namespace created"
  value       = kubernetes_namespace.ml_platform.metadata[0].name
}

output "kubernetes_service_account" {
  description = "Kubernetes service account name"
  value       = module.iam.kubernetes_service_account_name
}

output "gcp_service_account_email" {
  description = "GCP service account email"
  value       = module.iam.service_account_email
}

output "workload_identity_annotation" {
  description = "Annotation to add to any K8s SA that needs GCP access"
  value       = "iam.gke.io/gcp-service-account: ${module.iam.service_account_email}"
}