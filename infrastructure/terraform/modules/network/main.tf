resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  for_each      = var.subnets
  name          = each.key
  ip_cidr_range = each.value.cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# optional Cloud NAT
resource "google_compute_router" "nat_router" {
  count   = var.create_nat ? 1 : 0
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  count                              = var.create_nat ? 1 : 0
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # ควรจำกัดเป็น IP ของคุณ
  target_tags   = ["public-subnet", "devops-subnet"]
}

# เพิ่มใน modules/network/main.tf
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  # allow {
  #   protocol = "udp"
  #   ports    = ["0-65535"]
  # }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/16"]
  target_tags   = ["frontend-subnet", "backend-subnet", "db-subnet"]
}

resource "google_compute_firewall" "allow_haproxy_to_apps" {
  name    = "${var.vpc_name}-allow-haproxy-apps"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3000", "3001"] # Frontend and backend ports
  }

  source_tags = ["haproxy"]
  target_tags = ["frontend", "backend"]
}


resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.vpc_name}-allow-web"
  network = google_compute_network.vpc.name

  allow {
    protocol = "http"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public-subnet", "devops-subnet"]
}
