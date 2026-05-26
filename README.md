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
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── database.py
│   └── models.py
│
├── docs/
│   └── operator-sudoers.txt
│
├── nginx/
│   └── mywebapp.conf
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
├── venv/
│
├── .gitignore
├── app.py
├── config.json.example
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