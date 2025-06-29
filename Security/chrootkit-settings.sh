#!/usr/bin/env bash

#######################################
# Chkrootkit Configuration
# This module handles the hardening of GRUB Chkrootkit settings
# It is part of the HARDN-XDR security hardening framework
# https://github.com/LinuxUser255/HARDN-XDR/tree/main/src/setup/modules/chkrootkit.sh
#######################################

# Save original environment variables for proper restoration
IFS_OLD="$IFS"
LC_ALL_OLD="$LC_ALL"
LANG_OLD="$LANG"

# Set safe environment for script execution
IFS=$' \t\n'
LC_ALL=C
LANG=C

# Error handling function
handle_error() {
    local exit_code=$1
    local error_message=$2

    HARDN_STATUS "error" "$error_message"

    # Restore environment variables
    IFS="$IFS_OLD"
    LC_ALL="$LC_ALL_OLD"
    LANG="$LANG_OLD"

    return $exit_code
}

# Cleanup function to ensure environment is restored
cleanup_environment() {
    # Restore environment variables
    IFS="$IFS_OLD"
    LC_ALL="$LC_ALL_OLD"
    LANG="$LANG_OLD"
}

HARDN_STATUS "info" "Setting up Chkrootkit..."

install_chkrootkit_from_source() {

        # Trying the FTP, cause the https source is not available
        local download_url="ftp://ftp.chkrootkit.org/pub/seg/pac/chkrootkit.tar.gz"

        ##local download_url="https://www.chkrootkit.org/dl/chkrootkit.tar.gz"
        local download_dir="/tmp/chkrootkit_install"
        local tar_file="$download_dir/chkrootkit.tar.gz"

        mkdir -p "$download_dir"
        cd "$download_dir" || {
            handle_error 1 "Error: Cannot change directory to $download_dir."
            return 1
        }

        HARDN_STATUS "info" "Downloading $download_url..."
        if ! wget -q "$download_url" -O "$tar_file"; then
            handle_error 1 "Error: Failed to download $download_url."
            cleanup_install_files
            return 1
        }
        HARDN_STATUS "pass" "Download successful."

        HARDN_STATUS "info" "Extracting..."
        if ! tar -xzf "$tar_file" -C "$download_dir"; then
            handle_error 1 "Error: Failed to extract $tar_file."
            cleanup_install_files
            return 1
        }
        HARDN_STATUS "pass" "Extraction successful."

        local extracted_dir
        extracted_dir=$(tar -tf "$tar_file" | head -1 | cut -f1 -d/)

        if ! [[ -d "$download_dir/$extracted_dir" ]]; then
            handle_error 1 "Error: Extracted directory not found."
            cleanup_install_files
            return 1
        }

        cd "$download_dir/$extracted_dir" || {
            handle_error 1 "Error: Cannot change directory to extracted folder."
            cleanup_install_files
            return 1
        }

        HARDN_STATUS "info" "Running chkrootkit installer..."
        if ! [[ -f "chkrootkit" ]]; then
            handle_error 1 "Error: chkrootkit script not found in extracted directory."
            cleanup_install_files
            return 1
        }

        cp chkrootkit /usr/local/sbin/
        chmod +x /usr/local/sbin/chkrootkit

        if [[ -f "chkrootkit.8" ]]; then
            cp chkrootkit.8 /usr/local/share/man/man8/
            mandb >/dev/null 2>&1 || true
        fi

        HARDN_STATUS "pass" "chkrootkit installed to /usr/local/sbin."
        cleanup_install_files
        return 0
}


cleanup_install_files() {
        cd /tmp || true
        rm -rf "/tmp/chkrootkit_install"
}


configure_chkrootkit_cron() {
        if ! command -v chkrootkit >/dev/null 2>&1; then
            handle_error 1 "chkrootkit command not found, skipping cron configuration."
            return 1
        }

        if ! grep -q "/usr/local/sbin/chkrootkit" /etc/crontab; then
            echo "0 3 * * * root /usr/local/sbin/chkrootkit 2>&1 | logger -t chkrootkit" >> /etc/crontab
            HARDN_STATUS "pass" "chkrootkit daily check added to crontab."
        else
            HARDN_STATUS "info" "chkrootkit already in crontab."
        fi

        return 0
}

# Main function
setup_chkrootkit() {
        HARDN_STATUS "info" "Configuring chkrootkit..."

        if ! command -v chkrootkit >/dev/null 2>&1; then
            HARDN_STATUS "info" "chkrootkit package not found. Attempting to download and install from chkrootkit.org..."
            install_chkrootkit_from_source
        else
            HARDN_STATUS "pass" "chkrootkit package is already installed."
        fi

        configure_chkrootkit_cron
}

# Calling main
setup_chkrootkit

# Ensure environment is restored before exiting
trap cleanup_environment EXIT


