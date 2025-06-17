#!/bin/bash
# harden-services.sh
# Purpose: Apply security hardening for a list of services marked as UNSAFE in Lynis scan
# Platform: Debian 12
# Shell: zsh or bash compatible

SERVICES=(
  "alsa-state.service"
  "anacron.service"
  "avahi-daemon.service"
  "clamav-daemon.service"
  "cron.service"
  "cups-browsed.service"
  "cups.service"
  "dbus.service"
  "dm-event.service"
  "emergency.service"
  "exim4.service"
  "fail2ban.service"
  "getty@tty1.service"
  "lightdm.service"
  "lvm2-lvmpolld.service"
  "lynis.service"
  "plymouth-start.service"
  "polkit.service"
  "rc-local.service"
  "rescue.service"
  "rsyslog.service"
  "smartmontools.service"
  "ssh.service"
  "suricata.service"
  "systemd-ask-password-console.service"
  "systemd-ask-password-plymouth.service"
  "systemd-ask-password-wall.service"
  "systemd-fsckd.service"
  "systemd-initctl.service"
  "systemd-rfkill.service"
  "udisks2.service"
  "unattended-upgrades.service"
  "user@1000.service"
  "vboxadd-service.service"
  "wpa_supplicant.service"
)

# Create override directory and secure each service
for SERVICE in "${SERVICES[@]}"; do
  echo "Hardening $SERVICE..."

  mkdir -p "/etc/systemd/system/$SERVICE.d"
  cat <<EOF > "/etc/systemd/system/$SERVICE.d/harden.conf"
[Service]
# Drop all capabilities not needed
CapabilityBoundingSet=
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
RestrictRealtime=true
RestrictSUIDSGID=true
LockPersonality=true
MemoryDenyWriteExecute=true
SystemCallFilter=@system-service
SystemCallArchitectures=native
EOF

done

# Reload systemd and show status
systemctl daemon-reexec
systemctl daemon-reload

echo "\nSecurity hardening overrides have been applied to ${#SERVICES[@]} services."
echo "Please review and restart each service as needed."
echo "Example: systemctl restart <service>.service"
