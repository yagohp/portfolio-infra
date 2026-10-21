#!/usr/bin/env bash
set -euo pipefail # strict mode

echo "[1/5] Configuring user permissions for $USER..."

# Add the current user to the docker's group
sudo usermod -aG docker "$USER" 2>/dev/null || true

# Fix ownership of ~/.docker (avoids "permission denied" on config.json
# after previous "sudo docker" runs left the directory owned by root)
sudo chown -R "$USER":"$USER" "$HOME/.docker" 2>/dev/null || true

echo "Permission applied."

echo "[2/5] Installing Docker dependencies..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg ufw git

# Removes old versions
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc 2>/dev/null || true

# Docker oficial repo and key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[3/5] Configuring Firewall (UFW)..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 81/tcp   # NPM
sudo ufw allow 9443/tcp # Portainer
sudo ufw allow 9000/tcp # Portainer HTTP
sudo ufw allow 8080/tcp # Jenkins
sudo ufw --force enable

echo "[4/5] Creating Docker networks..."
sudo docker network create proxy 2>/dev/null || true
sudo docker network create db-net 2>/dev/null || true

echo "[5/5] Creating backup directory /opt/stacks/backups..."
sudo mkdir -p /opt/stacks/backups
sudo chown -R $USER:$USER /opt/stacks

echo "Host successfully configured!"
echo "Next steps:"
echo "1. Log out and log back in (to apply docker group)."
echo "2. Run 'make up' from inside the repository."