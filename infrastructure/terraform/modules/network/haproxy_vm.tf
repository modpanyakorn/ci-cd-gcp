# Public user access web application via HTTP, HTTPS
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.vpc_name}-allow-http-https"
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

# Allow Exporter for Prometheus in DevOps VM access
resource "google_compute_firewall" "allow_devops_to_haproxy_exporter" {
  name    = "${var.vpc_name}-allow-devops-to-haproxy-exporter"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    # Port 9100 for Node Exporter, 9101 haproxy exporter
    ports = ["9100", "9101"]
  }

  # Source is the devops VM
  source_tags = ["devops"]

  # Targets are the VMs we want to monitor
  target_tags = ["haproxy"]
}
