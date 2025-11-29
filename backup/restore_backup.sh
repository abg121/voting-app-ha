#!/bin/bash

BACKUP_DIR="/home/ubuntu/git/voting-app-ha/backup/postgresql"

echo "=== PostgreSQL Backup Restore ==="

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

# List available backups
echo "Available backups:"
find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f -printf "%Tb %Td %TH:%TM | %p\n" | sort -nr

echo ""
echo "Enter the backup filename to restore (or press Enter for latest):"
read -r BACKUP_CHOICE

if [ -z "$BACKUP_CHOICE" ]; then
    # Use latest backup
    BACKUP_FILE=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -1 | cut -d' ' -f2-)
else
    # Use selected backup
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_CHOICE"
fi

# Validate backup file
if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo ""
echo "Selected backup: $(basename "$BACKUP_FILE")"
echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo "Backup date: $(find "$BACKUP_FILE" -printf "%Tc")"

# Confirmation
echo ""
echo "⚠️  WARNING: This will overwrite all current data in the database!"
echo "Are you sure you want to continue? (yes/no)"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Restore process
echo ""
echo "Starting restore process..."

# Stop applications that use database (if needed)
# docker compose stop voting-app result-app worker

# Restore backup
echo "Restoring backup..."
gunzip -c "$BACKUP_FILE" | docker compose exec -T postgres-primary psql -U postgres -h localhost -p 5432

if [ $? -eq 0 ]; then
    echo "✅ Restore completed successfully!"

    # Start applications again
    # docker compose start voting-app result-app worker
    # echo "Applications restarted"
else
    echo "❌ Restore failed!"
    exit 1
fi

echo "Restore finished at: $(date)"
