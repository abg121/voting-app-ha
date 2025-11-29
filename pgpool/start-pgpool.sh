#!/bin/sh
echo "Starting Pgpool-II with custom configuration..."
exec /opt/pgpool-II/bin/pgpool -n -f /opt/pgpool-II/etc/pgpool.conf -a /opt/pgpool-II/etc/pool_hba.conf
