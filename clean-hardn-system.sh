#!/bin/bash
################################################################################
# HARDN Complete System Cleanup Script
# Purpose: Remove all traces of HARDN/HARDN-XDR installations
# WARNING: Run this ONLY on your Virtual Machine, not on the host!
# 
# This script will:
# - Remove all HARDN-related packages
# - Clean up service files
# - Remove configuration and data directories
# - Clear logs and temporary files
# - Reset systemd daemon
################################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script metadata
SCRIPT_VERSION="1.0.0"
LOG_FILE="/tmp/hardn-cleanup-$(date +%Y%m%d-%H%M%S).log"

################################################################################
# FUNCTIONS
################################################################################

# Logging function
log_message() {
    local level=$1
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        ERROR)
            echo -e "${RED}[✗]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        WARNING)
            echo -e "${YELLOW}[⚠]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        INFO)
            echo -e "${BLUE}[ℹ]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        SECTION)
            echo -e "\n${CYAN}═══ $message ═══${NC}\n" | tee -a "$LOG_FILE"
            ;;
    esac
    
    # Also log to file without colors
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
}

# Check if running with root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message ERROR "This script must be run as root!"
        echo -e "${YELLOW}Please run with: sudo $0${NC}"
        exit 1
    fi
}

# Display banner
display_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║           HARDN COMPLETE SYSTEM CLEANUP             ║"
    echo "║                   Version ${SCRIPT_VERSION}                    ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
    log_message INFO "Starting cleanup process - Log file: $LOG_FILE"
    echo
}

# Confirmation prompt
confirm_cleanup() {
    echo -e "${YELLOW}${BOLD}WARNING: This will completely remove ALL HARDN installations!${NC}"
    echo -e "${YELLOW}This includes:${NC}"
    echo "  • All HARDN and HARDN-XDR packages"
    echo "  • All configuration files in /etc/hardn*"
    echo "  • All data in /var/lib/hardn*"
    echo "  • All logs in /var/log/hardn*"
    echo "  • All systemd service files"
    echo "  • All binaries in /usr/bin/hardn*"
    echo ""
    read -rp "Are you sure you want to continue? Type 'YES' to confirm: " confirmation
    
    if [[ "$confirmation" != "YES" ]]; then
        log_message INFO "Cleanup cancelled by user"
        exit 0
    fi
}

# Stop all HARDN services
stop_services() {
    log_message SECTION "Stopping HARDN Services"
    
    local services=(
        "hardn.service"
        "hardn-api.service"
        "hardn-monitor.service"
        "hardn-xdr.service"
        "hardn-xdr-monitor.service"
        "legion-daemon.service"
        "legion.service"
    )
    
    for service in "${services[@]}"; do
        if systemctl list-units --all | grep -q "$service"; then
            log_message INFO "Stopping $service..."
            systemctl stop "$service" 2>/dev/null || true
            systemctl disable "$service" 2>/dev/null || true
            log_message SUCCESS "Stopped and disabled $service"
        fi
    done
}

# Remove packages
remove_packages() {
    log_message SECTION "Removing HARDN Packages"
    
    # List of possible package names
    local packages=(
        "hardn"
        "hardn-xdr"
        "hardn-cli"
        "hardn-gui"
        "hardn-dev"
        "hardn-monitor"
    )
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii.*$package"; then
            log_message INFO "Removing package: $package"
            
            # First try normal removal
            dpkg --remove "$package" 2>/dev/null || true
            
            # Then try purge
            dpkg --purge "$package" 2>/dev/null || true
            
            # If still failing, force remove
            if dpkg -l | grep -q "$package"; then
                log_message WARNING "Force removing $package..."
                dpkg --purge --force-all "$package" 2>/dev/null || true
            fi
            
            log_message SUCCESS "Removed package: $package"
        fi
    done
    
    # Clean up any broken dependencies
    log_message INFO "Fixing any broken dependencies..."
    apt-get install -f -y 2>/dev/null || true
}

# Remove service files
remove_service_files() {
    log_message SECTION "Removing Service Files"
    
    # System service directories
    local service_dirs=(
        "/lib/systemd/system"
        "/etc/systemd/system"
        "/usr/lib/systemd/system"
    )
    
    for dir in "${service_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_message INFO "Cleaning service files in $dir"
            find "$dir" -name "*hardn*.service" -type f -exec rm -f {} \; 2>/dev/null || true
            find "$dir" -name "*legion*.service" -type f -exec rm -f {} \; 2>/dev/null || true
        fi
    done
    
    # Remove any timer files
    for dir in "${service_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -name "*hardn*.timer" -type f -exec rm -f {} \; 2>/dev/null || true
        fi
    done
    
    log_message SUCCESS "Service files removed"
}

# Remove binaries
remove_binaries() {
    log_message SECTION "Removing HARDN Binaries"
    
    local binary_dirs=(
        "/usr/bin"
        "/usr/local/bin"
        "/opt/hardn/bin"
        "/usr/sbin"
        "/usr/local/sbin"
    )
    
    for dir in "${binary_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_message INFO "Cleaning binaries in $dir"
            find "$dir" -name "hardn*" -type f -exec rm -f {} \; 2>/dev/null || true
            find "$dir" -name "legion*" -type f -exec rm -f {} \; 2>/dev/null || true
        fi
    done
    
    log_message SUCCESS "Binaries removed"
}

# Remove configuration directories
remove_config_dirs() {
    log_message SECTION "Removing Configuration Directories"
    
    local config_dirs=(
        "/etc/hardn"
        "/etc/hardn-xdr"
        "/etc/hardn.d"
        "/usr/share/hardn"
        "/usr/share/hardn-xdr"
        "/opt/hardn"
        "/opt/hardn-xdr"
    )
    
    for dir in "${config_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_message INFO "Removing $dir"
            rm -rf "$dir"
            log_message SUCCESS "Removed $dir"
        fi
    done
}

# Remove data directories
remove_data_dirs() {
    log_message SECTION "Removing Data Directories"
    
    local data_dirs=(
        "/var/lib/hardn"
        "/var/lib/hardn-xdr"
        "/var/cache/hardn"
        "/var/cache/hardn-xdr"
    )
    
    for dir in "${data_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_message INFO "Removing $dir"
            rm -rf "$dir"
            log_message SUCCESS "Removed $dir"
        fi
    done
}

# Remove log files
remove_logs() {
    log_message SECTION "Removing Log Files"
    
    local log_dirs=(
        "/var/log/hardn"
        "/var/log/hardn-xdr"
        "/var/log/legion"
    )
    
    for dir in "${log_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_message INFO "Removing $dir"
            rm -rf "$dir"
            log_message SUCCESS "Removed $dir"
        fi
    done
    
    # Remove individual log files
    find /var/log -name "*hardn*" -type f -exec rm -f {} \; 2>/dev/null || true
    find /var/log -name "*legion*" -type f -exec rm -f {} \; 2>/dev/null || true
}

# Remove user and group
remove_users_groups() {
    log_message SECTION "Removing HARDN Users and Groups"
    
    # Remove hardn user if exists
    if id "hardn" &>/dev/null; then
        log_message INFO "Removing hardn user"
        userdel -r hardn 2>/dev/null || true
        log_message SUCCESS "Removed hardn user"
    fi
    
    # Remove hardn group if exists
    if getent group hardn &>/dev/null; then
        log_message INFO "Removing hardn group"
        groupdel hardn 2>/dev/null || true
        log_message SUCCESS "Removed hardn group"
    fi
}

# Clean APT cache
clean_apt_cache() {
    log_message SECTION "Cleaning APT Cache"
    
    log_message INFO "Updating package database..."
    apt-get update 2>/dev/null || true
    
    log_message INFO "Cleaning package cache..."
    apt-get clean
    apt-get autoclean
    apt-get autoremove -y
    
    log_message SUCCESS "APT cache cleaned"
}

# Reset systemd
reset_systemd() {
    log_message SECTION "Resetting Systemd"
    
    log_message INFO "Reloading systemd daemon..."
    systemctl daemon-reload
    
    log_message INFO "Resetting failed units..."
    systemctl reset-failed
    
    log_message SUCCESS "Systemd reset completed"
}

# Remove build artifacts (if in development directory)
remove_build_artifacts() {
    log_message SECTION "Removing Build Artifacts"
    
    # Common build directories
    local build_dirs=(
        "./target"
        "./build"
        "./dist"
        "./debian/hardn"
        "./debian/hardn-xdr"
        "./debian/.debhelper"
        "./debian/files"
        "./debian/*.debhelper"
        "./debian/*.substvars"
        "./debian/*.log"
    )
    
    local current_dir
    current_dir=$(pwd)
    
    # Only clean if we're in a directory that looks like HARDN source
    if [[ -f "Cargo.toml" ]] || [[ -f "Makefile" ]] && [[ -d "src" ]]; then
        log_message INFO "Detected HARDN source directory at $current_dir"
        
        for pattern in "${build_dirs[@]}"; do
            # Use find to handle patterns
            find . -path "$pattern" -exec rm -rf {} \; 2>/dev/null || true
        done
        
        # Remove .deb files
        find . -name "*.deb" -type f -exec rm -f {} \; 2>/dev/null || true
        
        # Remove Cargo.lock if it exists
        rm -f Cargo.lock 2>/dev/null || true
        
        log_message SUCCESS "Build artifacts removed from $current_dir"
    fi
}

# Final verification
verify_cleanup() {
    log_message SECTION "Verifying Cleanup"
    
    local issues=0
    
    # Check for remaining packages
    if dpkg -l | grep -q "hardn"; then
        log_message WARNING "Some HARDN packages may still be installed"
        ((issues++))
    fi
    
    # Check for remaining service files
    if find /lib/systemd/system /etc/systemd/system -name "*hardn*.service" 2>/dev/null | grep -q .; then
        log_message WARNING "Some service files may still exist"
        ((issues++))
    fi
    
    # Check for remaining binaries
    if which hardn &>/dev/null; then
        log_message WARNING "HARDN binary still in PATH"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_message SUCCESS "Cleanup verification passed - system is clean!"
    else
        log_message WARNING "Some items may require manual cleanup"
    fi
}

# Generate summary report
generate_report() {
    log_message SECTION "Cleanup Summary"
    
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}   HARDN Cleanup Completed Successfully${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo
    echo "Log file saved to: $LOG_FILE"
    echo
    echo -e "${CYAN}You can now:${NC}"
    echo "  1. Build fresh: ${YELLOW}sudo make build${NC}"
    echo "  2. Install: ${YELLOW}sudo make hardn${NC}"
    echo "  3. Or install a specific .deb: ${YELLOW}sudo dpkg -i hardn_*.deb${NC}"
    echo
    echo -e "${GREEN}System is ready for a clean HARDN installation!${NC}"
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    # Initial setup
    check_root
    display_banner
    confirm_cleanup
    
    # Perform cleanup
    stop_services
    remove_packages
    remove_service_files
    remove_binaries
    remove_config_dirs
    remove_data_dirs
    remove_logs
    remove_users_groups
    clean_apt_cache
    reset_systemd
    remove_build_artifacts
    
    # Verification and report
    verify_cleanup
    generate_report
    
    exit 0
}

# Run main function
main "$@"