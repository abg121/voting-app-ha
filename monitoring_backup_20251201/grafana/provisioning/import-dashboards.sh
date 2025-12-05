#!/bin/bash

echo "🕒 Waiting for Grafana to be ready..."
until curl -s http://admin:admin123@grafana:3000/api/health > /dev/null; do
    sleep 5
done

echo "📊 Setting up Grafana dashboards..."
sleep 10

# Install jq if not present
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    apk add --no-cache jq > /dev/null 2>&1 || apt-get update && apt-get install -y jq > /dev/null 2>&1
fi

# Import all dashboards (simple approach - let Grafana handle updates via provisioning)
echo "Importing dashboards from provisioning directory..."
# Grafana will auto-load dashboards from the provisioning directory
# No need for manual import when using provisioning

echo "🎉 Dashboards setup complete!"
