# terraform/modules/iam/workload_identity.tf

# Kubernetes service account — lives inside GKE
# This is a K8s resource, not a GCP resource
resource "kubernetes_service_account" "ml_inference" {
  metadata {
    name      = "ml-inference-ksa"
    namespace = var.kubernetes_namespace

    # This annotation is the magic link
    # It tells GKE: "this K8s SA = that GCP SA"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.ml_inference.email
    }
  }
}

# GCP IAM binding — the other half of the link
# Allows the K8s SA to impersonate the GCP SA
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.ml_inference.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.kubernetes_namespace}/ml-inference-ksa]"
  # ↑ format: PROJECT.svc.id.goog[NAMESPACE/KSA_NAME]
  #   this is the Workload Identity member format GCP requires
}