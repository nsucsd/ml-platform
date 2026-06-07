# main.tf

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Artifacts bucket — stores ML model artifacts
resource "google_storage_bucket" "artifacts" {
  name          = local.buckets.artifacts
  location      = var.region
  force_destroy = var.bucket_config.force_destroy
  labels        = local.common_labels

  uniform_bucket_level_access = true

  versioning {
    enabled = var.bucket_config.versioning_enabled
  }
}

# Models bucket — stores trained model files
resource "google_storage_bucket" "models" {
  name          = local.buckets.models
  location      = var.region
  force_destroy = var.bucket_config.force_destroy
  labels        = local.common_labels

  uniform_bucket_level_access = true

  versioning {
    enabled = var.bucket_config.versioning_enabled
  }
}

# Logs bucket — stores application logs
resource "google_storage_bucket" "logs" {
  name          = local.buckets.logs
  location      = var.region
  force_destroy = var.bucket_config.force_destroy
  labels        = local.common_labels

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}