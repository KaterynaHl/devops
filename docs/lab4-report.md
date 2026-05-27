# Лабораторна робота №4

# IaC. Terraform. Ansible

## Мета роботи

Метою лабораторної роботи є практичне засвоєння принципів декларативного керування інфраструктурою та конфігурацією.

У роботі використано:

- Terraform для provisioning;
- cloud-init для базового налаштування VM;
- Ansible для configuration management;
- nginx як reverse proxy;
- Flask web application;
- PostgreSQL database.

## Варіант

N = 3

V2 = 2  
V3 = 1  
V5 = 4

Отже:

- застосунок: Notes Service;
- база даних: PostgreSQL;
- конфігурація: config file;
- порт застосунку: 8000.

## Архітектура

Система розгортається на двох віртуальних машинах:

```text
client → VM1(worker): nginx → web application → VM2(db): PostgreSQL

## Архітектура системи

У ЛР4 застосунок із попередніх лабораторних робіт розгортається не на одній машині, а на двох окремих віртуальних машинах.

```text
client → VM1(worker): nginx → web application → VM2(db): PostgreSQL
```

VM1 `worker` містить:

- nginx reverse proxy;
- web application;
- systemd service для запуску застосунку.

VM2 `db` містить:

- PostgreSQL database.

Такий поділ дозволяє відокремити application layer від database layer.

---

## Terraform

Terraform використовується для provisioning інфраструктури.

У Terraform описується створення двох віртуальних машин:

- `mywebapp-worker`;
- `mywebapp-db`.

Для віртуальних машин використовується офіційний Ubuntu cloud image.

Базове налаштування виконується за допомогою `cloud-init`.

Cloud-init створює користувачів:

- `ansible`;
- `teacher`.

Користувач `ansible` має sudo-доступ без введення пароля і використовується для подальшого налаштування машин через Ansible.

---

## Ansible

Ansible використовується для configuration management після створення віртуальних машин.

Inventory розділений на дві групи:

```ini
[workers]
worker ansible_host=<worker-ip>

[db]
db ansible_host=<db-ip>
```

Playbook `site.yml` запускає такі ролі:

- `common`;
- `database`;
- `webapp`;
- `nginx`.

---

## Роль common

Роль `common` виконується на всіх віртуальних машинах.

Вона:

- встановлює базові пакети;
- створює користувача `teacher`;
- створює файл `/home/student/gradebook`, який містить номер варіанту `N = 3`.

---

## Роль database

Роль `database` виконується на VM2 `db`.

Вона:

- встановлює PostgreSQL;
- створює базу даних застосунку;
- створює користувача бази даних;
- налаштовує PostgreSQL listen address;
- дозволяє доступ до PostgreSQL тільки з VM1 `worker`;
- обмежує доступ до бази даних через firewall.

---

## Роль webapp

Роль `webapp` виконується на VM1 `worker`.

Вона:

- створює системного користувача `app`;
- створює користувача `operator`;
- копіює код застосунку;
- створює Python virtual environment;
- встановлює залежності з `requirements.txt`;
- генерує `config.json` через Ansible template;
- встановлює systemd unit для застосунку;
- налаштовує обмежені sudo-права для користувача `operator`.

---

## Роль nginx

Роль `nginx` виконується на VM1 `worker`.

Вона:

- встановлює nginx;
- генерує nginx-конфігурацію через Ansible template;
- проксує запити на `127.0.0.1:8000`;
- вимикає default site;
- запускає nginx service.

---

## Ідемпотентність

Ansible playbook побудований на декларативних модулях:

- `apt`;
- `user`;
- `file`;
- `copy`;
- `template`;
- `systemd`;
- `pip`;
- `lineinfile`;
- `postgresql_db`;
- `postgresql_user`.

Повторний запуск:

```bash
ansible-playbook site.yml
```

не повинен вносити змін, якщо система вже відповідає описаній конфігурації.

---

## Команди запуску

### Terraform

```bash
cd terraform
terraform init
terraform apply
terraform output
```

### Ansible

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

### Перевірка

```bash
curl http://<worker-ip>/
curl http://<worker-ip>/health/alive
curl http://<worker-ip>/health/ready
curl -H "Accept: application/json" http://<worker-ip>/notes
```

---

## Висновки

Terraform відповідає за створення інфраструктури, а Ansible — за конфігурацію системи.

Розподілена архітектура дозволяє відокремити web application від database layer.

Ansible templates дозволяють динамічно підставляти IP-адресу database VM у конфігурацію застосунку та nginx.

Такий підхід робить інфраструктуру відтворюваною, контрольованою та придатною для повторного розгортання.
