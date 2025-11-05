#!/usr/bin/env bash

# SMART-ZSTD-BACKUP.SH - Safe and reliable zstd backup script
#=======================================================================
# Automatically detects system hardware and optimizes compression settings
# Usage: ./smart-zstd-backup.sh <directory-or-file>

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_info()    { echo -e "${YELLOW}[INFO]${NC} $*"; }

# Check dependencies
check_dependencies() {
    local missing=()
    for cmd in tar zstd pv; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        log_info "Install with: sudo apt-get install ${missing[*]}"
        exit 1
    fi
}

# Validate input
validate_input() {
    local target="${1:-}"
    
    if [[ -z "$target" ]]; then
        log_error "Usage: $0 <directory-or-file>"
        exit 1
    fi
    
    if [[ ! -e "$target" ]]; then
        log_error "Path not found: $target"
        exit 1
    fi
    
    # Remove trailing slashes for consistency
    target="${target%/}"
    echo "$target"
}

# Calculate optimal compression settings
calculate_settings() {
    local cores ram_gb threads level long_flag=""
    
    cores=$(nproc 2>/dev/null || echo 2)
    ram_gb=$(free -g 2>/dev/null | awk '/Mem:/ {print int($2)}' || echo 1)
    
    log_info "Detected: $cores CPU threads, ${ram_gb}GB RAM"
    
    # Smart thread allocation (leave some for system)
    if   (( cores >= 32 )); then threads=$((cores - 4)); level=18
    elif (( cores >= 16 )); then threads=$((cores - 2)); level=17
    elif (( cores >= 8  )); then threads=$((cores - 1)); level=16
    elif (( cores >= 4  )); then threads=$((cores - 1)); level=15
    else                          threads=$cores;        level=14
    fi
    
    # Adjust for low memory systems
    if (( ram_gb <= 2 )); then
        level=$((level > 15 ? 15 : level))
        log_info "Low memory detected, capping compression level at $level"
    fi
    
    # Long-range mode for high memory systems
    if (( ram_gb >= 32 )); then
        long_flag="--long"
        log_info "Enabling long-range mode for better compression"
    fi
    
    # Check if ultra mode is safe (needs more memory)
    local ultra_flag=""
    if (( level >= 20 && ram_gb >= 16 )); then
        ultra_flag="--ultra"
    elif (( level > 19 )); then
        level=19  # Cap at 19 without --ultra
    fi
    
    echo "$threads $level $long_flag $ultra_flag"
}

# Get size of target for progress bar
get_size() {
    local target="$1"
    if [[ -d "$target" ]]; then
        du -sb "$target" 2>/dev/null | cut -f1 || echo 0
    else
        stat -c%s "$target" 2>/dev/null || echo 0
    fi
}

# Create safe archive name
create_archive_name() {
    local target="$1"
    local base_name=$(basename "$target")
    local archive="${base_name}.tar.zst"
    local counter=1
    
    # Don't overwrite existing archives
    while [[ -e "$archive" ]]; do
        archive="${base_name}.${counter}.tar.zst"
        ((counter++))
    done
    
    echo "$archive"
}

# Main backup function
perform_backup() {
    local target="$1"
    local archive="$2"
    local threads="$3"
    local level="$4"
    shift 4
    local extra_flags="$*"
    
    local size=$(get_size "$target")
    local tar_target
    
    # Determine tar target (handle both files and directories)
    if [[ -d "$target" ]]; then
        # For directories, use parent dir and basename to avoid path issues
        local parent_dir=$(dirname "$target")
        local base_name=$(basename "$target")
        tar_target="-C $parent_dir $base_name"
    else
        # For files, similar approach
        local parent_dir=$(dirname "$target")
        local base_name=$(basename "$target")
        tar_target="-C $parent_dir $base_name"
    fi
    
    log_info "Compressing with: zstd -$level -T$threads $extra_flags"
    log_info "Output: $archive"
    
    # Create archive with progress bar
    if (( size > 0 )); then
        eval "tar -cf - $tar_target" 2>/dev/null \
            | pv -s "$size" -F ' %b  %t  %p  ETA %e  @ %r' \
            | zstd -"$level" -T"$threads" $extra_flags -o "$archive" 2>/dev/null
    else
        eval "tar -cf - $tar_target" 2>/dev/null \
            | zstd -"$level" -T"$threads" $extra_flags -o "$archive"
    fi
    
    return $?
}

# Verify archive integrity
verify_archive() {
    local archive="$1"
    
    log_info "Verifying archive integrity..."
    
    if zstd -t "$archive" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Calculate and display statistics
show_statistics() {
    local target="$1"
    local archive="$2"
    
    local original_size=$(get_size "$target")
    local archive_size=$(stat -c%s "$archive" 2>/dev/null || echo 0)
    
    if (( original_size > 0 && archive_size > 0 )); then
        local saved_percent=$(( 100 - (archive_size * 100 / original_size) ))
        local archive_human=$(numfmt --to=iec-i --suffix=B "$archive_size" 2>/dev/null || du -h "$archive" | cut -f1)
        local original_human=$(numfmt --to=iec-i --suffix=B "$original_size" 2>/dev/null || echo "unknown")
        
        log_success "Archive created successfully!"
        echo "  Original size: $original_human"
        echo "  Archive size:  $archive_human"
        echo "  Space saved:   ${saved_percent}%"
        echo ""
        log_info "To extract: tar -I 'zstd -d' -xf '$archive'"
        log_info "To delete original (verify first!): rm -rf '$target'"
    else
        log_success "Archive created: $archive"
    fi
}

# Main execution
main() {
    # Check dependencies first
    check_dependencies
    
    # Validate and normalize input
    TARGET=$(validate_input "$1")
    
    # Calculate optimal settings
    read -r THREADS LEVEL EXTRA_FLAGS <<< $(calculate_settings)
    
    # Create safe archive name
    ARCHIVE=$(create_archive_name "$TARGET")
    
    # Perform backup
    if perform_backup "$TARGET" "$ARCHIVE" "$THREADS" "$LEVEL" $EXTRA_FLAGS; then
        # Verify integrity
        if verify_archive "$ARCHIVE"; then
            show_statistics "$TARGET" "$ARCHIVE"
        else
            log_error "Archive verification failed! The archive may be corrupted."
            log_info "Archive kept at: $ARCHIVE (please verify manually)"
            exit 1
        fi
    else
        log_error "Backup failed!"
        [[ -f "$ARCHIVE" ]] && rm -f "$ARCHIVE"
        exit 1
    fi
}

# Run main function
main "$@"