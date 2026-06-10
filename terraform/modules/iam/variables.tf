# terraform/modules/iam/variables.tf

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "bucket_names" {
  description = "Map of bucket names to grant access to"
  type        = map(string)
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

# ADD to terraform/modules/iam/variables.tf

variable "kubernetes_namespace" {
  description = "Kubernetes namespace where the service account lives"
  type        = string
  default     = "ml-platform"
}