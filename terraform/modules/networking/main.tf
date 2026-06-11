# terraform/modules/networking/main.tf

locals {
  name_prefix = "${var.network_name}-${var.environment}"

  common_labels = merge(
    {
      environment = var.environment
      managed-by  = "terraform"
      project     = "ml-platform"
    },
    var.labels
  )
}

# ── VPC ───────────────────────────────────────────────────────

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  # ↑ false = we control subnets manually
  #   true  = GCP auto-creates one subnet per region (not what we want)
  project = var.project_id
}

# ── SUBNET ────────────────────────────────────────────────────

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
  project       = var.project_id

  private_ip_google_access = true
  # ↑ allows VMs with no public IP to reach Google APIs
  #   critical for private GKE nodes to pull container images

  # Secondary ranges for GKE
  # GKE needs separate IP ranges for pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# ── CLOUD ROUTER ──────────────────────────────────────────────

resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.self_link
  project = var.project_id
  # Router is required by Cloud NAT
  # Think of it as the gateway that NAT attaches to
}

# ── CLOUD NAT ─────────────────────────────────────────────────

resource "google_compute_router_nat" "nat" {
  name                   = "${var.network_name}-nat"
  router                 = google_compute_router.router.name
  region                 = var.region
  project                = var.project_id
  nat_ip_allocate_option = "AUTO_ONLY"
  # ↑ GCP automatically assigns public IPs for NAT
  #   alternative is MANUAL_ONLY where you specify IPs

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  # ↑ NAT applies to all subnets in this router's network
  #   private GKE nodes use this to reach the internet
  #   for pulling container images, calling external APIs etc.

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
    # Log NAT errors — useful for debugging connectivity issues
  }
}

# ── FIREWALL RULES ────────────────────────────────────────────

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.self_link
  project = var.project_id

  description = "Allow all internal traffic within the VPC"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
    # icmp = ping — useful for debugging connectivity
  }

  # Only apply to traffic originating inside the VPC
  source_ranges = [
    var.subnet_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.vpc.self_link
  project = var.project_id

  description = "Allow GCP health check probes to reach nodes"

  allow {
    protocol = "tcp"
  }

  # GCP health checkers always come from these two ranges
  # Without this rule load balancers can't check node health
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
}