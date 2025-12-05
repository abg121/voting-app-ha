![Docker Compose](https://img.shields.io/badge/Docker%20Compose-1.0-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-green)
![Redis](https://img.shields.io/badge/Redis-7-red)
![Traefik](https://img.shields.io/badge/Traefik-v2.11-orange)
# Voting App with High Availability (HA)
-----------------------------------------
A production-grade, fully functional voting application with complete high-availability for databases and services — built with Docker Compose.

![Architecture Overview](https://via.placeholder.com/1200x600.png?text=Voting+App+HA+Architecture)


## Features
------------
- **PostgreSQL HA** – 1 Primary + 2 Replicas with streaming replication
- **Redis HA** – 3-node cluster + 3 Sentinels + HAProxy with automatic failover (< 10s)
- **Traefik** – Reverse proxy & load balancer (HTTP + TCP)
- **Voting App** – Full stack from Docker Samples (Vote, .NET Worker, Node.js Result)
- **Monitoring** – Prometheus + Grafana + cAdvisor + Node Exporter
- **Centralized Logging** – ELK Stack (Elasticsearch, Logstash, Kibana) + Filebeat
- **Automated Backups** – Daily PostgreSQL backup with 7-day retention
- **Failover Scripts** – Automatic Redis failover, scripted PostgreSQL failover


## Architecture
----------------
Clients
↓
Traefik (80, 443, 5432, 6379)
├──→ HAProxy → Redis Cluster + Sentinel
├──→ PostgreSQL Primary/Replica (via Patroni or scripts)
└──→ Voting App (Vote, Worker, Result)
↓
Monitoring → Grafana / Prometheus
Logging   → Kibana / Elasticsearch


## Quick Start
---------------
```bash
git clone https://github.com/abg121/voting-app-ha.git
cd voting-app-ha

# Edit passwords if needed
cp .env.example .env

# Start everything
docker compose up -d


## Access URLs
---------------
Service,URL,Default Credentials
Vote App,http://your-server:5000,-
Result App,http://your-server:5001,-
Grafana,http://your-server:3000,admin / admin
Kibana,http://your-server:5601,-
Traefik Dashboard,http://your-server:8080,-
PostgreSQL,your-server:5432,user: postgres
Redis,your-server:6379,no password


## Failover Test
-----------------
# Kill current PostgreSQL primary
docker stop postgres-primary
sleep 20
psql -h your-server -p 5432 -U postgres -c "SELECT now();"

# Kill current Redis master
docker stop redis-a
sleep 15
redis-cli -h your-server -p 6379 PING   # Still returns PONG


## Automated Backups
---------------------
# Manual backup
docker exec pg-backup /backup/simple-pg-backup.sh

# List backups
docker exec pg-backup ls -lh /backups


## Project Structure
---------------------
voting-app-ha/
├── backup/                  # PostgreSQL backup scripts
├── postgres-init/           # Primary & replica initialization
├── redis/                   # Redis cluster + Sentinel + Sentinel + HAProxy
├── haproxy/                 # HAProxy configs
├── traefik/                 # Traefik reverse proxy
├── monitoring/              # Prometheus, Grafana, cAdvisor, ELK
├── voting-app/              # Vote, Worker, Result apps
├── docker-compose.yml       # Main orchestration
├── switch-primary.sh        # PostgreSQL failover helper
└── README.md                # This file


## Production Notes
--------------------
All services use persistent volumes
Health checks and restart policies enabled
Graceful reloads during config changes
Ready for migration to Kubernetes (Helm + ArgoCD + Longhorn + KEDA)

## Author & Contact
--------------------
GitHub: @abg121
Project Status: Fully functional & tested

