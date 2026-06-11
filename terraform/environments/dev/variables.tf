# terraform/environments/dev/variables.tf

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "min_node_count" {
  description = "Minimum GKE nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum GKE nodes"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-2"
}# CI/CD test
