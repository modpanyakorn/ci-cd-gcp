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

# Dev team access vm via IAP (Identity Aware Proxy) 
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
  target_tags   = ["nginx-proxy", "private", "devops"]
}


# devops-vm (control node) access to other vm via ssh (port 22)
resource "google_compute_firewall" "allow_devops_to_all_vm" {
  name    = "${var.vpc_name}-devops-to-all-vm"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["devops"]
  target_tags = ["nginx-proxy", "private"]
}
