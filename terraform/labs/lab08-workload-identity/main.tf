# terraform/labs/lab08-workload-identity/main.tf

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
      # Second provider — talks to GKE API directly
      # Creates K8s resources like namespaces and service accounts
    }
  }

  backend "gcs" {
    bucket = "ml-platform-dev-498404-terraform-state"
    prefix = "labs/lab08"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Configure Kubernetes provider using GKE cluster details
# This is how Terraform talks to your GKE cluster
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

# Create the namespace first
resource "kubernetes_namespace" "ml_platform" {
  metadata {
    name = "ml-platform"

    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# Read storage outputs from lab05 state
data "terraform_remote_state" "storage" {
  backend = "gcs"
  config = {
    bucket = "ml-platform-dev-498404-terraform-state"
    prefix = "labs/lab05"
  }
}

# Wire up Workload Identity using the IAM module
module "iam" {
  source = "../../modules/iam"

  project_id           = var.project_id
  environment          = var.environment
  kubernetes_namespace = kubernetes_namespace.ml_platform.metadata[0].name
  bucket_names         = data.terraform_remote_state.storage.outputs.bucket_names

  labels = {
    team  = "platform"
    owner = "nitish"
  }

  depends_on = [kubernetes_namespace.ml_platform]
  # ↑ explicit dependency — namespace must exist before
  #   we create the kubernetes service account inside it
}