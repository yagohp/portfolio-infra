#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/opt/stacks/backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$BACKUP_DIR"

echo "Initializing PostgreSQL backup in $BACKUP_DIR..."
docker exec postgres pg_dump -U admin -d npm_db > "$BACKUP_DIR/npm_$DATE.sql"

gzip "$BACKUP_DIR/npm_$DATE.sql"
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +7 -exec rm {} \;

echo "Backups finished!"