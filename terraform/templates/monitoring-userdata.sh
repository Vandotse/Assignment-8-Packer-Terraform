#!/bin/bash
set -e

while ! systemctl is-active --quiet docker; do
  sleep 2
done

# Wait for NAT gateway / internet connectivity before pulling images
for i in $(seq 1 60); do
  if curl -s --max-time 5 -o /dev/null https://registry-1.docker.io/v2/; then
    break
  fi
  sleep 5
done

mkdir -p /home/ec2-user/prometheus
mkdir -p /home/ec2-user/grafana/provisioning/datasources
mkdir -p /home/ec2-user/grafana/provisioning/dashboards
mkdir -p /home/ec2-user/grafana/dashboards

# ── Prometheus configuration ────────────────────────────────────────
cat > /home/ec2-user/prometheus/prometheus.yml <<'PROMCFG'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets:
PROMCFG

%{ for ip in private_ips ~}
echo "          - '${ip}:9100'" >> /home/ec2-user/prometheus/prometheus.yml
%{ endfor ~}
echo "          - '${bastion_ip}:9100'" >> /home/ec2-user/prometheus/prometheus.yml
echo "          - 'localhost:9100'" >> /home/ec2-user/prometheus/prometheus.yml

# ── Grafana datasource provisioning ─────────────────────────────────
cat > /home/ec2-user/grafana/provisioning/datasources/prometheus.yml <<'DSCFG'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    uid: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
DSCFG

# ── Grafana dashboard provisioning config ───────────────────────────
cat > /home/ec2-user/grafana/provisioning/dashboards/dashboards.yml <<'DBCFG'
apiVersion: 1
providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /var/lib/grafana/dashboards
      foldersFromFilesStructure: false
DBCFG

# ── Grafana dashboard JSON (base64-encoded to avoid escaping) ───────
echo "${dashboard_json_b64}" | base64 -d > /home/ec2-user/grafana/dashboards/node-metrics.json

chown -R ec2-user:ec2-user /home/ec2-user/prometheus /home/ec2-user/grafana

# ── Start containers ────────────────────────────────────────────────
docker network create monitoring 2>/dev/null || true

docker run -d \
  --name prometheus \
  --network monitoring \
  --restart unless-stopped \
  -p 9090:9090 \
  -v /home/ec2-user/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus:latest

docker run -d \
  --name grafana \
  --network monitoring \
  --restart unless-stopped \
  -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_USER=admin" \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  -v /home/ec2-user/grafana/provisioning:/etc/grafana/provisioning:ro \
  -v /home/ec2-user/grafana/dashboards:/var/lib/grafana/dashboards:ro \
  grafana/grafana:latest
