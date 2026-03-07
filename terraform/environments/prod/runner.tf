# ~/devops-gcp/infra/terraform/environments/prod/runner.tf
resource "google_compute_instance" "gitlab_runner" {
  name         = "gitlab-runner-vm"
  machine_type = "e2-small"
  zone         = "us-central1-a"

  tags = ["ssh-server", "http-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
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
    ssh-keys       = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    startup-script = <<-EOF
  #!/bin/bash
  apt-get update
  apt-get install -y docker.io curl wget git
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ubuntu

  # Скачивание и установка актуальной версии GitLab Runner
  curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
  # Важно: Проверяем, что файл скачался, прежде чем пытаться его установить
  if [ -f "gitlab-runner_amd64.deb" ]; then
    dpkg -i gitlab-runner_amd64.deb
  else
    echo "Failed to download GitLab Runner package" >&2
    exit 1
  fi
EOF
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "runner_public_ip" {
  description = "Public IP of the GitLab Runner VM"
  value       = google_compute_instance.gitlab_runner.network_interface[0].access_config[0].nat_ip
}
