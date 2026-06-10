# terraform/modules/networking/outputs.tf

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "VPC network self link — used by GKE"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_self_link" {
  description = "Subnet self link — used by GKE"
  value       = google_compute_subnetwork.subnet.self_link
}

output "pods_range_name" {
  description = "Secondary range name for GKE pods"
  value       = "pods"
}

output "services_range_name" {
  description = "Secondary range name for GKE services"
  value       = "services"
}