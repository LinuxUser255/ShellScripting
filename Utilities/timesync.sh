#!/usr/bin/env bash

#!/bin/bash

set -e  # Exit on any error

#-------------------------
# Function: Check current time
#-------------------------
check_current_time() {
    echo "🕒 Current system time:"
    date
    echo
}

#-------------------------
# Function: Install and configure chrony
#-------------------------
install_chrony() {
    echo "📦 Installing chrony (best for VMs)..."
    sudo apt update
    sudo apt install -y chrony

    echo "🔁 Enabling and starting chrony..."
    sudo systemctl enable chrony --now
}

#-------------------------
# Function: Verify chrony status
#-------------------------
verify_chrony() {
    echo "✅ Verifying chrony status..."
    chronyc tracking
    echo
    timedatectl status
    echo
}

#-------------------------
# Function: One-time sync with ntpdate (optional)
#-------------------------
manual_sync_ntpdate() {
    echo "⏳ Optionally forcing one-time sync with ntpdate..."
    sudo apt install -y ntpdate
    sudo ntpdate pool.ntp.org
    echo
}

#-------------------------
# Main driver
#-------------------------
main() {
    check_current_time
    install_chrony
    verify_chrony
    echo "✅ Time sync setup completed for VirtualBox VM."
}

# Run main
main

