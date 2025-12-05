# Voting App with High Availability (HA)

Production-grade voting application with full high-availability for databases and services — built with Docker Compose.

![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?logo=redis&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-24B7A3?logo=traefikmesh&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)

## Features
- PostgreSQL HA (1 Primary + 2 Replicas with streaming replication)
- Redis HA (3 nodes + 3 Sentinels + HAProxy automatic failover < 10s)
- Traefik reverse proxy (HTTP + TCP)
- Full Voting App (Vote + .NET Worker + Node.js Result)
- WordPress with MySQL (via Traefik)
- Monitoring: Prometheus + Grafana + cAdvisor
- Logging: ELK Stack + Filebeat
- Automated daily PostgreSQL backup (7-day retention)
- Zero-downtime capable

## Architecture

```mermaid
flowchart TD
    A[Client] --> B(Traefik :80/443/8080)

    B --> C[Vote App :5000]
    B --> D[Result App :5001]
    B --> WP[WordPress :8080]

    B --> E[PostgreSQL :5432]
    B --> F[Redis :6379 via HAProxy]

    E --> G[(Primary)]
    E --> H[(Replica 1)]
    E --> I[(Replica 2)]

    F --> HP[HAProxy]
    HP --> RC[(Redis Cluster + 3 Sentinels)]
    RC --> R1[redis-a]
    RC --> R2[redis-b]
    RC --> R3[redis-c]

    subgraph Monitoring
        GRAF[Grafana :3000] --> PROM[Prometheus]
        PROM --> CADV[cAdvisor]
    end

    subgraph Logging
        KIB[Kibana :5601] --> ES[Elasticsearch]
        ES --> FB[Filebeat]
    end

    subgraph Backup
        BACKUP[Daily Backup] -->|pg_dumpall| G
    end

    style B fill:#24B7A3,stroke:#fff,color:#fff
    style G fill:#28a745,stroke:#fff,color:#fff
    style HP fill:#dc3545,stroke:#fff,color:#fff
