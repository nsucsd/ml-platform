# terraform/modules/monitoring/variables.tf

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  # sensitive = true — never printed in logs or plan output
}

variable "prometheus_retention_days" {
  description = "How many days to retain Prometheus metrics"
  type        = number
  default     = 15
}

variable "grafana_storage_size" {
  description = "Persistent volume size for Grafana"
  type        = string
  default     = "5Gi"
}

variable "prometheus_storage_size" {
  description = "Persistent volume size for Prometheus"
  type        = string
  default     = "10Gi"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}