#!/bin/bash

# Paths for configuration files
PROMETHEUS_CONFIG_FILE="./prometheus/prometheus.yml"
HOSTS_FILE="hosts.json"
GRAFANA_INI_PATH="grafana/provisioning/grafana.ini"
CONFIG_CFG_FILE="config.cfg"

# Function to configure Prometheus
configure_prometheus() {
  # Check if hosts.json exists
  if [ ! -f "$HOSTS_FILE" ]; then
    echo "Error: $HOSTS_FILE not found."
    exit 1
  fi

  # Start the Prometheus config
  echo "global:" > $PROMETHEUS_CONFIG_FILE
  echo "  scrape_interval: 15s" >> $PROMETHEUS_CONFIG_FILE
  echo "" >> $PROMETHEUS_CONFIG_FILE
  echo "scrape_configs:" >> $PROMETHEUS_CONFIG_FILE

  # Create a temporary file for grouping targets by category
  TEMP_FILE=$(mktemp)

  # Read hosts.json and group targets by category
  jq -c '.[]' $HOSTS_FILE | while read -r host; do
    NAME=$(echo "$host" | jq -r '.[0]')
    IP=$(echo "$host" | jq -r '.[1]')
    CATEGORY=$(echo "$host" | jq -r '.[2]')

    # Append target info to the temp file grouped by category
    echo "$CATEGORY $IP:9100 $NAME" >> "$TEMP_FILE"
  done

  # Process the grouped targets to create scrape_configs
  for CATEGORY in $(cut -d' ' -f1 "$TEMP_FILE" | sort | uniq); do
    echo "  - job_name: \"$CATEGORY\"" >> $PROMETHEUS_CONFIG_FILE
    echo "    static_configs:" >> $PROMETHEUS_CONFIG_FILE
    grep "^$CATEGORY" "$TEMP_FILE" | while read -r LINE; do
      TARGET=$(echo "$LINE" | awk '{print $2}')
      INSTANCE=$(echo "$LINE" | awk '{print $3}')
      echo "      - targets: [\"$TARGET\"]" >> $PROMETHEUS_CONFIG_FILE
      echo "        labels:" >> $PROMETHEUS_CONFIG_FILE
      echo "          instance: \"$INSTANCE\"" >> $PROMETHEUS_CONFIG_FILE
    done
  done

  # Clean up the temporary file
  rm "$TEMP_FILE"

  echo "Prometheus configuration file generated: $PROMETHEUS_CONFIG_FILE"
}

# Function to configure Grafana
configure_grafana() {
  # Check if config.cfg exists
  if [ ! -f "$CONFIG_CFG_FILE" ]; then
    echo "Error: $CONFIG_CFG_FILE not found."
    exit 1
  fi

  # Source the config file to load environment variables
  source "$CONFIG_CFG_FILE"

  # Generate grafana.ini dynamically
  cat <<EOF > "$GRAFANA_INI_PATH"
[security]
admin_user = $GRAFANA_ADMIN_USER
admin_password = $GRAFANA_ADMIN_PASSWORD

[smtp]
enabled = true
host = $SMTP_HOST:$SMTP_PORT
user = $SMTP_USER
password = $SMTP_PASSWORD
from_address = $ALERTMANAGER_EMAIL_FROM

[alerting]
execute_alerts = true

[server]
http_addr = 0.0.0.0
http_port = 3000
EOF

  echo "Grafana configuration file generated: $GRAFANA_INI_PATH"
}

# Main script execution
echo "Configuring Prometheus..."
configure_prometheus

echo "Configuring Grafana..."
configure_grafana

echo "Configuration complete."