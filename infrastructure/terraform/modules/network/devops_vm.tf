# Allow Load Balancer, Health Check and Proxy access devops-vm
resource "google_compute_firewall" "allow_lb_to_devops" {
  name    = "${var.vpc_name}-allow-lb-to-devops"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    #  Jenkins, Grafana, Prometheus, Sonarqube, Mongo Express, cAdvisor
    ports = ["8000", "8001", "8002", "8003", "8004", "8005"]
  }

  # IP Ranges of Google Load Balancer
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["devops"]
}

resource "google_compute_firewall" "allow_github_webhook_to_devops" {
  name    = "${var.vpc_name}-allow-github-webhook-to-devops"
  network = google_compute_network.vpc.name

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8000"]
  }

  # IP Ranges of GitHub Webhook
  source_ranges = ["140.82.112.0/20",
    "192.30.252.0/22",
    "185.199.108.0/22",
    "20.201.28.151/32",
    "20.205.243.166/32",
    "20.87.245.0/32",
    "20.248.137.48/32",
    "20.207.73.82/32",
  "20.27.177.113/32"]

  target_tags = ["devops"]
}
