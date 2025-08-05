# VPC
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "this" {
  for_each      = var.subnets
  name          = each.key
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Cloud NAT
resource "google_compute_router" "nat_router" {
  count   = var.create_nat ? 1 : 0
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

# Router NAT (Routing)
resource "google_compute_router_nat" "nat" {
  count                              = var.create_nat ? 1 : 0
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Public user access web application via HTTP, HTTPS
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.vpc_name}-allow-web"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["haproxy"]
}

# Dev team access vm via ssh 
resource "google_compute_firewall" "allow_iap_access" {
  name    = "${var.vpc_name}-allow-iap-access"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["haproxy", "devops"]
}

# Haproxy routing to Frontend
resource "google_compute_firewall" "allow_haproxy_to_apps" { # HaProxy --> Frontend
  name    = "${var.vpc_name}-allow-haproxy-apps"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_tags = ["haproxy"]
  target_tags = ["frontend"]
}

# Internal Communicate
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    # serve frontend, api, db
    ports = ["3001", "3002", "3003"] # Frontend, Backend, DB
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/16"]
  target_tags   = ["private"]
}

# Allow Load Balancer, Health Check and Proxy access devops-vm
resource "google_compute_firewall" "allow_lb_to_devops" {
  name    = "${var.vpc_name}-allow-devops-lb-iap"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["8080", "8081", "8082"] #Services Port such as Jenkins, Grafana, Prometheus, ... 
  }

  # IP Ranges of Google Load Balancer
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  target_tags = ["devops"]
}

