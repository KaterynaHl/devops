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

### GET /matrix

Generates two random 10x10 matrices, multiplies them and returns the result in JSON format.

## Health Checks

### GET /health/alive

Liveness probe endpoint.

Returns:

### GET /health/ready

Readiness probe endpoint. Checks database connectivity before returning successful response.

## Docker Compose

Build and start all services:

```bash
docker compose up --build
```

Stop services:

```bash
docker compose down
```

Stop services and remove volumes:

```bash
docker compose down -v
```

## Docker Services

The application stack contains:

- web: Flask application
- nginx: Reverse proxy
- database: PostgreSQL database

---

## Container Networking

Docker Compose creates isolated bridge network:

```text
mywebapp_network
```

All containers communicate internally through this network.


## Persistent Storage

This allows database data to survive container restart and recreation.

## Project Structure

```text
mywebapp/
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
│   │
│   ├── mywebapp/
│   │   └── Dockerfile
│   │
│   └── experiments/
│       │
│       ├── python/
│       │   ├── Dockerfile.bad
│       │   ├── Dockerfile.optimized
│       │   ├── Dockerfile.alpine
│       │   └── README.md
│       │
│       └── golang/
│           ├── Dockerfile.single
│           ├── Dockerfile.scratch
│           ├── Dockerfile.distroless
│           └── README.md
│
├── docs/
│   ├── operator-sudoers.txt
│   └── lab2-report.md
│
├── nginx/
│   ├── mywebapp.conf
│   └── docker-mywebapp.conf
│
├── scripts/
│   └── install.sh
│
├── systemd/
│   ├── mywebapp.service
│   └── mywebapp.socket
│
├── templates/
│
├── .dockerignore
├── .gitignore
│
├── app.py
├── config.json.example
├── docker-compose.yml
├── migrate.py
├── README.md
└── requirements.txt
```

## Deployment

Run:

```bash
bash scripts/install.sh

## Docker Compose

Build and start all services:

```bash
docker compose up --build
```

Check application:

```bash
curl http://localhost/
curl http://localhost/health/alive
curl http://localhost/health/ready
curl -H "Accept: application/json" http://localhost/notes
```

Create note:

```bash
curl -X POST http://localhost/notes \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Test note\",\"content\":\"Hello from Docker\"}"
```

Stop services:

```bash
docker compose down
```

Stop services and remove database volume:

```bash
docker compose down -v
```