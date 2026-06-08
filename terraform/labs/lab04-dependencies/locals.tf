# locals.tf

locals {
  name_prefix = "${var.project_id}-${var.environment}"

  # Service account details
  sa_account_id   = "ml-inference-sa-${var.environment}"
  sa_display_name = "ML Inference Service Account (${var.environment})"

  # These are the buckets we created in lab02
  # We reference them by name so we can grant access
  existing_buckets = [
    "${local.name_prefix}-artifacts",
    "${local.name_prefix}-models",
    "${local.name_prefix}-logs",
  ]

  common_labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = "ml-platform"
  }
}