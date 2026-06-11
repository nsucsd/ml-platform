# terraform/environments/dev/main.tf

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
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = "ml-platform-cluster-${var.environment}"
  location = var.region
  project  = var.project_id

  depends_on = [module.gke]
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
    )
  }
}

# ── 1. STORAGE ────────────────────────────────────────────────
module "storage" {
  source = "../../modules/storage"

  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  force_destroy      = true
  versioning_enabled = true

  labels = {
    team  = "platform"
    owner = "nitish"
  }
}

# ── 2. NETWORKING ─────────────────────────────────────────────
module "networking" {
  source = "../../modules/networking"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  network_name = "ml-platform-vpc"

  subnet_cidr   = "10.0.0.0/24"
  pods_cidr     = "10.1.0.0/16"
  services_cidr = "10.2.0.0/20"

  labels = {
    team  = "platform"
    owner = "nitish"
  }
}

# ── 3. GKE ────────────────────────────────────────────────────
module "gke" {
  source = "../../modules/gke"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  cluster_name = "ml-platform-cluster"

  network_self_link   = module.networking.network_self_link
  subnet_self_link    = module.networking.subnet_self_link
  pods_range_name     = module.networking.pods_range_name
  services_range_name = module.networking.services_range_name

  min_node_count = var.min_node_count
  max_node_count = var.max_node_count
  machine_type   = var.machine_type

  labels = {
    team  = "platform"
    owner = "nitish"
  }
}

# ── 4. IAM + WORKLOAD IDENTITY ────────────────────────────────
module "iam" {
  source = "../../modules/iam"

  project_id           = var.project_id
  environment          = var.environment
  bucket_names         = module.storage.bucket_names
  kubernetes_namespace = "ml-platform"

  labels = {
    team  = "platform"
    owner = "nitish"
  }

  depends_on = [module.gke]
}

# ── 5. MONITORING ─────────────────────────────────────────────
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

  depends_on = [module.gke]
}