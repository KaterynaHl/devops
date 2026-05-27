output "worker_ip" {
  description = "Worker VM IP address"
  value       = libvirt_domain.worker.network_interface[0].addresses[0]
}

output "db_ip" {
  description = "Database VM IP address"
  value       = libvirt_domain.db.network_interface[0].addresses[0]
}

output "ansible_inventory_hint" {
  description = "Static inventory example"
  value = <<EOT
[workers]
worker ansible_host=${libvirt_domain.worker.network_interface[0].addresses[0]}

[db]
db ansible_host=${libvirt_domain.db.network_interface[0].addresses[0]}

[all:vars]
ansible_user=ansible
EOT
}
