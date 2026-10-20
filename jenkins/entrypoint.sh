#!/usr/bin/env bash
set -e

echo "[entrypoint] Configuring known_hosts for the user jenkins..."

# ─── For user jenkins (HOME=/var/jenkins_home) ───
mkdir -p /var/jenkins_home/.ssh
ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> /var/jenkins_home/.ssh/known_hosts 2>/dev/null
chmod 700 /var/jenkins_home/.ssh
chmod 644 /var/jenkins_home/.ssh/known_hosts

echo "[entrypoint] known_hosts configured:"
wc -l /var/jenkins_home/.ssh/known_hosts 2>/dev/null

echo "[entrypoint] Initializing Jenkins..."
exec /usr/local/bin/jenkins.sh "$@"