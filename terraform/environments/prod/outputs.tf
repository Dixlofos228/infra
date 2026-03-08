output "monitoring_ip" {
  description = "Static IP address for monitoring VM"
  value       = google_compute_address.monitoring.address
}

output "monitoring_vm_ip" {
  description = "Ephemeral IP of the monitoring VM"
  value       = google_compute_instance.monitoring.network_interface[0].access_config[0].nat_ip
}
