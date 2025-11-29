#!/bin/bash
set -e

echo "=== Starting Replica Initialization ==="

# Wait for primary
echo "Waiting for primary database to be ready..."
until psql -h postgres-primary -U postgres -d postgres -c "SELECT 1;" > /dev/null 2>&1; do
  echo "Primary not ready yet, waiting..."
  sleep 5
done

echo "Primary is ready!"

# Determine replica instance and slot name
INSTANCE=${POSTGRES_INSTANCE:-replica1}
if [ "$INSTANCE" = "replica1" ]; then
    slot_name="replica_slot1"
elif [ "$INSTANCE" = "replica2" ]; then
    slot_name="replica_slot2"
else
    slot_name="replica_slot_${INSTANCE}"
fi

echo "Configuring as $INSTANCE with slot: $slot_name"

# Wait a bit more to ensure primary is fully ready
sleep 10

# Test replication connection with password
echo "Testing replication connection..."
export PGPASSWORD=replicator_password

# Check if slot already exists, if not create it
if ! psql -h postgres-primary -U replicator -d postgres -c "SELECT * FROM pg_replication_slots WHERE slot_name = '$slot_name';" | grep -q "$slot_name"; then
    echo "Creating replication slot: $slot_name"
    psql -h postgres-primary -U replicator -d postgres -c "SELECT pg_create_physical_replication_slot('$slot_name', true);"
else
    echo "Replication slot $slot_name already exists"
fi

# Clear existing data
echo "Clearing existing data..."
rm -rf /var/lib/postgresql/data/*

# Perform base backup with password and slot
echo "Starting base backup with slot: $slot_name"
pg_basebackup \
    -h postgres-primary \
    -D /var/lib/postgresql/data \
    -U replicator \
    -P \
    -v \
    -R \
    -X stream \
    -S "$slot_name"

echo "Base backup completed successfully!"

# Ensure proper ownership
chown -R postgres:postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

echo "=== Replica initialization complete ==="
