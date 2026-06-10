# terraform/labs/lab07-gke/main.tf

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "ml-platform-dev-498404-terraform-state"
    prefix = "labs/lab07"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Read networking outputs from lab06 state
# This is how modules share data across separate state files
data "terraform_remote_state" "networking" {
  backend = "gcs"
  config = {
    bucket = "ml-platform-dev-498404-terraform-state"
    prefix = "labs/lab06"
  }
}

# GKE cluster — uses networking outputs
module "gke" {
  source = "../../modules/gke"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  cluster_name = "ml-platform-cluster"

  # These come directly from lab06 networking state
  network_self_link   = data.terraform_remote_state.networking.outputs.network_self_link
  subnet_self_link    = data.terraform_remote_state.networking.outputs.subnet_self_link
  pods_range_name     = data.terraform_remote_state.networking.outputs.pods_range_name
  services_range_name = data.terraform_remote_state.networking.outputs.services_range_name

  min_node_count = 1
  max_node_count = 3
  machine_type   = "e2-standard-2"

  labels = {
    team  = "platform"
    owner = "nitish"
  }
}