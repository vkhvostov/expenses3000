# expenses3000 monitoring

Run commands from the repository root; `make up` starts monitoring, while `make dev` does not.

## Setup

1. Copy `.env.example` to `.env` if missing, then replace these placeholders; generate passwords with `openssl rand -hex 24`:

   ```env
   POSTGRES_EXPORTER_PASSWORD=<monitoring-database-password>
   GRAFANA_ADMIN_USER=<grafana-admin-username>
   GRAFANA_ADMIN_PASSWORD=<grafana-admin-password>
   ```

2. Run `make up`; Compose creates the monitoring database user and Grafana loads its dashboards automatically.
   After changing the exporter password, run `docker compose up -d` to update the database role and exporter; restarting alone does not apply the change.

## Access

| Resource | Location |
|---|---|
| Grafana | https://localhost:3002; sign in with the credentials from `.env` |
| Dashboards | expenses3000 → Backend-Dashboard / Database-Dashboard |
| Alerts | https://localhost:3002/alerting/list |

Nginx terminates HTTPS on the loopback-only host port 3002 and forwards requests to Grafana over the internal Docker network. Grafana has no direct host port and uses secure login cookies. Plain HTTP on port 3002 redirects to HTTPS. The existing mkcert certificate also covers this endpoint.

Prometheus, exporters and backend metrics stay inside Docker; do not expose their unauthenticated ports.
Dashboard files are in `monitoring/grafana/`; alert rules are in `monitoring/alerts.yml`.
Prometheus evaluates alert rules without sending external notifications; inspect alert state in Grafana.

## Verify alerts

- Run `sh scripts/monitoring.check.sh` to validate the Compose and Prometheus configurations, including alert rules
- Open Grafana in a private browser window and confirm login is required
- Run `NODE_EXTRA_CA_CERTS=nginx/certs/ca/rootCA.pem node scripts/grafana-https.check.mjs` against the running full stack to check HTTPS, the HTTP redirect and blocked anonymous API access
- In Grafana Explore, check `up{job="backend"}` and `pg_up{job="postgres-exporter"}` both return `1`

Alerts cover backend/database/exporter availability, high error rate, slow responses and database connection queues.
