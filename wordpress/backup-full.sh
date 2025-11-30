#!/bin/bash

# Load environment variables
set -a
source ./.env
set +a

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/wordpress_full_$DATE.tar.gz"

mkdir -p $BACKUP_DIR

echo "Starting full site backup..."

# Stop services to ensure data consistency
docker-compose stop wordpress

# Create full backup (excluding backups directory and itself)
tar -czf $BACKUP_FILE \
  --exclude='backups' \
  --exclude='*.tar.gz' \
  --exclude='*.log' \
  .

# Start services back
docker-compose start wordpress

if [ $? -eq 0 ]; then
  echo "Full site backup completed: $BACKUP_FILE"

  # Clean up old full backups
  find $BACKUP_DIR -name "wordpress_full_*.tar.gz" -mtime +$FULL_BACKUP_RETENTION_DAYS -delete
  echo "Old full backups cleaned (retention: $FULL_BACKUP_RETENTION_DAYS days)"
else
  echo "Full site backup failed!"
  exit 1
fi
