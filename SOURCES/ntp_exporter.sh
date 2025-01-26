cat <<'EOF' > ~/rpmbuild/SOURCES/node_exporter/ntp_exporter.sh
#!/bin/bash
# Script to export NTP server information as a Prometheus metric

# Extract the NTP server IP from chronyc sources -V
NTP_SERVER=$(chronyc sources -V | grep -oP '^\^\*? \K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

# Generate a Prometheus-compatible metric file
cat <<EOF_METRIC > /var/lib/node_exporter/textfile_collector/ntp_server.prom
# HELP ntp_server_ip The NTP server currently in use.
# TYPE ntp_server_ip gauge
ntp_server_ip{server="$NTP_SERVER"} 1
EOF_METRIC
EOF
chmod +x ~/rpmbuild/SOURCES/node_exporter/ntp_exporter.sh

