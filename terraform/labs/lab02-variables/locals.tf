# locals.tf

locals {
  # Standard prefix for all resource names
  name_prefix = "${var.project_id}-${var.environment}"

  # Merge common labels with any custom labels passed in
  common_labels = merge(
    {
      environment = var.environment
      managed-by  = "terraform"
      project     = "ml-platform"
      region      = var.region
    },
    var.labels
  )

  # Bucket names derived from prefix — defined once, used everywhere
  buckets = {
    artifacts = "${local.name_prefix}-artifacts"
    models    = "${local.name_prefix}-models"
    logs      = "${local.name_prefix}-logs"
  }
}