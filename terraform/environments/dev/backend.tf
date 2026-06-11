# terraform/environments/dev/backend.tf

terraform {
  backend "gcs" {
    bucket = "ml-platform-dev-498404-terraform-state"
    prefix = "environments/dev"
  }
}