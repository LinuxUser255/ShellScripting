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


# Color definitions
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
RESET="\e[0m"

# Logging functions using shorter function declaration
log_info(){
        printf "${BLUE}[INFO]${RESET} %s\n" "$1"
}

log_success(){
        printf "${GREEN}[SUCCESS]${RESET} %s\n" "$1"
}

log_warning(){
        printf "${YELLOW}[WARNING]${RESET} %s\n" "$1"
}

log_error(){
        printf "${RED}[ERROR]${RESET} %s\n" "$1"
}

harden_ssh_config(){
        log_info "Hardening SSH configuration..."

        # Define paths
        local custom_config="sshd_config"
        local system_config="/etc/ssh/sshd_config"
        local backup_config
        backup_config="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"

        # Check if running as root using shorter if syntax
        [[ $EUID -ne 0 ]] && {
                log_error "This function must be run as root"
                return 1
        }

        # Check if custom config exists
        [[ ! -f "${custom_config}" ]] && {
                log_error "Custom SSH config not found at ${custom_config}"
                return 1
        }

        # Create backup
        log_info "Creating backup of current SSH configuration..."
        if cp "${system_config}" "${backup_config}"; then
                log_success "Original SSH config backed up to ${backup_config}"
        else
                log_error "Failed to create backup of SSH config"
                return 1
        fi

        # Copy custom config
        log_info "Installing custom SSH configuration..."
        if cp "${custom_config}" "${system_config}"; then
                : # No-op, continue execution
        else
                log_error "Failed to install custom SSH config"
                return 1
        fi

        # Set proper permissions
        log_info "Setting proper file permissions..."
        chmod 644 "${system_config}"
        chown root:root "${system_config}"

        # Validate config before restarting
        log_info "Validating SSH configuration..."
        if ! sshd -t; then
                log_error "Invalid SSH configuration detected. Reverting changes..."
                cp "${backup_config}" "${system_config}"
                return 1
        fi

        # Restart SSH service
        log_info "Restarting SSH service..."
        if systemctl restart sshd; then
                log_success "SSH configuration hardened successfully."
        else
                log_error "Failed to restart SSH service. Reverting changes..."
                cp "${backup_config}" "${system_config}"
                systemctl restart sshd
                return 1
        fi

        return 0
}

# Execute the function if script is run directly (not sourced)
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
        # Check if running as root
        [[ $EUID -ne 0 ]] && {
                printf "%s[ERROR]%s This script must be run as root\n" "${RED}" "${RESET}"
                echo "Try: sudo $0"
                exit 1
        }

        harden_ssh_config
}
