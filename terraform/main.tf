terraform {
  required_version = ">= 1.6.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "mywebapp_pool" {
  name = "mywebapp-pool"
  type = "dir"

  path = "/var/lib/libvirt/images/mywebapp"
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-noble-base.qcow2"
  pool   = libvirt_pool.mywebapp_pool.name
  source = var.ubuntu_image_url
  format = "qcow2"
}

resource "libvirt_volume" "worker_disk" {
  name           = "mywebapp-worker.qcow2"
  pool           = libvirt_pool.mywebapp_pool.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 21474836480
}

resource "libvirt_volume" "db_disk" {
  name           = "mywebapp-db.qcow2"
  pool           = libvirt_pool.mywebapp_pool.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 21474836480
}

data "template_file" "cloud_init_user_data" {
  template = file("${path.module}/cloud-init-user-data.yml")

  vars = {
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
  }
}

resource "libvirt_cloudinit_disk" "worker_cloud_init" {
  name      = "worker-cloud-init.iso"
  pool      = libvirt_pool.mywebapp_pool.name
  user_data = data.template_file.cloud_init_user_data.rendered
}

resource "libvirt_cloudinit_disk" "db_cloud_init" {
  name      = "db-cloud-init.iso"
  pool      = libvirt_pool.mywebapp_pool.name
  user_data = data.template_file.cloud_init_user_data.rendered
}

resource "libvirt_network" "mywebapp_network" {
  name      = "mywebapp-network"
  mode      = "nat"
  domain    = "mywebapp.local"
  addresses = ["192.168.56.0/24"]

  dhcp {
    enabled = true
  }
}

resource "libvirt_domain" "worker" {
  name   = "mywebapp-worker"
  memory = var.vm_memory
  vcpu   = var.vm_cpus

  cloudinit = libvirt_cloudinit_disk.worker_cloud_init.id

  network_interface {
    network_id     = libvirt_network.mywebapp_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_domain" "db" {
  name   = "mywebapp-db"
  memory = var.vm_memory
  vcpu   = var.vm_cpus

  cloudinit = libvirt_cloudinit_disk.db_cloud_init.id

  network_interface {
    network_id     = libvirt_network.mywebapp_network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
