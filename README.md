# MyWebApp
Опис застосунку: Notes Service — простий сервіс для зберігання текстових нотаток.

## Variant

N = 3

V2 = 2
V3 = 1
V5 = 4

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

## Deployment

Run:

```bash
bash scripts/install.sh