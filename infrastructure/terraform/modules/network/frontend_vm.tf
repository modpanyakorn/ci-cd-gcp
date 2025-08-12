# Haproxy routing to Frontend
# Allow frontend Server 
# for Backend configure CORS Origin
resource "google_compute_firewall" "allow_haproxy_to_frontend" { # HaProxy --> Frontend
  name    = "${var.vpc_name}-allow-haproxy-to-frontend"
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

# Allow Exporter for Prometheus in DevOps VM access
resource "google_compute_firewall" "allow_devops_to_frontend_exporter" {
  name    = "${var.vpc_name}-allow-devops-to-monitor"
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
  target_tags = ["frontend"]
}
