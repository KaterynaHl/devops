# MyWebApp
Опис застосунку: Notes Service — простий сервіс для зберігання текстових нотаток.

## Variant

```text
N = 3

V2 = (N % 2) + 1 = (3 % 2) + 1 = 2

V3 = (N % 3) + 1 = (3 % 3) + 1 = 1

V5 = (N % 5) + 1 = (3 % 5) + 1 = 4
```

## Stack

- Python
- Flask
- PostgreSQL
- Nginx
- systemd

## Features

- Health checks
- HTML responses
- JSON responses
- Reverse proxy
- Database migration
- Socket activation

## API

### GET /notes

Returns all notes.

### POST /notes

Creates new note.

### GET /notes/<id>

Returns note details.

## Project Structure

```text
mywebapp/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── database.py
│   └── models.py
│
├── config/
│   └── app_config.json
│
├── docker/
│   ├── mywebapp/
│   │   └── Dockerfile
│   └── experiments/
│       ├── golang/
│       │   ├── Dockerfile.distroless
│       │   ├── Dockerfile.scratch
│       │   └── Dockerfile.single
│       └── python/
│           ├── Dockerfile.alphine
│           ├── Dockerfile.bad
│           └── Dockerfile.optimized
│
├── docs/
│   ├── lab3-report.md
│   └── operator-sudoers.txt
│
├── nginx/
│   ├── mywebapp.conf
│   └── docker-mywebapp.conf
│
├── scripts/
│   ├── install.sh
│   ├── bootstrap-target.sh
│   ├── setup-runner.sh
│   ├── deploy.sh
│   └── verify.sh
│
├── systemd/
│   ├── mywebapp.service
│   ├── mywebapp.socket
│   └── mywebapp-container.service
│
├── tests/
│   └── test_app.py
│
├── .dockerignore
├── .flake8
├── .gitignore
├── .gitattributes
├── app.py
├── config.json.example
├── docker-compose.yml
├── docker-compose.prod.yml
├── migrate.py
├── README.md
├── requirements.txt
├── requirements-dev.txt
└── lab2-report.md
```

## Laboratory Work 3: CI/CD

This branch contains CI/CD configuration for the project from Laboratory Works 1 and 2.

Pipeline includes:

- static analysis;
- automated tests;
- test coverage;
- Docker image build;
- GitHub Container Registry publishing;
- deployment scripts;
- verification scripts.

Workflow file:

```text
.github/workflows/ci-cd.yml
```

Report:

```text
docs/lab3-report.md
```

Runner setup documentation:

```text
docs/runner-setup.md
```
