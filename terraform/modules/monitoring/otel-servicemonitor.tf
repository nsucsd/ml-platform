# terraform/modules/monitoring/otel-servicemonitor.tf

resource "kubernetes_manifest" "otel_collector_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "otel-collector"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        release = "kube-prometheus-stack"
        # ↑ CRITICAL — kube-prometheus-stack's Prometheus instance
        #   only watches ServiceMonitors with this label
        #   without it, Prometheus ignores this ServiceMonitor entirely
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "otel-collector"
        }
      }
      endpoints = [
        {
          port     = "prometheus"
          interval = "15s"
          path     = "/metrics"
        }
      ]
    }
  }

  depends_on = [
    kubernetes_service.otel_collector,
    helm_release.kube_prometheus_stack
  ]
}