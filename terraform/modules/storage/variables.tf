# terraform/modules/storage/variables.tf

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

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable object versioning on buckets"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to all buckets"
  type        = map(string)
  default     = {}
}