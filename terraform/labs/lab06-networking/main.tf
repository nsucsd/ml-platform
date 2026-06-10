# terraform/labs/lab06-networking/main.tf

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
    prefix = "labs/lab06"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

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