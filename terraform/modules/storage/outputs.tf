# terraform/modules/storage/outputs.tf

output "bucket_names" {
  description = "Map of bucket names"
  value = {
    artifacts = google_storage_bucket.artifacts.name
    models    = google_storage_bucket.models.name
    logs      = google_storage_bucket.logs.name
  }
}

output "bucket_urls" {
  description = "Map of bucket GCS URLs"
  value = {
    artifacts = google_storage_bucket.artifacts.url
    models    = google_storage_bucket.models.url
    logs      = google_storage_bucket.logs.url
  }
}

output "name_prefix" {
  description = "Name prefix used for all buckets"
  value       = local.name_prefix
}