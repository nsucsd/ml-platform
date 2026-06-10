# terraform/modules/storage/main.tf

locals {
  name_prefix = "${var.project_id}-${var.environment}"

  common_labels = merge(
    {
      environment = var.environment
      managed-by  = "terraform"
      project     = "ml-platform"
    },
    var.labels
  )
}

resource "google_storage_bucket" "artifacts" {
  name          = "${local.name_prefix}-artifacts"
  location      = var.region
  force_destroy = var.force_destroy
  labels        = local.common_labels

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }
}

resource "google_storage_bucket" "models" {
  name          = "${local.name_prefix}-models"
  location      = var.region
  force_destroy = var.force_destroy
  labels        = local.common_labels

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }
}

resource "google_storage_bucket" "logs" {
  name          = "${local.name_prefix}-logs"
  location      = var.region
  force_destroy = var.force_destroy
  labels        = local.common_labels

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}