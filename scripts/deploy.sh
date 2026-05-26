#!/bin/bash

set -e

if [ -z "$TARGET_HOST" ]; then
  echo "TARGET_HOST is not set"
  exit 1
fi

if [ -z "$TARGET_USER" ]; then
  echo "TARGET_USER is not set"
  exit 1
fi

if [ -z "$APP_IMAGE" ]; then
  echo "APP_IMAGE is not set"
  exit 1
fi

ssh "$TARGET_USER@$TARGET_HOST" "mkdir -p /opt/mywebapp/config /opt/mywebapp/nginx"

scp docker-compose.prod.yml "$TARGET_USER@$TARGET_HOST:/opt/mywebapp/docker-compose.prod.yml"
scp config/app_config.json "$TARGET_USER@$TARGET_HOST:/opt/mywebapp/config/app_config.json"
scp nginx/docker-mywebapp.conf "$TARGET_USER@$TARGET_HOST:/opt/mywebapp/nginx/docker-mywebapp.conf"

ssh "$TARGET_USER@$TARGET_HOST" "cat > /opt/mywebapp/.env <<EOF
APP_IMAGE=$APP_IMAGE
EOF"

ssh "$TARGET_USER@$TARGET_HOST" "docker pull $APP_IMAGE"
ssh "$TARGET_USER@$TARGET_HOST" "systemctl restart mywebapp-container.service"

echo "Deployment completed"