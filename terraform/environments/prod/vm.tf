# IP адрес для балансировщика
resource "google_compute_global_address" "lb_ip" {
  name = "instahelper-lb-ip"
}

# ВМ инстанс
resource "google_compute_instance" "app_server" {
  name         = "instahelper-server"
  machine_type = var.machine_type
  zone         = var.zone
  
  tags = ["http-server", "ssh-server", "load-balanced-backend"]
  
  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 20
    }
  }
  
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    
    access_config {
      # Будет автоматически назначен эфемерный внешний IP
    }
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y docker.io python3-pip curl
      systemctl enable docker
      systemctl start docker
      usermod -aG docker ubuntu
      
      # Установка Docker Compose
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
    EOF
  }
  
  service_account {
    scopes = ["cloud-platform"]
  }
}

# Группа инстансов для балансировщика
resource "google_compute_instance_group" "instahelper_group" {
  name        = "instahelper-instance-group"
  zone        = var.zone
  instances   = [google_compute_instance.app_server.self_link]
  
  named_port {
    name = "http"
    port = 8080
  }
}
