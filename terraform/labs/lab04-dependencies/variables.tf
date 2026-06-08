# variables.tf

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

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "service_account_roles" {
  description = "Roles to grant the ML service account on each bucket"
  type        = list(string)
  default = [
    "roles/storage.objectViewer",
    "roles/storage.objectCreator"
  ]
}