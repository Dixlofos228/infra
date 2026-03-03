output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "load_balancer_url" {
  description = "URL to access the application via load balancer"
  value       = "http://${google_compute_global_address.lb_ip.address}"
}

output "vm_public_ip" {
  description = "Public IP of the VM (for direct access)"
  value       = google_compute_instance.app_server.network_interface[0].access_config[0].nat_ip
}

output "vm_private_ip" {
  description = "Private IP of the VM"
  value       = google_compute_instance.app_server.network_interface[0].network_ip
}
