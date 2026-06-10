# terraform/modules/iam/main.tf

locals {
  sa_account_id = "ml-inference-sa-${var.environment}"

  common_labels = merge(
    {
      environment = var.environment
      managed-by  = "terraform"
      project     = "ml-platform"
    },
    var.labels
  )
}

resource "google_service_account" "ml_inference" {
  account_id   = local.sa_account_id
  display_name = "ML Inference Service Account (${var.environment})"
  description  = "Used by ML inference API to read/write model artifacts"
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "ml_inference_access" {
  for_each = var.bucket_names

  bucket = each.value
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ml_inference.email}"
}