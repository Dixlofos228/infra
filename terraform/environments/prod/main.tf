terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("/home/mirai/devops-gcp/keys/terraform-key.json")
  project     = var.project_id
  region      = var.region
}

# Используем модуль сети
module "network" {
  source      = "../../modules/network"
  environment = var.environment
  region      = var.region
}

# ВМ для приложения
module "app" {
  source         = "../../modules/app_instance"
  environment    = var.environment
  machine_type   = var.machine_type_app
  zone           = var.zone
  subnet         = module.network.subnet_id
  instance_count = var.app_instance_count
  tags           = ["app-server"]
}

# ВМ для мониторинга
resource "google_compute_instance" "monitoring" {
  name         = "monitoring-${var.environment}"
  machine_type = var.machine_type_monitoring
  zone         = var.zone

  tags = ["monitoring-server-${var.environment}", "http-server-${var.environment}"]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 40
    }
  }

  network_interface {
    subnetwork = module.network.subnet_name
    
    access_config {
      # Эфемерный внешний IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# IP адрес балансировщика
resource "google_compute_global_address" "lb_ip" {
  name = "instahelper-lb-${var.environment}"
}

# Группа инстансов
resource "google_compute_instance_group" "app_group" {
  name     = "instahelper-group-${var.environment}"
  zone     = var.zone
  instances = module.app.instance_self_links
  
  named_port {
    name = "http"
    port = 8080
  }
}

# Health check
resource "google_compute_health_check" "app_health" {
  name = "instahelper-health-${var.environment}"
  
  http_health_check {
    port         = 8080
    request_path = "/health"
  }
}

# Backend service
resource "google_compute_backend_service" "app_backend" {
  name          = "instahelper-backend-${var.environment}"
  health_checks = [google_compute_health_check.app_health.id]
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 10
  
  backend {
    group = google_compute_instance_group.app_group.id
  }
}

# URL map
resource "google_compute_url_map" "app_url_map" {
  name            = "instahelper-urlmap-${var.environment}"
  default_service = google_compute_backend_service.app_backend.id
}

# HTTP proxy
resource "google_compute_target_http_proxy" "app_http_proxy" {
  name    = "instahelper-httpproxy-${var.environment}"
  url_map = google_compute_url_map.app_url_map.id
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "app_http_forwarding" {
  name                  = "instahelper-httpforwarding-${var.environment}"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.app_http_proxy.id
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL"
}

# Выводы
output "app_ips" {
  value = module.app.instance_ips
}

output "monitoring_ip" {
  value = google_compute_instance.monitoring.network_interface[0].access_config[0].nat_ip
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}
