#!/bin/bash

set -e  # Exit on error

echo "Starting setup..."

# Define paths
NODE_EXPORTER_VERSION="1.8.2"
NODE_EXPORTER_DIR="node_exporter-${NODE_EXPORTER_VERSION}.linux-386"
NODE_EXPORTER_ARCHIVE="${NODE_EXPORTER_DIR}.tar.gz"
TEXTFILE_COLLECTOR_DIR="/var/lib/node_exporter/textfile_collector"
NODE_EXPORTER_BIN="/usr/local/bin/node_exporter"

# Extract and install Node Exporter
echo "Extracting Node Exporter..."
tar -xvf $NODE_EXPORTER_ARCHIVE
cd $NODE_EXPORTER_DIR/
sudo mv node_exporter $NODE_EXPORTER_BIN
cd ..
rm -rf $NODE_EXPORTER_DIR

# Create Node Exporter user
echo "Creating node_exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter $NODE_EXPORTER_BIN

# Ensure textfile collector directory exists
echo "Setting up textfile collector directory..."
sudo mkdir -p $TEXTFILE_COLLECTOR_DIR
sudo chown node_exporter:node_exporter $TEXTFILE_COLLECTOR_DIR

# Create Node Exporter systemd service
echo "Creating Node Exporter service..."
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=$NODE_EXPORTER_BIN --collector.textfile.directory=$TEXTFILE_COLLECTOR_DIR
Restart=always

[Install]
WantedBy=default.target
EOF

# Reload and start Node Exporter service
echo "Starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
sudo systemctl status node_exporter --no-pager

### NTP Exporter Setup ###
NTP_SCRIPT="/usr/local/bin/ntp_exporter.sh"
echo "Creating NTP Exporter script..."
cat <<EOF | sudo tee $NTP_SCRIPT
#!/bin/bash
NTP_SERVER=\$(chronyc sources -V | grep -oP '^\^\*? \K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
cat <<EOM > $TEXTFILE_COLLECTOR_DIR/ntp_server.prom
# HELP ntp_server_ip The NTP server currently in use.
# TYPE ntp_server_ip gauge
ntp_server_ip{server="\$NTP_SERVER"} 1
EOM
EOF

# Make script executable
sudo chmod +x $NTP_SCRIPT

# Add cron job for NTP Exporter
echo "Adding NTP Exporter cron job..."
(crontab -l 2>/dev/null; echo "* * * * * $NTP_SCRIPT") | crontab -

### License Days Exporter Setup ###
LICENSE_SCRIPT="/usr/local/bin/license_days_exporter.sh"
echo "Creating License Days Exporter script..."
cat <<EOF | sudo tee $LICENSE_SCRIPT
#!/bin/bash
LAST_END_DATE=\$(subscription-manager list --available | grep "Ends" | tail -n 1 | awk '{print \$2}')
if [ -z "\$LAST_END_DATE" ]; then
    REMAINING_DAYS="NA"
else
    END_DATE_SECONDS=\$(date -d "\$LAST_END_DATE" +%s)
    CURRENT_DATE_SECONDS=\$(date +%s)
    REMAINING_DAYS=\$(( (END_DATE_SECONDS - CURRENT_DATE_SECONDS) / 86400 ))
    if [ "\$REMAINING_DAYS" -lt 0 ]; then
        REMAINING_DAYS=0
    fi
fi
cat <<EOM > $TEXTFILE_COLLECTOR_DIR/license_remaining.prom
# HELP subscription_days_remaining Days remaining for the subscription to expire.
# TYPE subscription_days_remaining gauge
subscription_days_remaining \$REMAINING_DAYS
EOM
EOF

# Make script executable
sudo chmod +x $LICENSE_SCRIPT

# Add cron job for License Days Exporter
echo "Adding License Days Exporter cron job..."
(crontab -l 2>/dev/null; echo "* * * * * $LICENSE_SCRIPT") | crontab -

# Final checks
echo "Checking generated metrics..."
sleep 10  # Wait for cron jobs to execute at least once
cat $TEXTFILE_COLLECTOR_DIR/*.prom

echo "Setup completed successfully!"
