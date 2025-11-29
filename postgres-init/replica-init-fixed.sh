#!/bin/bash
set -e

echo "=== REPLICA INIT FIXED: Starting automatic setup ==="

# Create .pgpass for authentication
echo "postgres-primary:5432:replication:replicator:replicator_password" > /var/lib/postgresql/.pgpass
chmod 600 /var/lib/postgresql/.pgpass
chown postgres:postgres /var/lib/postgresql/.pgpass

# Wait for primary to be ready
echo "Waiting for primary database..."
until pg_isready -h postgres-primary -U postgres; do
    echo "Primary not ready, waiting..."
    sleep 5
done

echo "✅ Primary is ready"

# Better way to determine replica identity - use container name from hostname
CONTAINER_NAME=$(cat /etc/hostname)
echo "Container name: $CONTAINER_NAME"

# Determine slot name based on container name
if [[ "$CONTAINER_NAME" == *"replica1"* ]]; then
    SLOT_NAME="replica_slot1"
    echo "Configuring as replica1 with slot: $SLOT_NAME"
elif [[ "$CONTAINER_NAME" == *"replica2"* ]]; then
    SLOT_NAME="replica_slot2"
    echo "Configuring as replica2 with slot: $SLOT_NAME"
else
    # Fallback: use hostname
    SLOT_NAME="replica_slot_${HOSTNAME}"
    echo "⚠️ Could not determine replica, using slot: $SLOT_NAME"
fi

# Clean data directory
echo "Cleaning data directory..."
rm -rf /var/lib/postgresql/data/*

# Perform base backup with slot
echo "Starting base backup with slot: $SLOT_NAME"
PGPASSFILE=/var/lib/postgresql/.pgpass pg_basebackup \
    -h postgres-primary \
    -D /var/lib/postgresql/data \
    -U replicator \
    -P \
    -v \
    -R \
    -X stream \
    -S "$SLOT_NAME"

echo "✅ Base backup completed"

# Verify and set slot name in config
echo "Configuring slot name: $SLOT_NAME"
echo "primary_slot_name = '$SLOT_NAME'" >> /var/lib/postgresql/data/postgresql.auto.conf

# Set proper permissions
chown -R postgres:postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

echo "🎉 REPLICA INIT FIXED: Setup completed successfully for $CONTAINER_NAME"
echo "Starting PostgreSQL replica..."
exec gosu postgres postgres
