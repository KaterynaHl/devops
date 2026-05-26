FROM python:3.12-slim

WORKDIR /opt/mywebapp

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .

RUN python -m pip install --no-cache-dir pip==25.1.1 \
    && python -m pip install --no-cache-dir --requirement requirements.txt

COPY app/ app/
COPY app.py .
COPY migrate.py .
COPY config.json.example ./config.json

EXPOSE 8000

CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:8000", "app:app"]
