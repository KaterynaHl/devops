# MyWebApp
Опис застосунку: Notes Service — простий сервіс для зберігання текстових нотаток.

## Laboratory Work 4: IaC, Terraform and Ansible

This branch contains Infrastructure as Code configuration for deploying `mywebapp` on two separate virtual machines.

The application is based on previous laboratory works:

- Lab 1: Flask Notes Service, PostgreSQL, nginx, systemd
- Lab 2: Docker and Docker Compose configuration
- Lab 3: CI/CD pipeline, tests, deployment and verification scripts
- Lab 4: Terraform provisioning and Ansible configuration management

---

## Variant

Student number:

```text
N = 3
```

Variant calculation:

```text
V2 = (3 % 2) + 1 = 2
V3 = (3 % 3) + 1 = 1
V5 = (3 % 5) + 1 = 4
```

Selected variant:

- Application: Notes Service
- Database: PostgreSQL
- Configuration method: config file
- Application port: 8000

---

## Architecture

The system is deployed on two virtual machines:

```text
client → VM1(worker): nginx → web application → VM2(db): PostgreSQL
```

### VM1: worker

Contains:

- nginx reverse proxy
- Flask web application
- systemd service for the application
- `app` system user
- `operator` user with restricted sudo permissions

### VM2: db

Contains:

- PostgreSQL database
- database user and database for the application
- firewall rules that allow PostgreSQL access only from the worker VM

---

## Terraform

Terraform is used for infrastructure provisioning.

Terraform files are located in:

```text
terraform/
```

Terraform creates:

- `mywebapp-worker` VM
- `mywebapp-db` VM
- private virtual network
- cloud-init disks
- base Ubuntu cloud image volumes

Cloud-init creates users on both VMs:

- `ansible`
- `teacher`

The `ansible` user has passwordless sudo access and is used by Ansible for configuration management.

### Terraform commands

```bash
cd terraform
terraform init
terraform apply
terraform output
```

To destroy infrastructure:

```bash
terraform destroy
```

---

## Ansible

Ansible is used for configuration management.

Ansible files are located in:

```text
ansible/
```

Inventory file:

```text
ansible/inventory.ini
```

The inventory is divided into two groups:

```ini
[workers]
worker ansible_host=<worker-ip>

[db]
db ansible_host=<db-ip>

[all:vars]
ansible_user=ansible
ansible_python_interpreter=/usr/bin/python3
```

After running `terraform output`, update `ansible/inventory.ini` with actual VM IP addresses.

---

## Ansible Roles

The playbook `ansible/site.yml` runs the following roles:

### common

Runs on all virtual machines.

Responsibilities:

- install common packages
- ensure `teacher` user exists
- create `/home/student/gradebook` with student number `3`

### database

Runs on the `db` VM.

Responsibilities:

- install PostgreSQL
- create application database
- create database user
- configure PostgreSQL listen address
- allow PostgreSQL connections only from worker VM
- configure firewall restrictions

### webapp

Runs on the `worker` VM.

Responsibilities:

- create `app` system user
- create `operator` user
- copy application source code
- create Python virtual environment
- install dependencies
- generate `/etc/mywebapp/config.json` using Ansible template
- install systemd unit for `mywebapp`
- configure restricted sudo permissions for `operator`

### nginx

Runs on the `worker` VM.

Responsibilities:

- install nginx
- generate nginx reverse proxy configuration using Ansible template
- proxy requests to `127.0.0.1:8000`
- disable default nginx site
- start and enable nginx service

---

## Run Ansible

Install required Ansible collections:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

Run the playbook:

```bash
ansible-playbook site.yml
```

Check idempotency by running the playbook again:

```bash
ansible-playbook site.yml
```

The second run should not introduce changes if the system already matches the desired configuration.

---

## Verification

After Terraform and Ansible complete successfully, verify the application through the worker VM:

```bash
curl http://<worker-ip>/
curl http://<worker-ip>/health/alive
curl http://<worker-ip>/health/ready
curl -H "Accept: application/json" http://<worker-ip>/notes
```

Expected results:

- `/` returns HTML page with endpoint list
- `/health/alive` returns `OK`
- `/health/ready` returns `OK` if the worker VM can connect to PostgreSQL on the db VM
- `/notes` returns notes list in JSON format

---

## Documentation

Additional documentation:

```text
docs/lab4-report.md
docs/lab4-runbook.md
terraform/README.md
```

---

## Repository Structure for Lab 4

```text
mywebapp/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── cloud-init-user-data.yml
│   └── README.md
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── requirements.yml
│   ├── site.yml
│   ├── group_vars/
│   │   └── all.yml
│   └── roles/
│       ├── common/
│       ├── database/
│       ├── webapp/
│       └── nginx/
│
├── docs/
│   ├── lab4-report.md
│   └── lab4-runbook.md
│
├── app/
├── app.py
├── migrate.py
├── requirements.txt
└── README.md
```
