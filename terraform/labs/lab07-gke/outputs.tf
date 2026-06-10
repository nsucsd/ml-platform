# terraform/labs/lab07-gke/outputs.tf

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_location" {
  description = "GKE cluster location"
  value       = module.gke.cluster_location
}

output "node_pool_name" {
  description = "Node pool name"
  value       = module.gke.node_pool_name
}

output "workload_identity_pool" {
  description = "Workload identity pool"
  value       = module.gke.workload_identity_pool
}

output "kubectl_config_command" {
  description = "Run this to configure kubectl after cluster is ready"
  value       = "gcloud container clusters get-credentials ml-platform-cluster-dev --region us-central1 --project ${var.project_id}"
}