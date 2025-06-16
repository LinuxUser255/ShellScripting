#!/usr/bin/env bash

#!/bin/bash

# Exit on error
set -e

echo "🔐 Installing SELinux on Debian 12 in ENFORCING mode..."

# Step 1: Update packages
echo "📦 Updating APT package index..."
sudo apt update

# Step 2: Install core SELinux packages
echo "📥 Installing SELinux components..."
sudo apt install -y selinux-basics selinux-policy-default auditd

# Step 3: Activate SELinux (default is permissive)
echo "⚙️ Activating SELinux..."
sudo selinux-activate

# Step 4: Set SELinux to enforcing mode in config file
echo "🛠️ Setting SELinux mode to enforcing in /etc/selinux/config..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Step 5: Touch .autorelabel to force full filesystem relabel
echo "🧹 Scheduling full filesystem relabel on next boot..."
sudo touch /.autorelabel

# Step 6: Optional - disable AppArmor
read -p "❓ Disable AppArmor to avoid conflicts? (y/N): " disable_apparmor
if [[ "$disable_apparmor" =~ ^[Yy]$ ]]; then
    echo "🛑 Disabling AppArmor..."
    sudo systemctl disable apparmor
    sudo apt remove -y apparmor
fi

# Step 7: Prompt for reboot
read -p "🔁 Reboot now to complete SELinux activation in enforcing mode? (Y/n): " reboot_now
if [[ "$reboot_now" =~ ^[Nn]$ ]]; then
    echo "✅ SELinux installed and configured. Please reboot manually to apply changes."
else
    echo "🔄 Rebooting now..."
    sudo reboot
fi
