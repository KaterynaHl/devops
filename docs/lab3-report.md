# Лабораторна робота №3

# CI/CD

---

## Мета роботи

Метою лабораторної роботи є налаштування процесів Continuous Integration та Continuous Delivery для веб-застосунку, розробленого у Лабораторній роботі №1.

У межах роботи було налаштовано:

- статичний аналіз коду;
- автоматичне тестування;
- перевірку покриття тестами;
- збірку Docker-образу;
- публікацію образу в GitHub Container Registry;
- скрипти для розгортання на target node;
- скрипти верифікації після розгортання;
- документацію для self-hosted runner.

---

## Зв’язок із попередніми лабораторними роботами

Лабораторна робота №3 базується на результатах попередніх робіт.

### Лабораторна робота №1

З ЛР1 використано:

- Flask-застосунок `mywebapp`;
- API для Notes Service;
- health endpoints `/health/alive` та `/health/ready`;
- конфігурацію через файл;
- PostgreSQL;
- nginx reverse proxy;
- systemd unit;
- deployment scripts.

### Лабораторна робота №2

З ЛР2 використано:

- Dockerfile для застосунку;
- Docker Compose;
- контейнеризацію Flask-застосунку;
- PostgreSQL container;
- nginx container;
- Docker network;
- volume для збереження даних БД.

---

## Структура CI/CD

CI/CD pipeline описаний у файлі:

```text
.github/workflows/ci-cd.yml
```

Pipeline складається з таких етапів:

1. Static analysis
2. Automated tests
3. Build and publish image
4. Deploy to target node
5. Verify deployment

---

## Static Analysis

Для статичного аналізу були використані такі інструменти:

| Інструмент | Призначення |
|---|---|
| flake8 | Перевірка Python-коду |
| yamllint | Перевірка YAML-файлів |
| shellcheck | Перевірка shell-скриптів |
| hadolint | Перевірка Dockerfile |

Перевірялися:

- Python-код застосунку;
- тести;
- shell-скрипти для deployment;
- Dockerfile;
- GitHub Actions workflow;
- Docker Compose файли.

---

## Автоматичні тести

Для тестування використано `pytest`.

Файл із тестами:

```text
tests/test_app.py
```

Тестами перевіряються:

- доступність `/health/alive`;
- наявність endpoint-ів на головній сторінці;
- обробка некоректного POST-запиту до `/notes`;
- перевірка `/matrix`;
- структура JSON-відповіді.

---

## Coverage

Для перевірки покриття тестами використано `pytest-cov`.

У workflow задано мінімальний поріг покриття:

```text
40%
```

Команда запуску тестів:

```bash
pytest --cov=. --cov-report=xml --cov-fail-under=40
```

Звіт про покриття завантажується як GitHub Actions artifact:

```text
coverage-report
```

---

## Docker Image Build

Застосунок збирається у production Docker-образ за допомогою Dockerfile:

```text
docker/mywebapp/Dockerfile
```

Образ публікується в GitHub Container Registry.

Для комітів у гілку використовуються теги:

```text
latest
sha-<full-commit-hash>
```

Для annotated tags використовуються теги:

```text
stable
<tag>
```

---

## Deployment

Для розгортання використовується окрема target node.

Розгортання виконується не на self-hosted runner, а на окремій віртуальній машині, доступній через SSH.

Для підготовки target node створено скрипт:

```text
scripts/bootstrap-target.sh
```

Він встановлює:

- Docker;
- Docker Compose plugin;
- nginx;
- необхідні директорії;
- systemd unit для контейнерного deployment.

---

## Self-hosted Runner

Для self-hosted runner створено допоміжний скрипт:

```text
scripts/setup-runner.sh
```

Скрипт встановлює залежності для runner VM.

Реєстраційний токен GitHub runner не зберігається у репозиторії, оскільки це чутлива інформація.

Інструкція з налаштування runner описана у файлі:

```text
docs/runner-setup.md
```

---

## Deployment Script

Файл:

```text
scripts/deploy.sh
```

Скрипт виконує:

- підключення до target node через SSH;
- копіювання `docker-compose.prod.yml`;
- копіювання конфігурації застосунку;
- копіювання nginx-конфігурації;
- створення `.env` з образом застосунку;
- `docker pull`;
- restart systemd service.

---

## Verification Script

Файл:

```text
scripts/verify.sh
```

Скрипт перевіряє:

- головну сторінку;
- `/health/alive`;
- `/health/ready`;
- `/notes`;
- `/matrix`.

---

## Systemd Unit для контейнерного deployment

Файл:

```text
systemd/mywebapp-container.service
```

Цей unit керує Docker Compose stack:

- start;
- stop;
- reload/restart.

Socket activation у цій лабораторній роботі не використовується, оскільки застосунок розгортається в контейнері.

---

## GitHub Secrets

Для deployment використовуються GitHub Secrets:

| Secret | Призначення |
|---|---|
| TARGET_HOST | Адреса target node |
| TARGET_USER | Користувач для SSH |
| TARGET_SSH_KEY | Приватний SSH-ключ |
| GITHUB_TOKEN | Токен GitHub Actions для GHCR |

Чутливі дані не зберігаються в репозиторії.

---

## Демонстрація роботи CI/CD

### Невдалі запуски CI

Під час налаштування pipeline було отримано кілька невдалих запусків GitHub Actions.

Основні причини:

- flake8 formatting errors;
- yamllint formatting errors;
- shellcheck warnings;
- hadolint warning DL3013.

Скріншот:

```text
docs/screenshots/ci-failed-runs.png
```

Ці помилки були використані для поетапного налагодження pipeline.

---

### Успішний Pull Request

У межах роботи потрібно створити PR, який проходить усі перевірки.

Очікуваний сценарій:

```text
lab3-docs-success → lab3
```

PR має пройти:

- Static analysis;
- Automated tests;
- Build and publish image.

Скріншот після проходження перевірок:

```text
docs/screenshots/pr-success.png
```

---

### Невдалий Pull Request

Також створюється PR із навмисною помилкою, який не може бути злитий через failed checks.

Очікуваний сценарій:

```text
lab3-failing-check → lab3
```

Наприклад, у код додається некоректний імпорт або синтаксична помилка.

Скріншот:

```text
docs/screenshots/pr-failed.png
```

---

### Успішне розгортання та верифікація

Після створення annotated tag pipeline має виконати:

```text
Build → Deploy → Verify
```

Приклад tag:

```bash
git tag -a v1.0.0 -m "release v1.0.0"
git push origin v1.0.0
```

Очікувані скріншоти:

```text
docs/screenshots/deploy-success.png
docs/screenshots/verify-success.png
```

---

### Успішне розгортання та неуспішна верифікація

Для демонстрації failed verification можна тимчасово змінити `scripts/verify.sh`, наприклад перевіряти неіснуючий endpoint.

Очікуваний результат:

- deploy job успішний;
- verify job failed.

Скріншот:

```text
docs/screenshots/deploy-success-verify-failed.png
```

---

## Проблеми під час виконання

Під час налаштування CI/CD pipeline виникали такі проблеми:

### flake8

Проблеми:

- відсутність newline в кінці файлів;
- зайві пробіли у порожніх рядках;
- недостатня кількість порожніх рядків між функціями.

Вирішення:

- виправлено форматування Python-файлів;
- налаштовано `.flake8`.

### yamllint

Проблеми:

- CRLF замість LF;
- відсутність `---` на початку YAML-файлів;
- довгі рядки.

Вирішення:

- додано `.gitattributes`;
- додано `.yamllint.yml`;
- YAML-файли переведені у LF.

### shellcheck

Проблеми:

- SC1091 для `/etc/os-release`;
- SC2029 для SSH-команд.

Вирішення:

- для deployment scripts додано виключення для контекстно залежних warning-ів.

### hadolint

Проблема:

```text
DL3013 Pin versions in pip
```

Вирішення:

- зафіксовано версію pip у Dockerfile;
- додано використання `--requirement requirements.txt`.

---

## Висновки

У ході лабораторної роботи було налаштовано CI/CD pipeline для проєкту з Лабораторної роботи №1.

Було реалізовано:

- статичний аналіз коду;
- автоматичне тестування;
- coverage check;
- збірку Docker-образу;
- публікацію образу в GitHub Container Registry;
- deployment scripts;
- verification scripts;
- systemd unit для container deployment;
- документацію для self-hosted runner.

Лабораторна робота показала, що CI/CD дозволяє автоматизувати перевірку якості коду, зменшити кількість помилок перед deployment і зробити процес розгортання більш контрольованим та відтворюваним.
