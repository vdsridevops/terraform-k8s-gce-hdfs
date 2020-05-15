output "k8s_master_ip_addr" {
  value       = google_compute_instance.k8s_master.network_interface.0.access_config.0.nat_ip
  description = "The private IP address of the k8s-master server instance"
}
