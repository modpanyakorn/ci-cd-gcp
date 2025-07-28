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
