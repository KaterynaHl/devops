# Terraform Infrastructure

This directory contains Terraform configuration for Laboratory Work 4.

The infrastructure contains two virtual machines:

- worker: nginx reverse proxy and web application
- db: PostgreSQL database

Provider:

- libvirt for KVM/QEMU

## Requirements

- Terraform >= 1.6
- libvirt
- qemu-kvm
- Ubuntu cloud image
- SSH key pair

## Commands

Initialize Terraform:

```bash
terraform init
