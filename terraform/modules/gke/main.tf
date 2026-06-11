# terraform/modules/gke/main.tf

locals {
  cluster_name = "${var.cluster_name}-${var.environment}"

  common_labels = merge(
    {
      environment = var.environment
      managed-by  = "terraform"
      project     = "ml-platform"
    },
    var.labels
  )
}

resource "google_container_cluster" "primary" {
  name     = local.cluster_name
  location = var.region
  project  = var.project_id

  # We manage node pools separately below
  # This tells GKE to delete the default node pool immediately
  # and use our custom one instead
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_self_link
  subnetwork = var.subnet_self_link

  # Use the secondary IP ranges we created in Lab 6
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Private cluster — nodes have no public IPs
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    # enable_private_nodes    = true  → nodes have no public IPs
    # enable_private_endpoint = false → control plane still reachable
    #                                   from internet (needed for kubectl)
    master_ipv4_cidr_block = "172.16.0.0/28"
    # Separate range for the control plane
    # Must not overlap with any other range
    # /28 = 16 IPs, plenty for control plane
  }

  # Workload Identity — pods authenticate to GCP as service accounts
  # without needing to mount key files
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Cluster add-ons
  addons_config {
    http_load_balancing {
      disabled = false
      # Enables GCP load balancer integration
      # Required for Ingress resources to work
    }

    horizontal_pod_autoscaling {
      disabled = false
      # Enables HPA — you already know this from your K8s labs
    }

    network_policy_config {
      disabled = false
      # Enables NetworkPolicy enforcement
      # You built NetworkPolicies in your K8s Lab 10
    }
  }

  # Enable network policy using Calico
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # Logging and monitoring — send to Google Cloud Operations
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  resource_labels = local.common_labels

  # Prevent accidental deletion of the cluster
  deletion_protection = false
  # In production this would be true
  # false here so we can destroy easily during labs
}

# ── NODE POOL ─────────────────────────────────────────────────

resource "google_container_node_pool" "primary_nodes" {
  name     = "${local.cluster_name}-node-pool"
  location = var.region
  cluster  = google_container_cluster.primary.name
  project  = var.project_id

  # Autoscaling — cluster grows and shrinks based on demand
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Auto-repair and auto-upgrade keep nodes healthy
  management {
    auto_repair = true
    # GKE automatically replaces unhealthy nodes
    auto_upgrade = true
    # GKE automatically upgrades node Kubernetes version
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"

    # OAuth scopes — what GCP APIs nodes can call
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable Workload Identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = local.common_labels

    shielded_instance_config {
      enable_secure_boot = true
      # Shielded VMs — verified boot process
      # Protects against rootkits and bootkits
    }
  }

  # Allow nodes to be replaced without destroying the pool
  lifecycle {
    ignore_changes = [initial_node_count]
  }
}