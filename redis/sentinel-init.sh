#!/bin/sh
set -e

echo "Waiting for Redis master to be ready..."
until redis-cli -h redis-a -p 6379 ping; do
  sleep 2
done

echo "Getting Redis master IP..."
REDIS_MASTER_IP=$(getent hosts redis-a | awk '{ print $1 }')
echo "Redis master IP: $REDIS_MASTER_IP"

# Create dynamic sentinel configuration
cat > /tmp/sentinel-dynamic.conf << CONF
port 26379
dir /tmp
sentinel monitor mymaster $REDIS_MASTER_IP 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
sentinel parallel-syncs mymaster 1
CONF

echo "Starting Redis Sentinel with dynamic configuration..."
exec redis-sentinel /tmp/sentinel-dynamic.conf
