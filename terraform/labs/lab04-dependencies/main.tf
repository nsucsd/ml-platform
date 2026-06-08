# main.tf

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
    prefix = "labs/lab04"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ── DATA SOURCES ──────────────────────────────────────────────
# Read existing infrastructure — these don't create anything

# Read the current GCP project details
data "google_project" "current" {
  project_id = var.project_id
}

# Read each existing bucket from lab02 — reference without owning
data "google_storage_bucket" "existing" {
  for_each = toset(local.existing_buckets)
  name     = each.value
}

# ── RESOURCES ─────────────────────────────────────────────────

# Create a service account for the ML inference service
resource "google_service_account" "ml_inference" {
  account_id   = local.sa_account_id
  display_name = local.sa_display_name
  description  = "Used by the ML inference API to read/write model artifacts"
  project      = var.project_id
}

# Grant the service account access to each existing bucket
# for_each creates one IAM binding per bucket per role
resource "google_storage_bucket_iam_member" "ml_inference_access" {
  for_each = toset(local.existing_buckets)

  bucket = each.value
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ml_inference.email}"
  # ↑ implicit dependency — Terraform creates service account FIRST
  #   then creates these IAM bindings
}