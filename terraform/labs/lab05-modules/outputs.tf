# terraform/labs/lab05-modules/outputs.tf

output "bucket_names" {
  description = "All bucket names from storage module"
  value       = module.storage.bucket_names
}

output "bucket_urls" {
  description = "All bucket URLs from storage module"
  value       = module.storage.bucket_urls
}

output "service_account_email" {
  description = "ML inference service account email"
  value       = module.iam.service_account_email
}