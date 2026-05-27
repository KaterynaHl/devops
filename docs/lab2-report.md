# ЛАБОРАТОРНА РОБОТА №2

# Контейнеризація застосунків та Docker Compose

---

# Мета роботи

Метою завдання є практичне закріплення знань з таких тем курсу: Основи контейнеризації. Використання docker для упаковки застосунку. Використання docker compose для запуску програмної системи, що складається з декількох сервісів.

---

# Варіант

```text
N = 3

V2 = (N % 2) + 1 = (3 % 2) + 1 = 2

V3 = (N % 3) + 1 = (3 % 3) + 1 = 1

V5 = (N % 5) + 1 = (3 % 5) + 1 = 4
```

## Відповідно до варіанту

- застосунок: Notes Service
- база даних: PostgreSQL
- спосіб конфігурації: config file
- порт застосунку: 8000

---

# Методологія дослідження

Для виконання досліджень використовувалися:

- Docker
- Docker Compose
- Python 3.12
- PostgreSQL
- nginx
- Golang
- Alpine Linux
- Debian slim images

## Вимірювання часу збірки

```bash
time docker build -t image-name .
```

## Перегляд розміру образу

```bash
docker image ls
```

Базові образи попередньо завантажувалися через:

```bash
docker pull python:3.12-slim
docker pull python:3.12-alpine
```

для виключення часу завантаження образів із результатів експериментів.

---

# Дослідницька частина

# Дослідження контейнеризації Python-застосунку

Було використано starter project:

```text
https://github.com/KPI-FICT-MTSD/lab-03-starter-project-python
```

---

# Експеримент 1 — неоптимізований Dockerfile

Було створено Dockerfile із неефективним використанням Docker layers.

## Dockerfile.bad

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "app.py"]
```

---

# Результати першої збірки

Розмір образу: ~430 MB 
Час збірки: ~58 с 

---

# Повторна збірка після зміни коду

Було змінено файл `app.py` шляхом додавання коментаря.

## Результати повторної збірки

Розмір образу: ~430 MB
Час збірки: ~54 с

---

# Аналіз результатів

Через використання інструкції:

```dockerfile
COPY . .
```

до встановлення залежностей Docker втрачав кешування layer із Python-пакетами.

Будь-яка зміна application code призводила до повторного встановлення всіх залежностей.

Це значно збільшувало час rebuild образу.

---

# Експеримент 2 — оптимізований Dockerfile

Було змінено порядок Docker layers.

## Dockerfile.optimized

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

---

# Результати першої збірки

Розмір образу: ~430 MB
Час збірки: ~56 с

---

# Повторна збірка після зміни коду

Було повторно змінено файл `app.py`.

## Результати повторної збірки

Розмір образу: ~430 MB
Час збірки: ~6 с

---

# Аналіз результатів

Після винесення `requirements.txt` в окремий Docker layer залежності почали кешуватися окремо від application code.

При зміні лише коду застосунку Docker повторно виконував лише останні етапи збірки.

Це дозволило значно скоротити час rebuild контейнера.

---

# Експеримент 3 — Alpine image

Було використано Alpine-based image.

## Dockerfile.alpine

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

---

# Результати збірки

Розмір образу: ~145 MB
Час збірки: ~79 с

---

# Аналіз результатів

Alpine image дозволив значно зменшити розмір Docker-образу.

Проте час збірки збільшився через використання musl libc та необхідність компіляції деяких Python-залежностей із вихідного коду.

Alpine image підходить для deployment сценаріїв, де критично важливий мінімальний розмір контейнера.

---

# Експеримент із numpy

До проєкту було додано залежність:

```txt
numpy==2.1.3
```

Було реалізовано endpoint `/matrix`, який:

- генерує дві випадкові матриці 10x10;
- виконує множення матриць;
- повертає результат у JSON.

---

# Реалізований endpoint

```python
@app.route("/matrix")
def matrix():
    matrix_a = np.random.randint(1, 10, (10, 10))
    matrix_b = np.random.randint(1, 10, (10, 10))

    product = np.matmul(matrix_a, matrix_b)

    return jsonify({
        "matrix_a": matrix_a.tolist(),
        "matrix_b": matrix_b.tolist(),
        "product": product.tolist()
    })
```

---

# Порівняння Debian vs Alpine після додавання numpy

python:3.12-slim: ~510 MB ~67 с
python:3.12-alpine: ~320 MB ~145 с

---

# Аналіз результатів

Після додавання numpy різниця між Debian та Alpine стала значно помітнішою.

У Debian-based image використовувалися готові binary wheels.

У Alpine image numpy компілювався з вихідного коду через використання musl libc.

Це значно збільшило час збірки контейнера.

Під час тестування Alpine image також спостерігалися складнощі із залежностями, які потребують native compilation.

---

# Musl (Alpine) vs glibc (Debian/Ubuntu/etc)

## Створення docker network

```bash
docker network create dns-lab
```

---

## Запуск DNS server

```bash
docker run --rm -it \
--name dns-server \
--network dns-lab \
alpine sh -c "
apk add dnsmasq &&
echo 'address=/myservice.internal.corp/10.0.0.50' > /etc/dnsmasq.conf &&
dnsmasq -k --log-queries --log-facility=-"
```

---

## Ubuntu DNS test

```bash
docker run --rm --network dns-lab \
--dns=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dns-server) \
--dns-search="corp" \
ubuntu:latest getent hosts myservice.internal
```

---

## Alpine DNS test

```bash
docker run --rm --network dns-lab \
--dns=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dns-server) \
--dns-search="corp" \
alpine:latest getent hosts myservice.internal
```

---

# Аналіз DNS resolution

Ubuntu-контейнер коректно використовував DNS search domains та успішно резолвив домен.

Alpine-контейнер поводився інакше через використання musl libc.

Було помічено:

- різницю в DNS retries;
- відмінності у search domain behavior;
- паралельні A та AAAA queries.

---

## Логи DNS-сервера (dnsmasq)

```text
dnsmasq: query[A] myservice.internal.corp from 172.20.0.3
dnsmasq: reply myservice.internal.corp is 10.0.0.50
```

Ubuntu використовує glibc, яка послідовно підставляє search domains із `resolv.conf`.

Alpine Linux використовує musl libc, яка має іншу реалізацію DNS resolution та інакше працює із search domains і retries.

У musl libc DNS-запити можуть виконуватися паралельно, а логіка обробки DNS suffixes відрізняється від glibc.

У великих distributed systems це може призводити до проблем із Service Discovery, коли контейнери не можуть коректно знаходити один одного за короткими DNS-іменами.

---

# Golang Application та Multi-stage builds

Було використано starter project:

```text
https://github.com/comsys-kpi-ua/deploy.lab-containers-starter-project-golang
```

---

# Single-stage build

## Dockerfile.single

```dockerfile
FROM golang:1.23

WORKDIR /app

COPY . .

RUN go build -o server .

CMD ["./server"]
```

---

# Результати

Розмір образу: ~820 MB
Час збірки: ~43 с

---

# Аналіз

Образ містив:

- Go compiler;
- build cache;
- source code;
- runtime dependencies.

Більшість цих файлів не потрібна для запуску застосунку.

---

# Multi-stage build (scratch)

## Dockerfile.scratch

```dockerfile
FROM golang:1.23 AS builder

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM scratch

COPY --from=builder /app/server /server

CMD ["/server"]
```

---

# Результати

Розмір образу: ~14 MB
Час збірки: ~47 с

---

# Аналіз

Образ містив лише compiled binary.

Переваги:

- мінімальний розмір;
- мінімальна attack surface.

Недоліки:

- відсутність shell;
- складність debugging;
- неможливість запуску shell-команд усередині контейнера.

---

## Дослідження помилки лінковки

Під час першої спроби збірки scratch image без використання:

```bash
CGO_ENABLED=0
```

контейнер завершувався помилкою:

```text
standard_init_linux.go:228: exec user process caused: no such file or directory
```

Причина полягає у тому, що Go за замовчуванням використовує динамічну лінковку з glibc.

У scratch image відсутні будь-які системні бібліотеки, включно з glibc, тому binary файл не міг бути запущений.

Для вирішення проблеми було використано:

```bash
CGO_ENABLED=0
```

Це дозволило створити повністю статично злинкований binary файл без зовнішніх runtime-залежностей.

---

# Multi-stage build (distroless)

## Dockerfile.distroless

```dockerfile
FROM golang:1.23 AS builder

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM gcr.io/distroless/static-debian12

COPY --from=builder /app/server /server

CMD ["/server"]
```

---

# Результати

Розмір образу: ~32 MB
Час збірки: ~49 с

---

# Аналіз

Distroless image є компромісом між scratch image та повноцінними Linux-based images.

Переваги:

- менший розмір;
- покращена безпека;
- наявність базових runtime-компонентів.

Distroless image краще підходить для production deployment.

---

# Практична частина

Для контейнеризації застосунку з Лабораторної роботи №1 було створено:

- Dockerfile для Flask-застосунку;
- docker-compose.yml;
- nginx reverse proxy;
- PostgreSQL database container.

---

# docker-compose.yml

```yaml
services:
  database:
    image: postgres:16

    environment:
      POSTGRES_DB: mywebapp
      POSTGRES_USER: mywebapp
      POSTGRES_PASSWORD: password

    volumes:
      - postgres_data:/var/lib/postgresql/data

    networks:
      - mywebapp_network

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mywebapp"]
      interval: 5s
      timeout: 5s
      retries: 5

  web:
    build:
      context: .
      dockerfile: docker/mywebapp/Dockerfile

    depends_on:
      database:
        condition: service_healthy

    volumes:
      - ./config/app_config.json:/opt/mywebapp/config.json:ro

    networks:
      - mywebapp_network

  nginx:
    image: nginx:1.27

    depends_on:
      - web

    ports:
      - "80:80"

    volumes:
      - ./nginx/docker-mywebapp.conf:/etc/nginx/conf.d/default.conf:ro

    networks:
      - mywebapp_network

volumes:
  postgres_data:

networks:
  mywebapp_network:
    driver: bridge
```

---

# nginx reverse proxy

```nginx
server {
    listen 80;

    location / {
        proxy_pass http://web:8000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

# Запуск контейнерів

```bash
docker compose up --build
```

---

# Перевірка роботи застосунку

## Головна сторінка

```bash
curl http://localhost/
```

---

## Health endpoints

```bash
curl http://localhost/health/alive

curl http://localhost/health/ready
```

---

## Список нотаток

```bash
curl -H "Accept: application/json" http://localhost/notes
```

---

## Створення нотатки

```bash
curl -X POST http://localhost/notes \
-H "Content-Type: application/json" \
-d "{\"title\":\"Test\",\"content\":\"Docker note\"}"
```

---

# Висновки

Було реалізовано:

- контейнеризацію Flask-застосунку;
- запуск PostgreSQL у контейнері;
- reverse proxy через nginx;
- Docker Compose orchestration;
- окрему мережу для сервісів;
- volume для збереження даних БД.

Було встановлено:

- порядок Docker layers критично впливає на швидкість rebuild;
- Alpine image дозволяє суттєво зменшити розмір контейнера;
- musl libc та glibc мають різну DNS-поведінку;
- multi-stage builds значно зменшують розмір Go image;
- distroless images є хорошим production-рішенням.

Контейнеризація значно спрощує розгортання, масштабування та підтримку багатосервісних систем.