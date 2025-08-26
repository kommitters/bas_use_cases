## Prerequisites

### Read-only user on the target postgres database.

Create a read-only role first for Grafana to connect safely to the database.

```sql
CREATE ROLE read_only_access;
GRANT CONNECT ON DATABASE postgres TO read_only_access;
GRANT USAGE ON SCHEMA public TO read_only_access;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only_access;

CREATE USER read_only_user WITH PASSWORD 'changeme';
GRANT read_only_access TO read_only_user;
```

## Local development

```bash
docker compose pull
```

If you are running postgres on the same machine, you need to add both postgres and grafana to the same network and set
a hostname for the postgres service.

```sh
docker network create databases-local
```

```yml
services:
  postgres:
    networks:
      - databases-local
    hostname: postgres.local

# On grafana-docker-compose.yml
networks:
  databases-local:
    external: true
    name: databases-local

services:
  grafana:
    networks:
      - databases-local
```

Spin up the services:

```bash
docker compose up -d
```

### Access Grafana

- Open a web browser on your Windows machine and navigate to http://<server-ip>:3000
- Default username and password: `admin` / `admin`
- Upon your first login, Grafana will require you to set a new, secure password.
