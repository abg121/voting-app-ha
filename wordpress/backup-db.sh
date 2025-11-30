#!/bin/bash

# Load environment variables
set -a
source ./.env
source ./.db.env
set +a

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_BACKUP="$BACKUP_DIR/wordpress_db_$DATE.sql"

mkdir -p $BACKUP_DIR

echo "Starting database backup..."

# Backup database
docker-compose exec -T db mysqldump \
  -u $MYSQL_USER \
  -p$MYSQL_PASSWORD \
  $MYSQL_DATABASE > $DB_BACKUP

# Check if backup was successful
if [ $? -eq 0 ]; then
  # Compress backup
  gzip $DB_BACKUP
  echo "Database backup completed: $DB_BACKUP.gz"

  # Clean up old backups (keep last X days)
  find $BACKUP_DIR -name "wordpress_db_*.sql.gz" -mtime +$BACKUP_RETENTION_DAYS -delete
  echo "Old backups cleaned (retention: $BACKUP_RETENTION_DAYS days)"
else
  echo "Database backup failed!"
  rm -f $DB_BACKUP
  exit 1
fi
