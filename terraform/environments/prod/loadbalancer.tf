# Health check
resource "google_compute_health_check" "instahelper_health" {
  name = "instahelper-health-check"
  
  http_health_check {
    port         = 8080
    request_path = "/health"
  }
}

# Backend service
resource "google_compute_backend_service" "instahelper_backend" {
  name          = "instahelper-backend-service"
  health_checks = [google_compute_health_check.instahelper_health.id]
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 10
  
  backend {
    group = google_compute_instance_group.instahelper_group.id
  }
}

# URL map
resource "google_compute_url_map" "instahelper_url_map" {
  name            = "instahelper-url-map"
  default_service = google_compute_backend_service.instahelper_backend.id
}

# HTTP proxy
resource "google_compute_target_http_proxy" "instahelper_http_proxy" {
  name    = "instahelper-http-proxy"
  url_map = google_compute_url_map.instahelper_url_map.id
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "instahelper_http_forwarding" {
  name                  = "instahelper-http-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.instahelper_http_proxy.id
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL"
}
