#!/usr/bin/env bash


set -e  # Exit immediately on any error

#-------------------------------
# Function: Update and upgrade system
#-------------------------------
update_system() {
    echo "🔄 Updating system packages..."
    sudo apt update && sudo apt upgrade -y
}

#-------------------------------
# Function: Install required build tools
#-------------------------------
install_dependencies() {
    echo "🧱 Installing build tools and kernel headers..."
    sudo apt install -y build-essential dkms linux-headers-"$(uname -r)"
}

#-------------------------------
# Function: Mount Guest Additions CD
#-------------------------------
mount_guest_additions_iso() {
    echo "💿 Attempting to mount Guest Additions CD..."
    if [ ! -d /mnt ]; then
        sudo mkdir /mnt
    fi

    if mount | grep -q "/mnt"; then
        echo "✅ ISO already mounted at /mnt."
    else
        sudo mount /dev/cdrom /mnt || {
            echo "❌ Failed to mount /dev/cdrom. Make sure the Guest Additions ISO is inserted from VirtualBox menu: Devices → Insert Guest Additions CD image..."
            exit 1
        }
    fi
}

#-------------------------------
# Function: Run the Guest Additions installer
#-------------------------------
run_guest_additions_installer() {
    echo "🚀 Running VBoxLinuxAdditions.run installer..."
    if [ -f /mnt/VBoxLinuxAdditions.run ]; then
        sudo sh /mnt/VBoxLinuxAdditions.run || {
            echo "❌ Guest Additions installer failed."
            exit 1
        }
    else
        echo "❌ VBoxLinuxAdditions.run not found. Make sure the ISO is mounted correctly."
        exit 1
    fi
}

#-------------------------------
# Function: Confirm installation
#-------------------------------
verify_installation() {
    echo "🧪 Verifying Guest Additions installation..."
    lsmod | grep -i vbox || echo "⚠️ Kernel module 'vbox*' not found — may require reboot or indicate an issue."
    pgrep VBox || echo "⚠️ VBox processes not found — check manually after reboot."
}

#-------------------------------
# Function: Reboot the system
#-------------------------------
reboot_system() {
    read -rp "🔁 Reboot now to apply Guest Additions? [Y/n]: " response
    if [[ "$response" =~ ^[Yy]$ || -z "$response" ]]; then
        echo "Rebooting..."
        sudo reboot
    else
        echo "ℹ️ Reboot skipped. Guest Additions may not fully work until next reboot."
    fi
}

#-------------------------------
# Main Function
#-------------------------------
main() {
    update_system
    install_dependencies
    mount_guest_additions_iso
    run_guest_additions_installer
    verify_installation
    reboot_system
}

# Execute main
main
