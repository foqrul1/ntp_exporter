cat <<EOF > README.md
# NTP Exporter

This project provides an RPM package for exporting NTP server metrics as Prometheus-compatible metrics.

## Features
- Automatically extracts the NTP server from `chronyc`.
- Exports the data via Node Exporter's textfile collector.
- Installs systemd configuration and cron job.

## Installation
1. Build the RPM:
   ```bash
   rpmbuild -ba SPECS/ntp_exporter.spec


How to Use setup_monitoring.sh  Script
Copy and save it as setup_monitoring.sh.
Make it executable:
bash
Copy
Edit
chmod +x setup_monitoring.sh
Run the script:
bash
Copy
Edit
sudo ./setup_monitoring.sh
What This Script Does
✅ Installs Node Exporter and sets it up as a systemd service
✅ Sets up NTP Exporter and configures it to run every minute via cron
✅ Sets up License Days Exporter and configures it to run every minute via cron
✅ Creates necessary directories (/var/lib/node_exporter/textfile_collector)
✅ Ensures proper permissions and ownership
✅ Starts all services and verifies their status
✅ Checks if metrics are being generated correctly

This single script automates everything, so you don’t need to run multiple scripts manually. 🚀 Let me know if you need modifications! 😊
