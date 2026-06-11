# terraform/environments/dev/outputs.tf

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "bucket_names" {
  description = "GCS bucket names"
  value       = module.storage.bucket_names
}

output "network_name" {
  description = "VPC network name"
  value       = module.networking.network_name
}

output "service_account_email" {
  description = "ML inference service account"
  value       = module.iam.service_account_email
}

output "grafana_access_command" {
  description = "Access Grafana locally"
  value       = module.monitoring.grafana_access_command
}

output "kubectl_config_command" {
  description = "Configure kubectl"
  value       = "gcloud container clusters get-credentials ml-platform-cluster-${var.environment} --region ${var.region} --project ${var.project_id}"
}