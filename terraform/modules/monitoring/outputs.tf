# terraform/modules/monitoring/outputs.tf

output "namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_service_name" {
  description = "Grafana service name for port-forwarding"
  value       = "kube-prometheus-stack-grafana"
}

output "prometheus_service_name" {
  description = "Prometheus service name for port-forwarding"
  value       = "kube-prometheus-stack-prometheus"
}

output "grafana_access_command" {
  description = "Command to access Grafana locally"
  value       = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n ${var.namespace}"
}

output "prometheus_access_command" {
  description = "Command to access Prometheus locally"
  value       = "kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n ${var.namespace}"
}