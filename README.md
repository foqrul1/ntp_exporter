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
