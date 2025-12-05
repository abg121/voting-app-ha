#!/bin/bash

echo "🕒 Waiting for Grafana to be ready..."
until curl -s http://grafana:3000/api/health > /dev/null; do
    sleep 5
done

echo "📊 Importing dashboards..."

# Import voting-app dashboard
curl -X POST http://admin:admin123@grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @/provisioning/dashboards/voting-app.json > /dev/null 2>&1 && echo "✅ Voting App Dashboard imported"

# Import postgresql-overview dashboard
curl -X POST http://admin:admin123@grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @/provisioning/dashboards/postgresql-overview.json > /dev/null 2>&1 && echo "✅ PostgreSQL Dashboard imported"

# Import system-overview dashboard
curl -X POST http://admin:admin123@grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @/provisioning/dashboards/system-overview.json > /dev/null 2>&1 && echo "✅ System Overview Dashboard imported"

# Import redis official dashboard (763)
curl -X POST http://admin:admin123@grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @/provisioning/dashboards/redis-763-fixed.json > /dev/null 2>&1 && echo "✅ Redis Official Dashboard 763 imported"

echo "🎉 All dashboards imported successfully!"
