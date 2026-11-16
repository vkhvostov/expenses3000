#!/bin/sh
# Validate monitoring configs offline, using disposable containers.
set -eu
cd "$(dirname "$0")/.."

alertmanager_image=prom/alertmanager:v0.34.2
prometheus_image=prom/prometheus:v3.15.1

docker compose config --quiet

docker run --rm --network none --entrypoint /bin/promtool \
  -v "$PWD/monitoring:/etc/prometheus:ro" \
  "$prometheus_image" check config /etc/prometheus/prometheus.yml

docker run --rm --network none --entrypoint /bin/amtool \
  -v "$PWD/monitoring:/etc/alertmanager:ro" \
  "$alertmanager_image" check-config /etc/alertmanager/alertmanager.yml
