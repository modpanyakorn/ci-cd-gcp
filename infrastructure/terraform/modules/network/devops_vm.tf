# Allow Load Balancer, Health Check and Proxy access devops-vm
resource "google_compute_firewall" "allow_lb_to_devops" {
  name    = "${var.vpc_name}-allow-lb-to-devops"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["8000", "8001", "8002", "8003", "8004", "8005"] # Services Port -> Jenkins, Grafana, Prometheus, Sonarqube, Mongo Express, cAdvisor
  }

  # IP Ranges of Google Load Balancer
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["devops"]
}
