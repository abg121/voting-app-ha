#!/bin/bash
set -e

echo "=== Starting Primary Database Initialization ==="

# Wait for PostgreSQL to start
until pg_isready -U $POSTGRES_USER; do
    echo "Waiting for PostgreSQL to start..."
    sleep 2
done

echo "PostgreSQL is ready, running initialization script..."

# Execute SQL commands one by one to avoid syntax errors
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create replication user if not exists
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'replicator') THEN
            CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';
            RAISE NOTICE 'Created replicator user';
        ELSE
            RAISE NOTICE 'Replicator user already exists';
        END IF;
    END
    \$\$;
EOSQL

# Drop existing slots
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT pg_drop_replication_slot(slot_name)
    FROM pg_replication_slots
    WHERE slot_name IN ('replica_slot1', 'replica_slot2');
EOSQL

# Create replication slots
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT pg_create_physical_replication_slot('replica_slot1', true);
    SELECT pg_create_physical_replication_slot('replica_slot2', true);
EOSQL

# Create publication (without IF NOT EXISTS for compatibility)
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DROP PUBLICATION IF EXISTS pub;
    CREATE PUBLICATION pub FOR ALL TABLES;
EOSQL

# Add replication rules to pg_hba.conf
echo "Adding replication rules to pg_hba.conf..."
cat >> /var/lib/postgresql/data/pg_hba.conf <<-EOCONF

# Replication connections - added by init script
host replication replicator 0.0.0.0/0 md5
host all replicator 0.0.0.0/0 md5
EOCONF

echo "=== Primary Database Initialization Completed ==="
echo "Replication slots created: replica_slot1, replica_slot2"
echo "Replication rules added to pg_hba.conf"
