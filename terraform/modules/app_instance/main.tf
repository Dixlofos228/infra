resource "google_compute_instance" "app" {
  count        = var.instance_count
  name         = "instahelper-${var.environment}-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = concat(var.tags, ["app-server-${var.environment}", "http-server-${var.environment}"])

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 20
    }
  }

  network_interface {
    subnetwork = var.subnet
    
    access_config {
      # Эфемерный внешний IP
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
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
    EOF
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "instance_ips" {
  value = google_compute_instance.app[*].network_interface[0].access_config[0].nat_ip
}

output "instance_private_ips" {
  value = google_compute_instance.app[*].network_interface[0].network_ip
}

output "instance_names" {
  value = google_compute_instance.app[*].name
}

output "instance_self_links" {
  value = google_compute_instance.app[*].self_link
}
