# terraform/modules/gke/variables.tf

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "ml-platform-cluster"
}

variable "network_self_link" {
  description = "VPC network self link — from networking module output"
  type        = string
}

variable "subnet_self_link" {
  description = "Subnet self link — from networking module output"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods — from networking module output"
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services — from networking module output"
  type        = string
}

variable "min_node_count" {
  description = "Minimum nodes in the node pool"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes in the node pool"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "GCE machine type for nodes"
  type        = string
  default     = "e2-standard-2"
  # e2-standard-2 = 2 vCPU, 8GB RAM
  # cheap enough for dev, enough for running pods
}

variable "labels" {
  description = "Labels to apply to cluster resources"
  type        = map(string)
  default     = {}
}