#!/usr/bin/env bash

# This function is to be implemented into hardn-main.sh

# ABOUT the function
#  Hardens SSH configuration.
#  Creates a backup, apples the custom sshd_config file, validates the config, then restarts SSH.
#  ADDITIONAl:
# Need to  ensure that the SSH service remains functional even if there are issues with the configuration file,
# Such as, in the event of a broken SSH config, this approach can avoid an SSH lockout.

# Steps:
# 1. Proper error handling
# 2. Configuration validation before applying changes
# 3. Automatic rollback if something goes wrong
# 4. Clear logging of what's happening

# check if script is being run from the correct directory
check_user(){
if [ "$(id -u)" -ne 0 ]; then
    printf "\e[1;31mError: This script must be run as root\e[0m\n"
    exit 1
fi
}

# Function to ensure SSH prerequisites are met
ensure_ssh_prerequisites() {
    # Check if sshd directory exists, create if not
    if [ ! -d "/run/sshd" ]; then
        printf "\e[1;31mCreating missing privilege separation directory: /run/sshd\e[0m\n"
        mkdir -p /run/sshd
        chmod 0755 /run/sshd
    fi

    # Check if OpenSSH server is installed
    if ! command -v sshd >/dev/null 2>&1; then
        printf "\e[1;31mOpenSSH server is not installed. Installing...\e[0m\n"
        apt-get update && apt-get install -y openssh-server
        if [ $? -ne 0 ]; then
            printf "\e[1;31mFailed to install OpenSSH server. Aborting.\e[0m\n"
            return 1
        fi
    fi

    return 0
}

harden_ssh_config() {
        printf "\e[1;31mHardening SSH configuration...\e[0m\n"

        # Ensure SSH prerequisites are met
        ensure_ssh_prerequisites
        if [ $? -ne 0 ]; then
            printf "\e[1;31mFailed to meet SSH prerequisites. Aborting.\e[0m\n"
            return 1
        fi

        # Define paths
        local custom_config="${SCRIPT_DIR}/../../sshd_config"
        local system_config="/etc/ssh/sshd_config"
        local backup_config="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"

        # Check if custom config exists
        if [ ! -f "$custom_config" ]; then
            printf "\e[1;31mError: Custom SSH config not found at %s\e[0m\n" "$custom_config"
            return 1
        fi

        # Create backup
        if ! cp "$system_config" "$backup_config"; then
            printf "\e[1;31mError: Failed to create backup of SSH config\e[0m\n"
            return 1
        fi
        printf "\e[1;31mOriginal SSH config backed up to %s\e[0m\n" "$backup_config"

        # Copy custom config
        if ! cp "$custom_config" "$system_config"; then
            printf "\e[1;31mError: Failed to install custom SSH config\e[0m\n"
            return 1
        fi

        # Set proper permissions
        chmod 644 "$system_config"
        chown root:root "$system_config"

        # Validate config before restarting
        if ! sshd -t; then
            printf "\e[1;31mError: Invalid SSH configuration detected. Reverting changes...\e[0m\n"
            cp "$backup_config" "$system_config"
            return 1
        fi

        # Restart SSH service
        if systemctl restart sshd; then
            printf "\e[1;31mSSH configuration hardened successfully.\e[0m\n"
        else
            printf "\e[1;31mError: Failed to restart SSH service. Reverting changes...\e[0m\n"
            cp "$backup_config" "$system_config"
            systemctl restart sshd
            return 1
        fi

  return 0
}

# Define script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call the functions
check_user
harden_ssh_config
