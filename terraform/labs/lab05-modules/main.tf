# terraform/labs/lab05-modules/main.tf

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
    prefix = "labs/lab05"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Call the storage module
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

# Call the IAM module
# Notice: bucket_names comes directly from storage module output
module "iam" {
  source = "../../modules/iam"

  project_id   = var.project_id
  environment  = var.environment
  bucket_names = module.storage.bucket_names
  # ↑ output from storage module feeds directly into iam module
  #   Terraform automatically knows to create storage BEFORE iam

  labels = {
    team  = "platform"
    owner = "nitish"
  }
}