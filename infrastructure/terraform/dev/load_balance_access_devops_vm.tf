# Create Instance Group
# Receive Traffic from Load Balance and define name_port each services
resource "google_compute_instance_group" "devops_instance_group_lb" {
  name      = "devops-ig-lb"
  zone      = var.zone
  instances = [module.devops_vm.self_link]

  named_port {
    name = "jenkins-http"
    port = 8000
  }

  named_port {
    name = "grafana-http"
    port = 8001
  }

  named_port {
    name = "prometheus-http"
    port = 8002
  }

  named_port {
    name = "sonarqube-http"
    port = 8003
  }

  named_port {
    name = "mongoexpress-http"
    port = 8004
  }

  named_port {
    name = "cadvisor-http"
    port = 8005
  }
}

# Health Check for Jenkins
resource "google_compute_health_check" "jenkins_health_check" {
  name = "jenkins-lb-health-check"
  http_health_check {
    port         = 8000
    request_path = "/login" # path of Jenkins
  }
}

# Health Check for Grafana
resource "google_compute_health_check" "grafana_health_check" {
  name = "grafana-lb-health-check"
  http_health_check {
    port         = 8001
    request_path = "/api/health"
  }
}

# Health Check for Prometheus
resource "google_compute_health_check" "prometheus_health_check" {
  name = "prometheus-lb-health-check"
  http_health_check {
    port         = 8002
    request_path = "/-/healthy"
  }
}

# Health Check for Sonarqube
resource "google_compute_health_check" "sonarqube_health_check" {
  name = "sonarqube-lb-health-check"
  http_health_check {
    port         = 8003
    request_path = "/api/system/status"
  }
}

# Health Check for Mongo Express
resource "google_compute_health_check" "mongo_express_health_check" {
  name = "mongoexpress-lb-health-check"
  http_health_check {
    port         = 8004
    request_path = "/status"
  }
}

# Health Check for cAdvisor
resource "google_compute_health_check" "cadvisor_health_check" {
  name = "cadvisor-lb-health-check"
  http_health_check {
    port         = 8005
    request_path = "/healthz"
  }
}

# Create Backend Service Jenkins, Grafana, Prometheus, Sonarqube and enable IAP
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
    sonarqube = {
      port_name    = "sonarqube-http"
      health_check = google_compute_health_check.sonarqube_health_check.self_link
      description  = "Backend service for Sonarqube with IAP"
    }
    mongoexpress = {
      port_name    = "mongoexpress-http"
      health_check = google_compute_health_check.mongo_express_health_check.self_link
      description  = "Backend service for Mongo Express with IAP"
    }
    cadvisor = {
      port_name    = "cadvisor-http"
      health_check = google_compute_health_check.cadvisor_health_check.self_link
      description  = "Backend service for cAdvisor with IAP"
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
        for service_key in ["jenkins", "grafana", "prometheus", "sonarqube", "mongoexpress", "cadvisor"] : {
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

  # Main domain
  host_rule {
    hosts        = var.domains
    path_matcher = "main"
  }
  path_matcher {
    name            = "main"
    default_service = google_compute_backend_service.devops_backend_iap["jenkins"].self_link
  }

  # Jenkins host rule
  host_rule {
    hosts        = var.jenkins_sub_domain
    path_matcher = "jenkins-path-matcher"
  }

  # Path matcher for Jenkins
  path_matcher {
    name            = "jenkins-path-matcher"
    default_service = google_compute_backend_service.devops_backend_iap["jenkins"].self_link
  }

  # Grafana host rule
  host_rule {
    hosts        = var.grafana_sub_domain
    path_matcher = "grafana-path-matcher"
  }

  # Path Rule for Grafana
  path_matcher {
    name            = "grafana-path-matcher"
    default_service = google_compute_backend_service.devops_backend_iap["grafana"].self_link
  }

  # Prometheus host rule
  host_rule {
    hosts        = var.prometheus_sub_domain
    path_matcher = "prometheus-path-matcher"
  }

  # Path Rule for Prometheus
  path_matcher {
    name            = "prometheus-path-matcher"
    default_service = google_compute_backend_service.devops_backend_iap["prometheus"].self_link
  }

  # Sonarqube host rule
  host_rule {
    hosts        = var.sonarqube_sub_domain
    path_matcher = "sonarqube-path-matcher"
  }

  # Path Rule for sonarqube
  path_matcher {
    name            = "sonarqube-path-matcher"
    default_service = google_compute_backend_service.devops_backend_iap["sonarqube"].self_link
  }

  # Mongo Express host rule
  host_rule {
    hosts        = var.mongo_express_sub_domain
    path_matcher = "mongo-express-path-matcher"
  }

  # Path Rule for Mongo Express
  path_matcher {
    name            = "mongo-express-path-matcher"
    default_service = google_compute_backend_service.devops_backend_iap["mongoexpress"].self_link
  }

  # cAdvisor host rule
  host_rule {
    hosts        = var.cadvisor_sub_domain
    path_matcher = "cadvisor-path-matcher"
  }

  # Path Rule for cAdvisor
  path_matcher {
    name            = "cadvisor-path-matcher"
    default_service = google_compute_backend_service.devops_backend_iap["cadvisor"].self_link
  }
}

# HTTP proxy, receive traffic from forwarding_rule and sengind to backend service
# non SSL
resource "google_compute_target_http_proxy" "devops_http_proxy" {
  name    = "devops-lb-http-proxy"
  url_map = google_compute_url_map.devops_url_map.self_link # sending traffic to url mapping
}

# Managed SSL Certificate from GCP and allow domain
# domain ssl
resource "google_compute_managed_ssl_certificate" "default_service_ssl_cert" {
  name = "default-service-ssl-cert"

  managed {
    domains = var.domains
  }
}

resource "google_compute_managed_ssl_certificate" "devops_service_ssl_cert" {
  for_each = {
    # Combine all subdomains into one map for iteration
    jenkins      = var.jenkins_sub_domain
    grafana      = var.grafana_sub_domain
    prometheus   = var.prometheus_sub_domain
    sonarqube    = var.sonarqube_sub_domain
    mongoexpress = var.mongo_express_sub_domain
    cadvisor     = var.cadvisor_sub_domain
  }
  name = "${each.key}-ssl-cert"
  managed {
    domains = each.value
  }
}

# Jenknins sub domain ssl
# resource "google_compute_managed_ssl_certificate" "jenkins_ssl" {
#   name = "jenkins-ssl-cert"

#   managed {
#     domains = var.jenkins_sub_domain
#   }
# }

# # Grafana sub domain ssl
# resource "google_compute_managed_ssl_certificate" "grafana_ssl" {
#   name = "grafana-ssl-cert"

#   managed {
#     domains = var.grafana_sub_domain
#   }
# }

# # Prometheus sub domain ssl
# resource "google_compute_managed_ssl_certificate" "prometheus_ssl" {
#   name = "prometheus-ssl-cert"

#   managed {
#     domains = var.prometheus_sub_domain
#   }
# }

# # Sonarqube sub domain ssl
# resource "google_compute_managed_ssl_certificate" "sonarqube_ssl" {
#   name = "sonarqube-ssl-cert"

#   managed {
#     domains = var.sonarqube_sub_domain
#   }
# }

# # Mongo Express sub domain ssl
# resource "google_compute_managed_ssl_certificate" "mongo_express_ssl" {
#   name = "mongo-express-ssl-cert"

#   managed {
#     domains = var.mongo_express_sub_domain
#   }
# }

# # cAdvisor sub domain ssl
# resource "google_compute_managed_ssl_certificate" "cadvisor_ssl" {
#   name = "cadvisor-ssl-cert"
#   managed {
#     domains = var.cadvisor_sub_domain
#   }
# }

# HTTPS proxy
# SSL on
resource "google_compute_target_https_proxy" "devops_https_proxy" {
  name    = "devops-lb-https-proxy"
  url_map = google_compute_url_map.devops_url_map.self_link

  ssl_certificates = concat(
    [google_compute_managed_ssl_certificate.default_service_ssl_cert.self_link],
    [for cert in google_compute_managed_ssl_certificate.devops_service_ssl_cert : cert.self_link]
  )

  # ssl_certificates = [
  #   google_compute_managed_ssl_certificate.default_service_ssl_cert.self_link,
  # google_compute_managed_ssl_certificate.jenkins_ssl.id,
  # google_compute_managed_ssl_certificate.grafana_ssl.id,
  # google_compute_managed_ssl_certificate.prometheus_ssl.id,
  # google_compute_managed_ssl_certificate.sonarqube_ssl.id,
  # google_compute_managed_ssl_certificate.mongo_express_ssl.id,
  # google_compute_managed_ssl_certificate.cadvisor_ssl.id
  # ]
}

# Receive Traffic from Load Balancer (google_compute_global_address) on port80
# Then sending traffic to http_proxy
# Forwarding Rule HTTP (port 80) → http_proxy
resource "google_compute_global_forwarding_rule" "devops_http_forwarding_rule" {
  name        = "devops-lb-http-forwarding-rule"
  ip_protocol = "TCP"
  ip_address  = google_compute_global_address.devops_lb_static_ip.address
  target      = google_compute_target_http_proxy.devops_http_proxy.self_link
  port_range  = "80"
}

# Forwarding Rule HTTPS (port 443) → https_proxy
resource "google_compute_global_forwarding_rule" "devops_https_forwarding_rule" {
  name        = "devops-lb-https-forwarding-rule"
  ip_protocol = "TCP"
  ip_address  = google_compute_global_address.devops_lb_static_ip.address
  target      = google_compute_target_https_proxy.devops_https_proxy.self_link
  port_range  = "443"
}

# Create Public IP for Load Balancer
resource "google_compute_global_address" "devops_lb_static_ip" {
  name = "devops-lb-static-ip"
}
