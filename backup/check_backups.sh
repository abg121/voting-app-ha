#!/bin/bash

BACKUP_DIR="/home/ubuntu/git/voting-app-ha/backup/postgresql"

echo "=== Backup Status Check ==="
echo "Check time: $(date)"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

# Count backup files
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f | wc -l)

if [ "$BACKUP_COUNT" -eq 0 ]; then
    echo "No backup files found in: $BACKUP_DIR"
    echo "Available files:"
    ls -la "$BACKUP_DIR" || echo "Directory is empty or inaccessible"
    exit 1
fi

echo "Number of backup files: $BACKUP_COUNT"

# Find latest backup
LATEST_BACKUP=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -1 | cut -d' ' -f2-)

if [ -n "$LATEST_BACKUP" ]; then
    echo "Latest backup: $(basename "$LATEST_BACKUP")"
    echo "Backup size: $(du -h "$LATEST_BACKUP" | cut -f1)"
    echo "Backup age: $(find "$LATEST_BACKUP" -printf "%Tc")"

    # Check if backup is recent (less than 24 hours old)
    if find "$LATEST_BACKUP" -mtime -1 | grep -q .; then
        echo "Status: ✅ Backup is recent (less than 24 hours old)"
    else
        echo "Status: ⚠️  Backup is older than 24 hours"
    fi
else
    echo "Status: ❌ No backup files found"
fi

# Show all backups sorted by date
echo ""
echo "=== All Backups ==="
find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f -printf "%Tb %Td %TH:%TM %p\n" | sort -nr
