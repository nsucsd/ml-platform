# outputs.tf

output "state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.name
}

output "state_bucket_url" {
  description = "GCS URL of the state bucket"
  value       = google_storage_bucket.terraform_state.url
}

output "backend_config" {
  description = "Copy this into your terraform backend blocks"
  value       = <<-EOT
    backend "gcs" {
      bucket = "${google_storage_bucket.terraform_state.name}"
      prefix = "YOUR_MODULE_PATH"
    }
  EOT
}