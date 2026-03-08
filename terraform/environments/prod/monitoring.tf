# Создание ВМ для мониторинга
resource "google_compute_instance" "monitoring" {
  name         = "monitoring-vm"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["monitoring-server", "http-server", "ssh-server"]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 40
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    
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

# Резервация статического IP для мониторинга
resource "google_compute_address" "monitoring" {
  name = "monitoring-ip"
}

# Firewall правила для мониторинга
resource "google_compute_firewall" "allow-prometheus" {
  name    = "allow-prometheus"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring-server"]
}

resource "google_compute_firewall" "allow-grafana" {
  name    = "allow-grafana"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring-server"]
}
