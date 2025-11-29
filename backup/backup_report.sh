#!/bin/bash

BACKUP_DIR="/home/ubuntu/git/voting-app-ha/backup/postgresql"

echo "=== Backup System Report ==="
echo "Generated: $(date)"
echo ""

# Database information
echo "Database Information:"
docker compose exec -T postgres-primary psql -U postgres -c "
SELECT
    datname as database,
    pg_size_pretty(pg_database_size(datname)) as size
FROM pg_database
WHERE datistemplate = false;
"
echo ""

# Backup information
echo "Backup Information:"
if [ -d "$BACKUP_DIR" ]; then
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f | wc -l)
    TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    LATEST_BACKUP=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -type f -printf "%T@ %p\n" | sort -nr | head -1 | cut -d' ' -f2-)

    echo "Total backups: $BACKUP_COUNT"
    echo "Total backup size: $TOTAL_SIZE"

    if [ -n "$LATEST_BACKUP" ]; then
        echo "Latest backup: $(basename "$LATEST_BACKUP")"
        echo "Latest backup size: $(du -h "$LATEST_BACKUP" | cut -f1)"
        echo "Latest backup time: $(find "$LATEST_BACKUP" -printf "%Tc")"
    else
        echo "Latest backup: None"
    fi
else
    echo "Backup directory not found: $BACKUP_DIR"
fi

echo ""

# Cron jobs (if any)
echo "Cron Jobs:"
crontab -l | grep -i backup || echo "No backup-related cron jobs found"

echo ""

# Backup scripts
echo "Backup Scripts:"
find /home/ubuntu/git/voting-app-ha/backup -name "*.sh" -type f -exec ls -la {} \;
