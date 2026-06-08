# main.tf

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # PART 2 — we add the backend block here after creating the bucket
  # Leave this commented out for now
  # backend "gcs" {
  #   bucket = "ml-platform-dev-498404-terraform-state"
  #   prefix = "labs/lab03"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# This bucket will store ALL Terraform state for the ml-platform project
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = var.region
  force_destroy = false   # NEVER true for state bucket — protect it

  uniform_bucket_level_access = true

  versioning {
    enabled = true   # Critical — lets you roll back to previous state
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10   # Keep last 10 versions of state
    }
    action {
      type = "Delete"   # Delete older versions to save cost
    }
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = "ml-platform"
    purpose     = "terraform-state"
  }
}