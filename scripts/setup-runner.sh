#!/bin/bash

set -e

apt update

apt install -y \
  curl \
  tar \
  git \
  openssh-client \
  ca-certificates

useradd -m -s /bin/bash github-runner || true

mkdir -p /opt/actions-runner

chown -R github-runner:github-runner /opt/actions-runner

echo "Runner dependencies installed."
echo "Download and configure GitHub self-hosted runner manually using GitHub UI."
echo "Do not store runner registration tokens in repository."