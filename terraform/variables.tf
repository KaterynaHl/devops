variable "vm_memory" {
  description = "Memory allocated for each VM in MB"
  type        = number
  default     = 2048
}

variable "vm_cpus" {
  description = "Number of CPUs allocated for each VM"
  type        = number
  default     = 2
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key used by cloud-init"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ubuntu_image_url" {
  description = "Ubuntu cloud image URL"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
