# Allow backend VM to access DB on port 3002
# Mongo Express in DevOps monitor
resource "google_compute_firewall" "allow_backend_devops_to_db" {
  name    = "${var.vpc_name}-allow-backend-devops-to-db"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["3002"] # Database port
  }

  source_tags = ["backend", "devops"]
  target_tags = ["db"]
}

# Allow Exporter for Prometheus in DevOps VM access
resource "google_compute_firewall" "allow_devops_to_db_exporter" {
  name    = "${var.vpc_name}-allow-devops-to-db-exporter"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    # Port 9100 for Node Exporter, 9103 mongodb exporter
    ports = ["9100", "9103"]
  }

  # Source is the devops VM
  source_tags = ["devops"]

  # Targets are the VMs we want to monitor
  target_tags = ["db"]
}
