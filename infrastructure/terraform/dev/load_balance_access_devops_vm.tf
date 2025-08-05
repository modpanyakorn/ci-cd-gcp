# Create Instance Group
# Receive Traffic from Load Balance and define name_port each services
resource "google_compute_instance_group" "devops_instance_group_lb" {
  name      = "devops-ig-lb"
  zone      = var.zone
  instances = [module.devops_vm.self_link]

  named_port {
    name = "jenkins-http"
    port = 8080
  }

  named_port {
    name = "grafana-http"
    port = 8081
  }

  named_port {
    name = "prometheus-http"
    port = 8082
  }
}

# Health Check for Jenkins
resource "google_compute_health_check" "jenkins_health_check" {
  name = "jenkins-lb-health-check"
  http_health_check {
    port         = 8080
    request_path = "/login" # path of Jenkins
  }
}

# Health Check for Grafana
resource "google_compute_health_check" "grafana_health_check" {
  name = "grafana-lb-health-check"
  http_health_check {
    port         = 8081
    request_path = "/api/health"
  }
}

# Health Check for Prometheus
resource "google_compute_health_check" "prometheus_health_check" {
  name = "prometheus-lb-health-check"
  http_health_check {
    port         = 8082
    request_path = "/-/healthy"
  }
}

# Create Backend Service Jenkins, Grafana, Prometheus and enable IAP
resource "google_compute_backend_service" "devops_backend_iap" {
  for_each = {
    jenkins = {
      port_name    = "jenkins-http"
      health_check = google_compute_health_check.jenkins_health_check.self_link
      description  = "Backend service for Jenkins with IAP"
    }
    grafana = {
      port_name    = "grafana-http"
      health_check = google_compute_health_check.grafana_health_check.self_link
      description  = "Backend service for Grafana with IAP"
    }
    prometheus = {
      port_name    = "prometheus-http"
      health_check = google_compute_health_check.prometheus_health_check.self_link
      description  = "Backend service for Prometheus with IAP"
    }
  }

  name                  = "${each.key}-backend-iap"
  protocol              = "HTTP"
  port_name             = each.value.port_name
  timeout_sec           = 120
  enable_cdn            = false
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [each.value.health_check]
  backend {
    group = google_compute_instance_group.devops_instance_group_lb.self_link
  }
  iap {
    enabled              = true
    oauth2_client_id     = data.vault_kv_secret_v2.iap_creds.data["client_id"]
    oauth2_client_secret = data.vault_kv_secret_v2.iap_creds.data["client_secret"]
  }
}

# Memeber access Service via HTTP (Grant iap.httpsResourceAccessor)
resource "google_iap_web_backend_service_iam_member" "iap_access" {
  for_each = {
    for combo in flatten([
      for email in var.members : [
        for service_key in ["jenkins", "grafana", "prometheus"] : {
          email       = email
          service_key = service_key
        }
      ]
    ]) : "${combo.email}-${combo.service_key}" => combo
  }

  project             = var.project_id
  web_backend_service = google_compute_backend_service.devops_backend_iap[each.value.service_key].name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "user:${each.value.email}"
}

# URL Mapping for Load Balancer
# example: '/jenkins' url path direct to Jenkins backend
resource "google_compute_url_map" "devops_url_map" {
  name = "devops-lb-url-map"
  # **การแก้ไขที่สำคัญ:** เพิ่ม lifecycle block เพื่อแก้ปัญหา dependency
  lifecycle {
    create_before_destroy = true
  }

  # Define Jenkins is main page
  default_service = google_compute_backend_service.devops_backend_iap["jenkins"].self_link

  # reference pathmather for host_rules
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.devops_backend_iap["jenkins"].self_link

    # Path Rule for Jenkins
    path_rule {
      paths   = ["/jenkins", "/jenkins/*"]
      service = google_compute_backend_service.devops_backend_iap["jenkins"].self_link
    }

    # Path Rule for Grafana
    path_rule {
      paths   = ["/grafana", "/grafana/*"]
      service = google_compute_backend_service.devops_backend_iap["grafana"].self_link
    }

    # Path Rule for Prometheus
    path_rule {
      paths   = ["/prometheus", "/prometheus/*"]
      service = google_compute_backend_service.devops_backend_iap["prometheus"].self_link
    }
  }
}

# HTTP proxy, receive traffic from forwarding_rule and sengind to backend service
resource "google_compute_target_http_proxy" "devops_http_proxy" {
  name    = "devops-lb-http-proxy"
  url_map = google_compute_url_map.devops_url_map.self_link # sending traffic to url mapping
}

# Receive Traffic from Load Balancer (google_compute_global_address) on port80
# Then sending traffic to http_proxy
resource "google_compute_global_forwarding_rule" "devops_http_forwarding_rule" {
  name        = "devops-lb-http-forwarding-rule"
  ip_protocol = "TCP"
  ip_address  = google_compute_global_address.devops_lb_static_ip.self_link
  target      = google_compute_target_http_proxy.devops_http_proxy.self_link
  port_range  = "80"
}

# Create Public IP for Load Balancer
resource "google_compute_global_address" "devops_lb_static_ip" {
  name = "devops-lb-static-ip"
}
