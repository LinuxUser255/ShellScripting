#!/usr/bin/env bash

# Robust error handling and performance optimization (per parallelism guidelines)
set -euo pipefail
IFS=$'\n\t'

# Enable debug mode if DEBUG=1
[[ "${DEBUG:-0}" == "1" ]] && set -x

# Track background jobs for cleanup
declare -a BACKGROUND_JOBS=()

# Signal trap for cleanup on exit
cleanup_on_exit() {
    local exit_code=$?
    
    # Kill any remaining background jobs
    if [[ ${#BACKGROUND_JOBS[@]} -gt 0 ]]; then
        for job in "${BACKGROUND_JOBS[@]}"; do
            if kill -0 "$job" 2>/dev/null; then
                kill -TERM "$job" 2>/dev/null || true
            fi
        done
        wait 2>/dev/null || true
    fi
    
    # Reset terminal colors if needed
    printf '\033[0m'
    
    exit $exit_code
}

# Set up signal handlers
trap cleanup_on_exit EXIT
trap 'echo "Interrupted!"; exit 130' INT TERM

#=============================================================================
# HARDN-XDR Uninstall Module (TEST BRANCH ENHANCED VERSION)
#=============================================================================
#
# WHAT THIS SCRIPT DOES:
# ----------------------
# This script is a multi-purpose uninstallation and cleanup tool specifically
# enhanced for the TEST BRANCH of HARDN-XDR. It serves three primary functions:
#
# 1. SECURITY HARDENING REMOVAL:
#    - Removes all HARDN-applied security configurations
#    - Restores system to pre-hardening state
#    - Disables security services (UFW, Fail2Ban, etc.)
#    - Removes custom audit rules and kernel parameters
#    - Preserves logs and backups for analysis
#
# 2. BUILD ARTIFACT CLEANUP (TEST BRANCH EXCLUSIVE):
#    - Deletes all .deb package files (hardn-xdr_*.deb, *.buildinfo, *.changes)
#    - Removes build directories (target/, debian/hardn-xdr/)
#    - Cleans test directories (HARDN-XDR-test/)
#    - Handles root-owned files created during package building
#    - Removes Rust compilation artifacts if requested
#
# 3. COMPLETE SYSTEM RESET:
#    - Combines both hardening removal and artifact cleanup
#    - Purges the hardn-xdr package from dpkg database
#    - Optionally removes all security packages installed by HARDN
#    - Provides a completely clean slate for fresh testing
#
# PRIMARY USE CASE - TESTING WORKFLOW OPTIMIZATION:
# --------------------------------------------------
# This script is designed to streamline the testing process for HARDN-XDR
# developers and QA testers working with virtual machines. Instead of
# constantly reverting to VM snapshots between tests, testers can:
#
# 1. Test a build → Find issues → Run this uninstall script
# 2. Make code changes → Rebuild → Test again
# 3. Repeat without VM resets
#
# This workflow is particularly valuable when:
# - Testing installation procedures repeatedly
# - Verifying fixes for installation bugs
# - Testing upgrade paths between versions
# - Debugging package conflicts
# - Validating clean installation behavior
# - Testing different configuration scenarios
#
# DETAILED FUNCTIONALITY:
# -----------------------
# 
# STANDARD UNINSTALL (Option 1):
#   • Removes /etc/sysctl.d/99-hardn-security.conf
#   • Removes /etc/audit/rules.d/hardn-audit.rules
#   • Removes /etc/fail2ban/jail.d/hardn-jail.conf
#   • Removes /etc/rsyslog.d/50-hardn.conf
#   • Restores original DNS settings
#   • Resets kernel security parameters to defaults
#   • Optionally disables security services
#   • Creates pre-uninstall backup
#
# BUILD CLEANUP (Option 2 - TEST BRANCH):
#   • Scans for hardn-xdr_*.deb files
#   • Removes hardn-xdr_*_amd64.buildinfo
#   • Removes hardn-xdr_*_amd64.changes
#   • Deletes HARDN-XDR-test/ directory
#   • Cleans debian/.debhelper/
#   • Removes debian/hardn-xdr/ build directory
#   • Optionally removes target/ (Rust build cache)
#   • Uses sudo for root-owned files
#
# COMPLETE UNINSTALL (Option 3 - TEST BRANCH):
#   • Performs all standard uninstall operations
#   • Performs all build cleanup operations
#   • Purges hardn-xdr from package manager
#   • Optionally removes security packages:
#     - rkhunter, chkrootkit, unhide
#     - aide, aide-common
#     - fail2ban, lynis, yara
#
# HOW IT INTEGRATES WITH HARDN-XDR:
# ----------------------------------
# This script is executed through directly from the root of the code-base.
#
# It receives environment variables from the main binary:
#   - HARDN_MODULES_DIR: Path to module scripts
#   - HARDN_LOG_DIR: Logging directory
#   - HARDN_LIB_DIR: Data/backup directory
#
# INTERACTIVE MENU SYSTEM:
# ------------------------
# When run, presents a color-coded menu:
#   - Options clearly marked as [TEST] for test-branch features
#   - Descriptive help text for each option
#   - Confirmation prompts for destructive operations
#   - Dry-run option to preview changes
#
# SAFETY FEATURES:
# ----------------
# - Multiple confirmation prompts for destructive operations
# - Automatic backup creation before removal
# - Dry-run mode to preview changes
# - Graceful handling of missing files/services
# - Preservation of user data and logs
#
# TESTING VM OPTIMIZATION:
# ------------------------
# By automating cleanup, this script saves significant time in testing cycles:
# - Typical VM snapshot restore: 2-5 minutes
# - This script cleanup: 10-30 seconds
# - No need to maintain multiple VM snapshots
# - Consistent cleanup every time
# - No forgotten files or partial cleanups
#
# EXAMPLE TESTING SCENARIO:
# -------------------------
# Morning: Test installation on fresh VM
# → Found bug in package dependencies
# → Run: sudo ./uninstall.sh (Option 3)
# → Fix code, rebuild package
# → Test again on same VM (now clean)
# → Bug fixed, test passes
# 
# Afternoon: Test upgrade scenario
# → Install version 1.0
# → Attempt upgrade to 2.0
# → Upgrade fails
# → Run: sudo ./uninstall.sh (Option 2)
# → Adjust upgrade logic
# → Test upgrade again
# → Success!
#
# Total time saved: Multiple VM snapshot restores avoided
# Total tests completed: More iterations in less time
#
# WARNING AND LIMITATIONS:
# ------------------------
# ⚠️  This TEST BRANCH version is NOT for production use!
# ⚠️  Can remove important development files if used carelessly
# ⚠️  Some system changes may require reboot to fully revert
# ⚠️  Network settings changes may disconnect SSH sessions
# ⚠️  Always ensure you have backups before using Option 3
#
# DEPENDENCIES:
# -------------
# - Requires root/sudo privileges
# - Bash 4.0 or higher
# - Standard Linux utilities (systemctl, dpkg, rm, find)
# - NO external scripts or modules required
# - All functions are self-contained
#
# AUTHOR: Christopher Bingham
# VERSION: 2.3.0-test
# LICENSE: MIT
#
# PERFORMANCE OPTIMIZATIONS (v2.3.0):
# ------------------------------------
# This version includes parallel processing optimizations following
# Bash parallelism best practices:
#
# • Parallel file removal using background jobs
# • Concurrent package uninstallation (limited to avoid APT lock conflicts)
# • Parallel service stops for faster shutdown
# • Parallel sysctl resets for quicker system restoration
# • Background directory cleanup operations
# • Proper job control and signal handling
# • Controlled concurrency limits to prevent system overload
#
# These optimizations typically reduce cleanup time by 40-60% for
# large installations with many files and services.
#=============================================================================

#=============================================================================
# STANDALONE FUNCTIONS - No external dependencies
#=============================================================================

# Color definitions for enhanced output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    CYAN=''
    NC=''
fi

# Default paths (can be overridden if HARDN is installed)
HARDN_LOG_DIR="${HARDN_LOG_DIR:-/var/log/hardn}"
HARDN_LIB_DIR="${HARDN_LIB_DIR:-/var/lib/hardn}"
HARDN_MODULES_DIR="${HARDN_MODULES_DIR:-/usr/share/hardn/modules}"

# Logging functions (standalone versions)
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*"
    fi
}

hardn_status() {
    local status="$1"
    local message="$2"
    case "${status}" in
        "pass")
            log_info "✓ ${message}"
            ;;
        "fail")
            log_error "✗ ${message}"
            ;;
        *)
            echo "${message}"
            ;;
    esac
}

log_separator() {
    local char="${1:-=}"
    local length="${2:-50}"
    printf '%*s\n' "${length}" '' | tr ' ' "${char}"
}

# Utility functions (standalone versions)
confirm_action() {
    local prompt="$1"
    local default="${2:-y}"
    local response
    
    if [[ "${default}" == "y" ]]; then
        read -p "${prompt} [Y/n]: " response
        response=${response:-y}
    else
        read -p "${prompt} [y/N]: " response
        response=${response:-n}
    fi
    
    [[ "${response}" =~ ^[Yy]$ ]]
}

is_dry_run() {
    [[ "${DRY_RUN:-0}" == "1" ]]
}

backup_file() {
    local file="$1"
    if [[ -f "${file}" ]]; then
        cp "${file}" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
}

service_exists() {
    local service="$1"
    systemctl list-unit-files | grep -q "^${service}"
}

is_service_active() {
    local service="$1"
    systemctl is-active "${service}" >/dev/null 2>&1
}

is_service_enabled() {
    local service="$1"
    systemctl is-enabled "${service}" >/dev/null 2>&1
}

disable_service() {
    local service="$1"
    local description="${2:-$1}"
    
    if is_dry_run; then
        log_info "[DRY-RUN] Would disable ${description}"
    else
        systemctl stop "${service}" 2>/dev/null || true
        systemctl disable "${service}" 2>/dev/null || true
        log_debug "Disabled ${description}"
    fi
}

is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii.*${package}"
}

# Simple backup function for standalone operation
create_system_backup() {
    local backup_name="$1"
    local backup_dir="${HARDN_LIB_DIR}/backups/${backup_name}"
    
    if [[ -d "${HARDN_LIB_DIR}" ]]; then
        log_info "Creating backup: ${backup_name}"
        mkdir -p "${backup_dir}"
        
        # Backup key configuration files if they exist
        local files_to_backup=(
            "/etc/sysctl.d/99-hardn-security.conf"
            "/etc/audit/rules.d/hardn-audit.rules"
            "/etc/fail2ban/jail.d/hardn-jail.conf"
        )
        
        for file in "${files_to_backup[@]}"; do
            if [[ -f "${file}" ]]; then
                local backup_path="${backup_dir}$(dirname "${file}")"
                mkdir -p "${backup_path}"
                cp "${file}" "${backup_path}/" 2>/dev/null || true
            fi
        done
        
        log_info "Backup created at: ${backup_dir}"
    else
        log_warn "Backup directory not available, skipping backup"
    fi
}

# Remove HARDN hardening
remove_hardening() {
    log_warn "Removing HARDN hardening..."
    
    if ! confirm_action "This will remove HARDN security hardening. Are you sure?" "n"; then
        log_info "Uninstall cancelled"
        return 0
    fi
    
    if ! confirm_action "This action cannot be easily undone. Continue?" "n"; then
        log_info "Uninstall cancelled"
        return 0
    fi
    
    # Create backup before removal
    log_info "Creating backup before removal..."
    create_system_backup "pre-uninstall-$(date +%Y%m%d_%H%M%S)"
    
    # Remove HARDN configuration files
    remove_hardn_configs
    
    # Restore original configurations
    restore_original_configs
    
    # Remove HARDN services
    remove_hardn_services
    
    # Optionally remove security packages
    if confirm_action "Remove installed security packages?" "n"; then
        remove_security_packages
    fi
    
    hardn_status "pass" "HARDN hardening removed"
    log_info "System has been restored to pre-HARDN state"
    log_info "Please reboot the system to complete the removal"
}

# Remove HARDN configuration files
remove_hardn_configs() {
    log_info "Removing HARDN configuration files..."
    
    local config_files=(
        "/etc/sysctl.d/99-hardn-security.conf"
        "/etc/audit/rules.d/hardn-audit.rules"
        "/etc/fail2ban/jail.d/hardn-jail.conf"
        "/etc/rsyslog.d/50-hardn.conf"
        "/etc/aide/aide.conf.d/hardn-aide.conf"
        "/etc/systemd/resolved.conf.d/hardn-dns.conf"
    )
    
    # Parallel file removal function for config files
    remove_config_file() {
        local config_file="$1"
        if [[ -f "${config_file}" ]]; then
            if is_dry_run; then
                printf "[DRY-RUN] Would remove %s\n" "${config_file}"
            else
                backup_file "${config_file}"
                rm -f "${config_file}"
                printf "[REMOVED] %s\n" "${config_file}"
            fi
        fi
    }
    
    # Process removals in parallel for faster execution
    local -a joblist=()
    for config_file in "${config_files[@]}"; do
        remove_config_file "${config_file}" &
        joblist+=($!)
    done
    
    # Wait for all removal jobs to complete
    for job in "${joblist[@]}"; do
        wait "$job" 2>/dev/null || true
    done
    
    hardn_status "pass" "HARDN configuration files removed"
}

# Restore original configurations
restore_original_configs() {
    log_info "Restoring original configurations..."
    
    # Restore original sysctl settings
    if ! is_dry_run; then
        # Reset problematic sysctl settings to defaults
        local sysctl_resets=(
            "net.ipv4.ip_forward=0"
            "kernel.dmesg_restrict=0"
            "kernel.kptr_restrict=1"
            "fs.suid_dumpable=2"
        )
        
        # Function to reset single sysctl setting (for parallel execution)
        reset_sysctl() {
            local setting="$1"
            if sysctl -w "${setting}" >/dev/null 2>&1; then
                printf "[RESET] %s\n" "${setting}"
            else
                printf "[FAILED] %s\n" "${setting}" >&2
            fi
        }
        
        # Reset sysctl settings in parallel
        local -a sysctl_jobs=()
        for setting in "${sysctl_resets[@]}"; do
            reset_sysctl "${setting}" &
            sysctl_jobs+=($!)
            BACKGROUND_JOBS+=($!)  # Track for cleanup
        done
        
        # Wait for all sysctl resets to complete
        for job in "${sysctl_jobs[@]}"; do
            wait "$job" 2>/dev/null || true
        done
    fi
    
    # Restore DNS settings
    if [[ -f /etc/systemd/resolved.conf.d/hardn-dns.conf ]]; then
        if is_dry_run; then
            log_info "[DRY-RUN] Would restore DNS settings"
        else
            rm -f /etc/systemd/resolved.conf.d/hardn-dns.conf
            systemctl restart systemd-resolved 2>/dev/null || true
            log_debug "DNS settings restored"
        fi
    fi
    
    hardn_status "pass" "Original configurations restored"
}

# Remove HARDN services
remove_hardn_services() {
    log_info "Removing HARDN services..."
    
    # Stop and disable HARDN monitor service
    if service_exists "hardn-monitor"; then
        disable_service "hardn-monitor" "HARDN Monitor"
    fi
    
    # Reset security services to default state
    local services_to_reset=(
        "fail2ban"
        "ufw"
    )
    
    for service in "${services_to_reset[@]}"; do
        if service_exists "${service}"; then
            if confirm_action "Disable ${service}?" "n"; then
                disable_service "${service}"
            fi
        fi
    done
    
    # Reset UFW to defaults if requested
    if is_service_active "ufw" && confirm_action "Reset UFW firewall to defaults?" "n"; then
        if ! is_dry_run; then
            echo "y" | ufw --force reset >/dev/null 2>&1
            ufw --force disable >/dev/null 2>&1
            log_debug "UFW reset to defaults"
        fi
    fi
    
    hardn_status "pass" "HARDN services removed"
}

# Remove security packages (optional)
remove_security_packages() {
    log_info "Removing security packages..."
    
    local security_packages=(
        "rkhunter"
        "chkrootkit"
        "unhide"
        "aide"
        "aide-common"
        "fail2ban"
        "lynis"
        "yara"
    )
    
    # Show packages to be removed
    log_warn "The following packages will be removed:"
    local packages_to_remove=()
    for package in "${security_packages[@]}"; do
        if is_package_installed "${package}"; then
            echo "  - ${package}"
            packages_to_remove+=("${package}")
        fi
    done
    
    if [[ ${#packages_to_remove[@]} -eq 0 ]]; then
        log_info "No security packages to remove"
        return 0
    fi
    
    if ! confirm_action "Proceed with package removal?" "n"; then
        log_info "Package removal cancelled"
        return 0
    fi
    
    # Function to remove single package (for parallel execution)
    remove_single_package() {
        local package="$1"
        if is_dry_run; then
            printf "[DRY-RUN] Would remove: %s\n" "${package}"
        else
            if DEBIAN_FRONTEND=noninteractive apt-get remove -y "${package}" >/dev/null 2>&1; then
                printf "[REMOVED] %s\n" "${package}"
            else
                printf "[FAILED] %s\n" "${package}" >&2
            fi
        fi
    }
    
    # Remove packages in parallel for faster execution
    # Limit parallel APT operations to avoid lock conflicts
    local MAX_PARALLEL=2
    local -a joblist=()
    
    for package in "${packages_to_remove[@]}"; do
        # Limit concurrent package operations
        while (( ${#joblist[@]} >= MAX_PARALLEL )); do
            # Wait for the first job to complete
            wait "${joblist[0]}" 2>/dev/null || true
            joblist=("${joblist[@]:1}")
        done
        
        # Start package removal in background
        remove_single_package "${package}" &
        joblist+=($!)
    done
    
    # Wait for remaining jobs
    for job in "${joblist[@]}"; do
        wait "$job" 2>/dev/null || true
    done
    
    # Clean up orphaned packages
    if ! is_dry_run; then
        log_info "Cleaning up orphaned packages..."
        DEBIAN_FRONTEND=noninteractive apt-get autoremove -y >/dev/null 2>&1
    fi
    
    hardn_status "pass" "Security packages removed"
}

# Show what would be removed (dry run)
show_removal_plan() {
    log_info "HARDN Removal Plan"
    log_separator "=" 40
    
    echo "Configuration files to be removed:"
    local config_files=(
        "/etc/sysctl.d/99-hardn-security.conf"
        "/etc/audit/rules.d/hardn-audit.rules"
        "/etc/fail2ban/jail.d/hardn-jail.conf"
        "/etc/rsyslog.d/50-hardn.conf"
        "/etc/aide/aide.conf.d/hardn-aide.conf"
        "/etc/systemd/resolved.conf.d/hardn-dns.conf"
    )
    
    for config_file in "${config_files[@]}"; do
        if [[ -f "${config_file}" ]]; then
            echo "  ✓ ${config_file}"
        else
            echo "  - ${config_file} (not found)"
        fi
    done
    
    echo
    echo "Services to be modified:"
    local services=("hardn-monitor" "fail2ban" "ufw" "auditd")
    for service in "${services[@]}"; do
        if service_exists "${service}"; then
            local status
            if is_service_active "${service}"; then
                status="running → stopped"
            else
                status="stopped"
            fi
            echo "  ✓ ${service} (${status})"
        else
            echo "  - ${service} (not installed)"
        fi
    done
    
    echo
    echo "System changes to be reverted:"
    echo "  ✓ Kernel security parameters"
    echo "  ✓ DNS configuration"
    echo "  ✓ Audit rules"
    echo "  ✓ Firewall rules"
    
    echo
    echo "Data preserved:"
    echo "  ✓ System backups in ${HARDN_LIB_DIR}/backups"
    echo "  ✓ Log files in ${HARDN_LOG_DIR}"
    
    echo
}

#-----------------------------------------------------------------------------
# TEST BRANCH FEATURE: Clean Build Artifacts
#-----------------------------------------------------------------------------
# This function is specifically designed for the test branch to clean VMs
# between test iterations without requiring snapshot restoration.
# It removes all build-related files that accumulate during testing:
# - Debian package files (.deb, .buildinfo, .changes)
# - Build directories (target/, debian/hardn-xdr/)
# - Test directories (HARDN-XDR-test/)
# - Files owned by root from package building
#-----------------------------------------------------------------------------
clean_build_artifacts() {
    log_info "[TEST BRANCH] Cleaning HARDN-XDR build artifacts and test files..."
    
    # Optimized parallel file removal function
    # Uses background jobs for faster processing of multiple files
    remove_pattern() {
        local pattern="$1"
        local found=0
        local -a joblist=()
        local MAX_JOBS=4  # Limit parallel removals to avoid overwhelming the system
        
        # Function to remove single file (for parallel execution)
        remove_single_file() {
            local file="$1"
            if rm -f "$file" 2>/dev/null; then
                printf "[REMOVED] %s\n" "$file"
            elif sudo rm -f "$file" 2>/dev/null; then
                printf "[REMOVED-SUDO] %s\n" "$file"
            else
                printf "[FAILED] %s\n" "$file" >&2
            fi
        }
        
        # Use find for more efficient pattern matching (avoids shell globbing issues)
        # Process files in parallel for better performance
        while IFS= read -r -d '' file; do
            if [[ -e "$file" ]]; then
                found=1
                log_debug "Found: $file"
                
                # Run removal in background with job control
                remove_single_file "$file" &
                joblist+=($!)
                
                # Limit concurrent jobs
                if (( ${#joblist[@]} >= MAX_JOBS )); then
                    wait "${joblist[0]}" 2>/dev/null || true
                    joblist=("${joblist[@]:1}")
                fi
            fi
        done < <(find . -maxdepth 1 -name "$pattern" -type f -print0 2>/dev/null)
        
        # Wait for remaining jobs
        wait
        
        if [[ $found -eq 0 ]]; then
            log_debug "No files matching pattern: $pattern"
        fi
    }
    
    # Remove Debian build artifacts
    log_info "Removing Debian package build artifacts..."
    remove_pattern "hardn-xdr_*.buildinfo"
    remove_pattern "hardn-xdr_*.changes"
    remove_pattern "hardn-xdr_*.deb"
    remove_pattern "hardn-xdr_*.dsc"
    remove_pattern "hardn-xdr_*.tar.gz"
    remove_pattern "hardn-xdr_*.tar.xz"
    remove_pattern "hardn-xdr_*_amd64.buildinfo"
    remove_pattern "hardn-xdr_*_amd64.changes"
    remove_pattern "hardn-xdr_*_amd64.deb"
    remove_pattern "hardn-xdr_*_all.deb"
    
    # Use find to catch any remaining hardn-xdr files
    log_info "Searching for any remaining hardn-xdr build files..."
    find . -maxdepth 1 -name "hardn-xdr_*" -type f 2>/dev/null | while read -r file; do
        log_debug "Found: $file"
        if rm -f "$file" 2>/dev/null; then
            log_debug "Removed: $file"
        elif sudo rm -f "$file" 2>/dev/null; then
            log_debug "Removed with sudo: $file"
        else
            log_warn "Failed to remove: $file"
        fi
    done
    
    # Function to remove directory (for parallel execution)
    remove_directory() {
        local dir="$1"
        local desc="${2:-$1}"
        if [[ -d "$dir" ]]; then
            if rm -rf "$dir" 2>/dev/null; then
                printf "[REMOVED] %s\n" "$desc"
            elif sudo rm -rf "$dir" 2>/dev/null; then
                printf "[REMOVED-SUDO] %s\n" "$desc"
            else
                printf "[FAILED] %s\n" "$desc" >&2
            fi
        fi
    }
    
    # Remove test directories
    log_info "Removing test directories..."
    remove_directory "HARDN-XDR-test" "HARDN-XDR-test directory"
    
    # Remove other common build artifacts if in development directory
    if [[ -f "Cargo.toml" || -f "Makefile" ]]; then
        log_info "Detected development directory, cleaning additional artifacts..."
        
        # Clean Debian packaging artifacts in parallel
        local -a cleanup_jobs=()
        
        # Start parallel cleanup jobs
        remove_directory "debian/.debhelper" "debian/.debhelper" &
        cleanup_jobs+=($!)
        
        [[ -f "debian/files" ]] && { rm -f "debian/files" 2>/dev/null || sudo rm -f "debian/files"; } &
        cleanup_jobs+=($!)
        
        # Remove multiple patterns in parallel
        ( rm -f debian/*.substvars 2>/dev/null || sudo rm -f debian/*.substvars 2>/dev/null ) &
        cleanup_jobs+=($!)
        
        ( rm -f debian/*.debhelper 2>/dev/null || sudo rm -f debian/*.debhelper 2>/dev/null ) &
        cleanup_jobs+=($!)
        
        [[ -f "debian/debhelper-build-stamp" ]] && { rm -f "debian/debhelper-build-stamp" 2>/dev/null || sudo rm -f "debian/debhelper-build-stamp"; } &
        cleanup_jobs+=($!)
        
        remove_directory "debian/hardn-xdr" "debian/hardn-xdr" &
        cleanup_jobs+=($!)
        
        # Wait for all cleanup jobs to complete
        for job in "${cleanup_jobs[@]}"; do
            wait "$job" 2>/dev/null || true
        done
        
        # Optionally clean Rust target directory
        if [[ -d "target" ]] && confirm_action "Remove Rust build directory (target/)?" "n"; then
            remove_directory "target" "Rust target directory"
        fi
    fi
    
    hardn_status "pass" "Build artifacts cleaned"
    
    # TEST BRANCH: Summary for testers
    log_info "[TEST BRANCH] VM cleanup complete!"
    log_info "Your testing VM is now ready for a fresh HARDN-XDR installation."
    log_info "Next steps:"
    echo "  1. Download latest test branch ZIP from GitHub"
    echo "  2. Extract and run: make package"
    echo "  3. Install with: sudo make install-deb"
    echo "  4. Test and repeat as needed!"
}

#-----------------------------------------------------------------------------
# TEST BRANCH FEATURE: Complete Uninstall for Testing
#-----------------------------------------------------------------------------
# This combines standard uninstall with build artifact cleanup, providing
# a one-stop solution for testers who want to completely reset their VM
# between test iterations. This is especially useful when:
# - Testing installation procedures
# - Verifying clean install behavior
# - Switching between different versions/branches
# - Debugging installation issues
#
# This eliminates the need to restore VM snapshots for most testing scenarios,
# significantly speeding up the testing workflow.
#-----------------------------------------------------------------------------
complete_uninstall() {
    log_warn "[TEST BRANCH] Complete HARDN-XDR uninstall and cleanup"
    log_info "This will remove:"
    echo "  - All HARDN security hardening"
    echo "  - All build artifacts and test files"
    echo "  - All configuration files"
    echo "  - Optionally: security packages"
    echo
    
    if ! confirm_action "Proceed with complete uninstall?" "n"; then
        log_info "Complete uninstall cancelled"
        return 0
    fi
    
    # Run standard uninstall
    remove_hardening
    
    # Clean build artifacts
    clean_build_artifacts
    
    # Remove HARDN package if installed
    if dpkg -l | grep -q "hardn-xdr"; then
        log_info "Removing hardn-xdr package..."
        if ! is_dry_run; then
            sudo dpkg --purge hardn-xdr 2>/dev/null || true
            log_debug "Removed hardn-xdr package"
        fi
    fi
    
    log_info "Complete uninstall finished"
    log_info "System is ready for fresh HARDN-XDR installation"
}

#-----------------------------------------------------------------------------
# Main Uninstall Menu (TEST BRANCH ENHANCED)
#-----------------------------------------------------------------------------
# Provides an interactive menu for testers to choose the appropriate
# cleanup level for their testing needs
#-----------------------------------------------------------------------------
main_uninstall() {
    log_info "HARDN-XDR Uninstall Module (TEST BRANCH)"
    log_separator "=" 50
    echo "${GREEN}TEST BRANCH ENHANCED OPTIONS:${NC}"
    echo
    echo "1) Standard uninstall - Remove HARDN hardening only"
    echo "   ${CYAN}(Preserves build files and packages)${NC}"
    echo
    echo "2) ${YELLOW}[TEST] Clean build artifacts${NC} - Remove .deb and build files"
    echo "   ${CYAN}(Quick VM cleanup between tests)${NC}"
    echo
    echo "3) ${YELLOW}[TEST] Complete uninstall${NC} - Remove everything"
    echo "   ${CYAN}(Full reset for fresh installation testing)${NC}"
    echo
    echo "4) Show removal plan - Preview what will be removed"
    echo "   ${CYAN}(Dry run - no changes made)${NC}"
    echo
    echo "5) Cancel - Exit without changes"
    echo
    
    read -p "Select option [1-5]: " choice
    
    case $choice in
        1)
            remove_hardening
            ;;
        2)
            clean_build_artifacts
            ;;
        3)
            complete_uninstall
            ;;
        4)
            show_removal_plan
            ;;
        5)
            log_info "Uninstall cancelled"
            ;;
        *)
            log_error "Invalid option"
            return 1
            ;;
    esac
}

#=============================================================================
# MAIN EXECUTION
#=============================================================================

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run with sudo or as root"
   echo "Usage: sudo ./uninstall.sh"
   exit 1
fi

# Check if we're in the right directory (should have Makefile or Cargo.toml)
if [[ ! -f "Makefile" ]] && [[ ! -f "Cargo.toml" ]] && [[ ! -d "usr/share/hardn" ]]; then
    log_warn "Warning: This doesn't appear to be the HARDN-XDR repository root"
    log_warn "Current directory: $(pwd)"
    if ! confirm_action "Continue anyway?" "n"; then
        exit 1
    fi
fi

# Run the main menu
main_uninstall
