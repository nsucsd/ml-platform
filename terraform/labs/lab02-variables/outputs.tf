# outputs.tf

output "bucket_names" {
  description = "All created bucket names"
  value = {
    artifacts = google_storage_bucket.artifacts.name
    models    = google_storage_bucket.models.name
    logs      = google_storage_bucket.logs.name
  }
}

output "bucket_urls" {
  description = "GCS URLs for all buckets"
  value = {
    artifacts = google_storage_bucket.artifacts.url
    models    = google_storage_bucket.models.url
    logs      = google_storage_bucket.logs.url
  }
}

output "name_prefix" {
  description = "Name prefix used for all resources"
  value       = local.name_prefix
}

output "common_labels" {
  description = "Labels applied to all resources"
  value       = local.common_labels
}