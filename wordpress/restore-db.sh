#!/bin/bash

# Load environment variables
set -a
source ./.env
source ./.db.env
set +a

if [ -z "$1" ]; then
  echo "Usage: $0 <backup_file.sql.gz>"
  echo "Available backups:"
  ls -la ./backups/wordpress_db_*.sql.gz 2>/dev/null || echo "No backups found"
  exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "Starting database restore from: $BACKUP_FILE"

# Stop WordPress to prevent data corruption
docker-compose stop wordpress

# Restore database
gunzip -c $BACKUP_FILE | docker-compose exec -T db mysql \
  -u $MYSQL_USER \
  -p$MYSQL_PASSWORD \
  $MYSQL_DATABASE

# Start services
docker-compose start wordpress

echo "Database restored successfully from: $BACKUP_FILE"

