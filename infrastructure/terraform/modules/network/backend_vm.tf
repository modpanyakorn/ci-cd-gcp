# Allow frontend VM to access Backend Server API on port 3001
resource "google_compute_firewall" "allow_frontend_to_backend_api" {
  name    = "${var.vpc_name}-allow-frontend-to-backend-api"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["3001"] # API port
  }

  source_tags = ["frontend"]
  target_tags = ["backend"]
}

# Allow Exporter for Prometheus in DevOps VM access
resource "google_compute_firewall" "allow_devops_to_backend_exporter" {
  name    = "${var.vpc_name}-allow-devops-to-backend-exporter"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    # Port 9100 for Node Exporter, 9102 cAdvisor
    ports = ["9100", "9102"]
  }

  # Source is the devops VM
  source_tags = ["devops"]

  # Targets are the VMs we want to monitor
  target_tags = ["backend"]
}
