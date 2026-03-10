resource "google_compute_instance" "gitlab_runner" {
  name         = "gitlab-runner-vm"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["ssh-server", "http-server", "gitlab-runner"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network    = module.network.vpc_name
    subnetwork = module.network.subnet_name
    # access_config убран — внешний IP не требуется
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
