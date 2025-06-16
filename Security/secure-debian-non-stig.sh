#!/usr/bin/env bash


set -euo pipefail
IFS=$'\n\t'

echo "[+] Starting Debian 12 Security Hardening..."

### Function: Disable unneeded services
disable_services=(
  connman.service
  avahi-daemon.service
  preload.service
  ModemManager.service
  dundee.service
  ofono.service
  cups.service
  emergency.service
  rc-local.service
  rescue.service
)

echo "[+] Disabling unnecessary or exposed services..."
for svc in "${disable_services[@]}"; do
  if systemctl is-enabled --quiet "$svc"; then
    echo " - Disabling $svc"
    systemctl disable --now "$svc"
  fi
done

### Function: Apply systemd hardening to critical services
harden_service() {
  local service="$1"
  echo "[+] Hardening $service..."

  mkdir -p "/etc/systemd/system/${service}.d"
  cat <<EOF >"/etc/systemd/system/${service}.d/harden.conf"
[Service]
ProtectSystem=strict
ProtectHome=read-only
PrivateTmp=true
NoNewPrivileges=true
CapabilityBoundingSet=~CAP_SYS_ADMIN CAP_NET_ADMIN
RestrictAddressFamilies=AF_INET AF_UNIX
EOF
  systemctl daemon-reexec
  systemctl daemon-reload
}

services_to_harden=(
  cron.service
  rsyslog.service
  ntpsec.service
  smartmontools.service
)

for s in "${services_to_harden[@]}"; do
  harden_service "$s"
done

### Function: Harden mount points
echo "[+] Hardening /dev/shm..."
sed -i '/\/dev\/shm/d' /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
mount -o remount /dev/shm

### Function: Set secure umask
echo "[+] Setting secure default umask..."
sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
echo 'umask 027' >> /etc/profile

### Function: Disable core dumps
echo "[+] Disabling core dumps..."
echo '* hard core 0' >> /etc/security/limits.conf
echo 'ulimit -c 0' >> /etc/profile

### Function: Ensure AppArmor is enabled
echo "[+] Ensuring AppArmor is installed and active..."
apt install -y apparmor apparmor-utils
systemctl enable --now apparmor

echo "[+] System hardened. Recommend a reboot for full effect."
