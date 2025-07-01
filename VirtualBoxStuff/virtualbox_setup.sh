#!/bin/bash

# Automate the annoying parts of setting up a new VirtualBox guest machine
# Run this on a fresh install of a Linux iso in VirtualBox
# change to the root user
# then run this script like this:
# sudo ./virtualbox_setup.sh yourusernamehere

# What is does:
# 1. Add user to sudo group ( for obvious reasons )
# 2. Configure time synchronization (so that you can access the apt repositories)
# 3. Update apt sources (debian 12 is using newer apt usrls)
# 4. Install the VirtualBox Guest Additions (for screen resizes, and shared clipboard)

set -e  # Exit on any error


# you must run this script as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        printf "\e[1m\e[31m[WARNING] Please run as root e.g. sudo %s username\e[0m\n" "$0"
        exit 1
    fi
}

# Add the user to sudo group
add_to_sudo() {
        [ -z "$1" ] && printf "\e[1m\e[31m[WARNING] Usage: %s <username>\e[0m\n" "$0" && exit 1

        USERNAME="$1"

        if id "$USERNAME" &>/dev/null; then
        printf "\e[1m\e[31m[SUCCESS] User '%s' exists.\e[0m\n" "$USERNAME"

        else
            printf "\e[1m\e[31m[ERROR] User '%s' does not exist. Create the user first with 'adduser %s'\e[0m\n" "$USERNAME" "$USERNAME"
            exit 1
        fi

        # Ensure the required package is installed
        if ! command -v usermod &>/dev/null; then
            printf "\e[1m\e[31m[INFO] Installing required packages for user management...\e[0m\n"
            apt update
            apt install -y passwd
        fi

        usermod -aG sudo "$USERNAME"

        # Confirm the user was added
        if id "$USERNAME" | grep -q '\bsudo\b'; then
            printf "\e[1m\e[31m[SUCCESS] '%s' has been added to the 'sudo' group.\e[0m\n" "$USERNAME"
        else
            printf "\e[1m\e[31m[ERROR] Failed to add '%s' to 'sudo' group.\e[0m\n" "$USERNAME"
            exit 1
        fi
}

update_sources() {
    printf "\e[1m\e[31m[INFO] Updating APT sources list...\e[0m\n"
    cat > /etc/apt/sources.list << EOF
# updated to fix issues
deb-src http://deb.debian.org/debian/ bookworm main
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
    printf "\e[1m\e[31m[SUCCESS] APT sources updated successfully.\e[0m\n"
}

check_current_time() {
        printf "\e[1m\e[31m[INFO] Current system time:\e[0m\n"
        date
        printf "\n"
}

install_chrony() {
        printf "\e[1m\e[31m[INFO] Installing chrony (best for VMs)...\e[0m\n"
        apt install -y chrony

        printf "\e[1m\e[31m[INFO] Enabling and starting chrony...\e[0m\n"
        systemctl enable chrony --now
}

verify_chrony() {
        printf "\e[1m\e[31m[INFO] Verifying chrony status...\e[0m\n"
        chronyc tracking
        printf "\n"
        timedatectl status
        printf "\n"
}

manual_sync_ntpdate() {
        printf "\e[1m\e[31m[INFO] Optionally forcing one-time sync with ntpdate...\e[0m\n"
        apt install -y ntpdate
        ntpdate pool.ntp.org
        printf "\n"
}


update_system() {
        printf "\e[1m\e[31m[INFO] Updating system packages...\e[0m\n"
        apt update && apt upgrade -y
}


install_dependencies() {
        printf "\e[1m\e[31m[INFO] Installing build tools and kernel headers...\e[0m\n"
        apt install -y build-essential dkms linux-headers-"$(uname -r)"
}

mount_guest_additions_iso() {
        printf "\e[1m\e[31m[INFO] Attempting to mount Guest Additions CD...\e[0m\n"
        if [ ! -d /mnt ]; then
            mkdir /mnt
        fi

        if mount | grep -q "/mnt"; then
            printf "\e[1m\e[31m[SUCCESS] ISO already mounted at /mnt.\e[0m\n"
        else
            mount /dev/cdrom /mnt || {
                printf "\e[1m\e[31m[ERROR] Failed to mount /dev/cdrom. Make sure the Guest Additions ISO is inserted from VirtualBox menu: Devices → Insert Guest Additions CD image...\e[0m\n"
                exit 1
            }
        fi
}

run_guest_additions_installer() {
        printf "\e[1m\e[31m[INFO] Running VBoxLinuxAdditions.run installer...\e[0m\n"
        if [ -f /mnt/VBoxLinuxAdditions.run ]; then
            sh /mnt/VBoxLinuxAdditions.run || {
                printf "\e[1m\e[31m[ERROR] Guest Additions installer failed.\e[0m\n"
                exit 1
            }
        else
            printf "\e[1m\e[31m[ERROR] VBoxLinuxAdditions.run not found. Make sure the ISO is mounted correctly.\e[0m\n"
            exit 1
        fi
}

verify_installation() {
        printf "\e[1m\e[31m[INFO] Verifying Guest Additions installation...\e[0m\n"
        lsmod | grep -i vbox || printf "\e[1m\e[31m[WARNING] Kernel module 'vbox*' not found — may require reboot or indicate an issue.\e[0m\n"
        pgrep VBox || printf "\e[1m\e[31m[WARNING] VBox processes not found — check manually after reboot.\e[0m\n"
}

ask_reboot() {
        read -rp "[QUESTION] Reboot now to apply all changes? [Y/n]: " response
        if [[ "$response" =~ ^[Yy]$ || -z "$response" ]]; then
            printf "\e[1m\e[31m[INFO] Rebooting...\e[0m\n"
            reboot
        else
            printf "\e[1m\e[31m[INFO] Reboot skipped. Some changes may not take effect until next reboot.\e[0m\n"
        fi
}


main() {
        check_root

        USERNAME="$1"

        printf "\e[1m\e[31m[INFO] VirtualBox VM Setup Script\e[0m\n"
        printf "\e[1m\e[31m==============================\e[0m\n"
        printf "\e[1m\e[31m[INFO] This script will:\e[0m\n"
        printf "\e[1m\e[31m1. Add user to sudo group\e[0m\n"
        printf "\e[1m\e[31m2. Update APT sources\e[0m\n"
        printf "\e[1m\e[31m3. Configure time synchronization\e[0m\n"
        printf "\e[1m\e[31m4. Install VirtualBox Guest Additions\e[0m\n"
        printf "\n"

        # Confirm before proceeding
        read -rp "[QUESTION] Continue with setup? [Y/n]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ && ! -z "$confirm" ]]; then
            printf "\e[1m\e[31m[INFO] Setup cancelled.\e[0m\n"
            exit 0
        fi

        printf "\n\e[1m\e[31m[STEP 1] Adding user to sudo group\e[0m\n"
        printf "\e[1m\e[31m----------------------------------------\e[0m\n"
        add_to_sudo "$USERNAME"

        printf "\n\e[1m\e[31m[STEP 2] Updating APT sources\e[0m\n"
        printf "\e[1m\e[31m----------------------------------------\e[0m\n"
        update_sources
        update_system

        # !! Imortant: Configure time synchronization
        printf "\n\e[1m\e[31m[STEP 3] Configuring time synchronization\e[0m\n"
        printf "\e[1m\e[31m----------------------------------------\e[0m\n"
        check_current_time
        install_chrony
        verify_chrony
        manual_sync_ntpdate

        # Install VBox Guest Additions .iso
        printf "\n\e[1m\e[31m[STEP 4] Installing VirtualBox Guest Additions\e[0m\n"
        printf "\e[1m\e[31m----------------------------------------\e[0m\n"
        install_dependencies
        mount_guest_additions_iso
        run_guest_additions_installer
        verify_installation

        printf "\n\e[1m\e[31m[SUCCESS] VirtualBox VM setup completed successfully!\e[0m\n"
        ask_reboot
}

main "$@"

