# terraform/modules/monitoring/main.tf

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace

    labels = merge(
      {
        environment = var.environment
        managed-by  = "terraform"
        purpose     = "monitoring"
      },
      var.labels
    )
  }
}

# kube-prometheus-stack — industry standard monitoring stack
# Includes: Prometheus, Grafana, Alertmanager, Node Exporter
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.0.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  wait    = true
  timeout = 600
  # wait = true means Terraform waits until all pods are Running
  # timeout = 600 seconds (10 min) — Helm charts can take time

  # Grafana configuration
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name  = "grafana.persistence.size"
    value = var.grafana_storage_size
  }

  # Prometheus configuration
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "${var.prometheus_retention_days}d"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_storage_size
  }

  # Enable node exporter — scrapes CPU, memory, disk from nodes
  set {
    name  = "nodeExporter.enabled"
    value = "true"
  }

  # Enable kube-state-metrics — scrapes K8s object metrics
  set {
    name  = "kubeStateMetrics.enabled"
    value = "true"
  }

  depends_on = [kubernetes_namespace.monitoring]
}