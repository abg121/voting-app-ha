#!/bin/bash
# Failover command for pgpool II
# This script arguments:
# $1: failed node id
# $2: failed node hostname
# $3: failed node port
# $4: failed node database cluster path
# $5: new main node id
# $6: new main node hostname
# $7: new main node port
# $8: old main node id
# $9: old main node hostname
# $10: old main node port

FAILED_NODE_ID=$1
FAILED_NODE_HOST=$2
FAILED_NODE_PORT=$3
FAILED_NODE_PGDATA=$4
NEW_MAIN_NODE_ID=$5
NEW_MAIN_NODE_HOST=$6
NEW_MAIN_NODE_PORT=$7
OLD_MAIN_NODE_ID=$8
OLD_MAIN_NODE_HOST=$9
OLD_MAIN_NODE_PORT=$10

echo "FAILOVER: Failed node: $FAILED_NODE_ID, Host: $FAILED_NODE_HOST, Port: $FAILED_NODE_PORT"
echo "FAILOVER: New main node: $NEW_MAIN_NODE_ID, Host: $NEW_MAIN_NODE_HOST, Port: $NEW_MAIN_NODE_PORT"
echo "FAILOVER: Old main node: $OLD_MAIN_NODE_ID, Host: $OLD_MAIN_NODE_HOST, Port: $OLD_MAIN_NODE_PORT"

# Log the failover
logger -t pgpool_failover "Failed node: $FAILED_NODE_ID, New primary: $NEW_MAIN_NODE_ID"

exit 0;
