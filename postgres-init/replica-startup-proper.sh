#!/bin/bash
set -e

DATA_DIR="/var/lib/postgresql/data"
STANDBY_SIGNAL="$DATA_DIR/standby.signal"

# Only run initialization if not already a replica
if [ ! -f "$STANDBY_SIGNAL" ]; then
    echo "=== Initializing as new replica ==="
    /docker-entrypoint-initdb.d/replica-reliable.sh
fi

echo "=== Starting PostgreSQL replica ==="
exec docker-entrypoint.sh postgres
