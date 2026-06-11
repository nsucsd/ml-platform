# terraform/labs/lab09-monitoring/main.tf

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
      # Helm provider — lets Terraform deploy Helm charts
      # Same way you'd run helm install manually
      # but tracked in state and repeatable
    }
  }

  backend "gcs" {
    bucket = "ml-platform-dev-498404-terraform-state"
    prefix = "labs/lab09"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = "ml-platform-cluster-dev"
  location = var.region
  project  = var.project_id
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}

# Helm provider — same credentials as kubernetes provider
provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
    )
  }
}

module "monitoring" {
  source = "../../modules/monitoring"

  namespace              = "monitoring"
  environment            = var.environment
  grafana_admin_password = var.grafana_admin_password

  prometheus_retention_days = 15
  grafana_storage_size      = "5Gi"
  prometheus_storage_size   = "10Gi"

  labels = {
    team  = "platform"
    owner = "nitish"
  }
}