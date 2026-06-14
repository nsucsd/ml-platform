# terraform/modules/monitoring/otel-collector.tf

resource "kubernetes_config_map" "otel_collector_config" {
  metadata {
    name      = "otel-collector-config"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "config.yaml" = <<-EOT
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
            http:
              endpoint: 0.0.0.0:4318

      processors:
        batch:
          timeout: 10s

      exporters:
        prometheus:
          endpoint: 0.0.0.0:8889
          # Prometheus scrapes this endpoint
        debug:
          verbosity: detailed
          # Useful for debugging — prints telemetry to Collector logs

      service:
        pipelines:
          traces:
            receivers: [otlp]
            processors: [batch]
            exporters: [debug]
            # In production traces would go to Tempo, Jaeger, or New Relic
            # debug exporter lets us SEE traces are arriving for this lab

          metrics:
            receivers: [otlp]
            processors: [batch]
            exporters: [prometheus, debug]
    EOT
  }
}

resource "kubernetes_deployment" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels    = { app = "otel-collector" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = "otel-collector" }
    }

    template {
      metadata {
        labels = { app = "otel-collector" }
      }

      spec {
        container {
          name  = "otel-collector"
          image = "otel/opentelemetry-collector-contrib:0.103.0"

          args = ["--config=/etc/otel/config.yaml"]

          port {
            container_port = 4317
            name           = "otlp-grpc"
          }
          port {
            container_port = 4318
            name           = "otlp-http"
          }
          port {
            container_port = 8889
            name           = "prometheus"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/otel"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.otel_collector_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels    = { app = "otel-collector" }

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "8889"
    }
  }

  spec {
    selector = { app = "otel-collector" }

    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = 4317
    }
    port {
      name        = "otlp-http"
      port        = 4318
      target_port = 4318
    }
    port {
      name        = "prometheus"
      port        = 8889
      target_port = 8889
    }
  }
}