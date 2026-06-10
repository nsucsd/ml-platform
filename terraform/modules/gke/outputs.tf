# terraform/modules/gke/outputs.tf

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE cluster API endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
  # sensitive = true means Terraform won't print this in logs
  # The endpoint URL contains auth info — keep it private
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate for kubectl"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE cluster region"
  value       = google_container_cluster.primary.location
}

output "node_pool_name" {
  description = "Node pool name"
  value       = google_container_node_pool.primary_nodes.name
}

output "workload_identity_pool" {
  description = "Workload identity pool — used for pod IAM bindings"
  value       = "${var.project_id}.svc.id.goog"
}