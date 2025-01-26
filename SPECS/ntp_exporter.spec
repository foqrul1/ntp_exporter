cat <<'EOF' > ~/rpmbuild/SPECS/ntp_exporter.spec
Name: ntp_exporter
Version: 1.0
Release: 1%{?dist}
Summary: NTP server metric exporter for Prometheus
License: GPL
Source0: node_exporter/ntp_exporter.sh
Source1: node_exporter/node_exporter.service
BuildArch: noarch
Requires: node_exporter, chrony, cronie

%description
This RPM sets up an NTP server metric exporter for Prometheus using Node Exporter's textfile collector.

%prep
%setup -q -c -T

%install
install -Dm0755 %{SOURCE0} %{buildroot}/usr/local/bin/ntp_exporter.sh
install -Dm0644 %{SOURCE1} %{buildroot}/etc/systemd/system/node_exporter.service

mkdir -p %{buildroot}/var/lib/node_exporter/textfile_collector
chown -R node_exporter:node_exporter %{buildroot}/var/lib/node_exporter/textfile_collector

%post
systemctl daemon-reload
systemctl restart node_exporter
echo "* * * * * /usr/local/bin/ntp_exporter.sh" | crontab -u root -

%files
/usr/local/bin/ntp_exporter.sh
/etc/systemd/system/node_exporter.service
/var/lib/node_exporter/textfile_collector

%changelog
* Sun Jan 26 2025 Admin <admin@example.com> - 1.0-1
- Initial release
EOF

