#!/bin/bash

# virtualbox_setup.sh - Combined script for VirtualBox setup
# Combines functionality from:
# 1. addsudo.sh - Add user to sudo group
# 2. time-sync.sh - Configure time synchronization
# 3. sources.list - Update apt sources
# 4. guest-additions.sh - Install VirtualBox Guest Additions

set -e  # Exit on any error

#-------------------------
# Function: Check if running as root
#-------------------------
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Please run as root (e.g. sudo $0 <username>)"
        exit 1
    fi
}

#-------------------------
# Function: Add user to sudo group
#-------------------------
add_to_sudo() {
    # Check for username argument
    if [ -z "$1" ]; then
        echo "❌ Usage: $0 <username>"
        exit 1
    fi

    USERNAME="$1"

    # Check if the user exists
    if id "$USERNAME" &>/dev/null; then
        echo "✅ User '$USERNAME' exists."
    else
        echo "❌ User '$USERNAME' does not exist. Create the user first with 'adduser $USERNAME'"
        exit 1
    fi

    # Add the user to the sudo group
    usermod -aG sudo "$USERNAME"

    # Confirm the user was added
    if id "$USERNAME" | grep -q '\bsudo\b'; then
        echo "✅ '$USERNAME' has been added to the 'sudo' group."
    else
        echo "❌ Failed to add '$USERNAME' to 'sudo' group."
        exit 1
    fi
}

#-------------------------
# Function: Update apt sources
#-------------------------
update_sources() {
    echo "📝 Updating APT sources list..."
    cat > /etc/apt/sources.list << EOF
# updated to fix issues
deb-src http://deb.debian.org/debian/ bookworm main
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
    echo "✅ APT sources updated successfully."
}

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
    apt install -y chrony

    echo "🔁 Enabling and starting chrony..."
    systemctl enable chrony --now
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
    apt install -y ntpdate
    ntpdate pool.ntp.org
    echo
}


#-------------------------
# Function: Update and upgrade system
#-------------------------
update_system() {
    echo "🔄 Updating system packages..."
    apt update && apt upgrade -y
}


#-------------------------
# Function: Install required build tools
#-------------------------
install_dependencies() {
    echo "🧱 Installing build tools and kernel headers..."
    apt install -y build-essential dkms linux-headers-"$(uname -r)"
}

#-------------------------
# Function: Mount Guest Additions CD
#-------------------------
mount_guest_additions_iso() {
    echo "💿 Attempting to mount Guest Additions CD..."
    if [ ! -d /mnt ]; then
        mkdir /mnt
    fi

    if mount | grep -q "/mnt"; then
        echo "✅ ISO already mounted at /mnt."
    else
        mount /dev/cdrom /mnt || {
            echo "❌ Failed to mount /dev/cdrom. Make sure the Guest Additions ISO is inserted from VirtualBox menu: Devices → Insert Guest Additions CD image..."
            exit 1
        }
    fi
}

#-------------------------
# Function: Run the Guest Additions installer
#-------------------------
run_guest_additions_installer() {
    echo "🚀 Running VBoxLinuxAdditions.run installer..."
    if [ -f /mnt/VBoxLinuxAdditions.run ]; then
        sh /mnt/VBoxLinuxAdditions.run || {
            echo "❌ Guest Additions installer failed."
            exit 1
        }
    else
        echo "❌ VBoxLinuxAdditions.run not found. Make sure the ISO is mounted correctly."
        exit 1
    fi
}

#-------------------------
# Function: Confirm installation
#-------------------------
verify_installation() {
    echo "🧪 Verifying Guest Additions installation..."
    lsmod | grep -i vbox || echo "⚠️ Kernel module 'vbox*' not found — may require reboot or indicate an issue."
    pgrep VBox || echo "⚠️ VBox processes not found — check manually after reboot."
}

#-------------------------
# Function: Ask for reboot
#-------------------------
ask_reboot() {
    read -rp "🔁 Reboot now to apply all changes? [Y/n]: " response
    if [[ "$response" =~ ^[Yy]$ || -z "$response" ]]; then
        echo "Rebooting..."
        reboot
    else
        echo "ℹ️ Reboot skipped. Some changes may not take effect until next reboot."
    fi
}

#-------------------------
# Main function
#-------------------------
main() {
    check_root

    # Get username from command line
    USERNAME="$1"

    # Display welcome message
    echo "🖥️  VirtualBox VM Setup Script"
    echo "=============================="
    echo "This script will:"
    echo "1. Add user to sudo group"
    echo "2. Update APT sources"
    echo "3. Configure time synchronization"
    echo "4. Install VirtualBox Guest Additions"
    echo

    # Confirm before proceeding
    read -rp "Continue with setup? [Y/n]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ && ! -z "$confirm" ]]; then
        echo "Setup cancelled."
        exit 0
    fi

    # Step 1: Add user to sudo group
    echo -e "\n📋 STEP 1: Adding user to sudo group"
    echo "----------------------------------------"
    add_to_sudo "$USERNAME"


    # Step 2: Configure time synchronization
    echo -e "\n📋 STEP 3: Configuring time synchronization"
    echo "----------------------------------------"
    check_current_time
    install_chrony
    verify_chrony
    manual_sync_ntpdate

    # Step 3: Update APT sources
    echo -e "\n📋 STEP 2: Updating APT sources"
    echo "----------------------------------------"
    update_sources
    update_system

    # Step 4: Install VirtualBox Guest Additions
    echo -e "\n📋 STEP 4: Installing VirtualBox Guest Additions"
    echo "----------------------------------------"
    install_dependencies
    mount_guest_additions_iso
    run_guest_additions_installer
    verify_installation

    echo -e "\n✅ VirtualBox VM setup completed successfully!"
    ask_reboot
}

# Execute main with all arguments
main "$@"


