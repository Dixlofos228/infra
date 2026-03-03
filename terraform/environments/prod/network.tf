# VPC сеть
resource "google_compute_network" "vpc" {
  name                    = "instahelper-vpc"
  auto_create_subnetworks = false
}

# Подсеть
resource "google_compute_subnetwork" "subnet" {
  name          = "instahelper-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  
  private_ip_google_access = true
}

# Firewall правило для HTTP
resource "google_compute_firewall" "allow-http" {
  name    = "instahelper-allow-http"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Firewall правило для SSH
resource "google_compute_firewall" "allow-ssh" {
  name    = "instahelper-allow-ssh"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}

# Firewall для health checks балансировщика
resource "google_compute_firewall" "allow-health-check" {
  name    = "instahelper-allow-health-check"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["load-balanced-backend"]
}
