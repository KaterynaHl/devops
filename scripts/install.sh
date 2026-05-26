#!/bin/bash

set -e

apt update

apt install -y \
python3 \
python3-pip \
python3-venv \
postgresql \
postgresql-contrib \
nginx

useradd -r -s /usr/sbin/nologin app || true

useradd -m -s /bin/bash student || true
useradd -m -s /bin/bash teacher || true
useradd -m -s /bin/bash operator || true

echo "teacher:12345678" | chpasswd
echo "operator:12345678" | chpasswd

chage -d 0 teacher
chage -d 0 operator

mkdir -p /etc/mywebapp

cp config.json.example /etc/mywebapp/config.json

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt

sudo -u postgres psql <<EOF
CREATE USER mywebapp WITH PASSWORD 'password';
CREATE DATABASE mywebapp;
GRANT ALL PRIVILEGES ON DATABASE mywebapp TO mywebapp;
EOF

python migrate.py

cp systemd/mywebapp.service /etc/systemd/system/
cp systemd/mywebapp.socket /etc/systemd/system/

systemctl daemon-reload

systemctl enable mywebapp.service
systemctl enable mywebapp.socket

systemctl restart mywebapp.socket

cp nginx/mywebapp.conf /etc/nginx/sites-available/mywebapp

ln -sf \
/etc/nginx/sites-available/mywebapp \
/etc/nginx/sites-enabled/mywebapp

nginx -t

systemctl restart nginx

echo "3" > /home/student/gradebook

passwd -l ubuntu || true
passwd -l user || true