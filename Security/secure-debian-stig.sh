#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

VERSION="1.0"
STIG_REF="DOD STIG V1R6 Debian 12"

print_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Debian 12 Hardening Script – STIG Compliance Focused
Version: $VERSION

OPTIONS:
  --disable-services         Disable unnecessary and exposed services
  --systemd-hardening        Apply systemd service hardening
  --mount-hardening          Harden mount options (/dev, /dev/shm)
  --set-umask                Set secure default umask
  --disable-coredumps        Disable core dumps
  --enable-apparmor          Enable and enforce AppArmor
  --all                      Apply all modules
  -h, --help                 Show this help message
EOF
}

disable_services() {
  echo "[+] Disabling unnecessary/exposed services..."
  services=(
    connman.service avahi-daemon.service preload.service
    ModemManager.service dundee.service ofono.service
    cups.service rc-local.service rescue.service
  )
  for svc in "${services[@]}"; do
    if systemctl list-units --full -all | grep -q "$svc"; then
      systemctl disable --now "$svc" 2>/dev/null && echo " - Disabled: $svc"
    fi
  done
}

systemd_hardening() {
  echo "[+] Applying systemd hardening to select services..."
  services=(
    cron.service rsyslog.service ntpsec.service
    smartmontools.service systemd-logind.service
  )
  for svc in "${services[@]}"; do
    dir="/etc/systemd/system/${svc}.d"
    mkdir -p "$dir"
    cat <<EOF >"$dir/hardening.conf"
[Service]
ProtectSystem=strict
ProtectHome=read-only
PrivateTmp=true
NoNewPrivileges=true
CapabilityBoundingSet=~
RestrictAddressFamilies=AF_INET AF_UNIX
MemoryDenyWriteExecute=true
ProtectKernelModules=true
ProtectControlGroups=true
EOF
    echo " - Hardened: $svc"
  done
  systemctl daemon-reexec
  systemctl daemon-reload
}

mount_hardening() {
  echo "[+] Harden /dev and /dev/shm mount options..."
  sed -i '/\/dev\/shm/d' /etc/fstab
  echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
  mount -o remount,noexec,nosuid,nodev /dev/shm
  echo " - /dev/shm remounted with secure options"
}

set_umask() {
  echo "[+] Setting secure default umask to 027..."
  sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
  grep -qF 'umask 027' /etc/profile || echo 'umask 027' >> /etc/profile
  grep -qF 'umask 027' /etc/bash.bashrc || echo 'umask 027' >> /etc/bash.bashrc
}

disable_core_dumps() {
  echo "[+] Disabling core dumps..."
  echo '* hard core 0' >> /etc/security/limits.conf
  grep -qF 'ulimit -c 0' /etc/profile || echo 'ulimit -c 0' >> /etc/profile
  sysctl -w fs.suid_dumpable=0
  echo "fs.suid_dumpable = 0" > /etc/sysctl.d/50-coredump.conf
  sysctl --system
}

enable_apparmor() {
  echo "[+] Ensuring AppArmor is enabled and enforcing..."
  apt install -y apparmor apparmor-utils
  systemctl enable --now apparmor
  aa-enforce /etc/apparmor.d/* || true
}

# Parse arguments
if [[ $# -eq 0 ]]; then
  print_usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --disable-services) disable_services ;;
    --systemd-hardening) systemd_hardening ;;
    --mount-hardening) mount_hardening ;;
    --set-umask) set_umask ;;
    --disable-coredumps) disable_core_dumps ;;
    --enable-apparmor) enable_apparmor ;;
    --all)
      disable_services
      systemd_hardening
      mount_hardening
      set_umask
      disable_core_dumps
      enable_apparmor
      ;;
    -h|--help) print_usage; exit 0 ;;
    *) echo "Unknown option: $1"; print_usage; exit 1 ;;
  esac
  shift
done

echo "[+] All selected hardening steps complete."
