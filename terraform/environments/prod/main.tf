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

# ВМ для мониторинга (если нужна для uat)
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

# Балансировщик
resource "google_compute_global_address" "lb_ip" {
  name = "instahelper-lb-${var.environment}"
}

resource "google_compute_instance_group" "app_group" {
  name     = "instahelper-group-${var.environment}"
  zone     = var.zone
  instances = module.app.instance_self_links  # Вместо instance_ips
  
  named_port {
    name = "http"
    port = 8080
  }
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
