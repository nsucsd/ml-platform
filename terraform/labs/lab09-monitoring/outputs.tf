# terraform/labs/lab09-monitoring/outputs.tf

output "grafana_access_command" {
  description = "Run this to access Grafana in your browser"
  value       = module.monitoring.grafana_access_command
}

output "prometheus_access_command" {
  description = "Run this to access Prometheus in your browser"
  value       = module.monitoring.prometheus_access_command
}

output "monitoring_namespace" {
  value = module.monitoring.namespace
}