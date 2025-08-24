# nginx_reverse_proxy routing to Frontend
# Allow frontend Server 
# for Backend configure CORS Origin
resource "google_compute_firewall" "allow_nginx_to_frontend" { # nginx --> Frontend
  name    = "${var.vpc_name}-allow-nginx-to-frontend"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_tags = ["nginx-proxy"]
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
    # Port 9100 for Node Exporter, 9102 cAdvisor, nginx exporter
    ports = ["9100", "9102", "9104"]
  }

  # Source is the devops VM
  source_tags = ["devops"]

  # Targets are the VMs we want to monitor
  target_tags = ["frontend"]
}
