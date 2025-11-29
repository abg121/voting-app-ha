#!/bin/bash
BACKUP_DIR="/home/ubuntu/git/voting-app-ha/backup/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"
COMPRESSED_FILE="$BACKUP_FILE.gz"

echo "Starting backup at $(date)"

# Create directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Direct backup from PostgreSQL primary
echo "Creating database backup..."
docker compose exec -T postgres-primary pg_dumpall -U postgres -h localhost -p 5432 > $BACKUP_FILE

# Check if backup was successful
if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
    echo "Backup created successfully, size: $(du -h "$BACKUP_FILE" | cut -f1)"

    # Compression
    echo "Compressing backup..."
    gzip $BACKUP_FILE

    if [ $? -eq 0 ] && [ -f "$COMPRESSED_FILE" ]; then
        echo "Compression completed successfully"

        # Remove old backups
        echo "Cleaning up old backups..."
        find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

        # Final report
        echo "Backup completed successfully: $(basename $COMPRESSED_FILE)"
        echo "Final backup size: $(du -h "$COMPRESSED_FILE" | cut -f1)"
        echo "Backup finished at $(date)"
    else
        echo "Compression failed!"
        # Keep uncompressed backup if compression fails
        echo "Keeping uncompressed backup: $(basename $BACKUP_FILE)"
        exit 1
    fi
else
    echo "Backup failed or created empty file!"
    [ -f "$BACKUP_FILE" ] && rm -f "$BACKUP_FILE"
    exit 1
fi
