#!/usr/bin/env bash

# =============================================================================
# yt4k - Download 4K videos with yt-dlp
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# CONFIGURATION
# =============================================================================

OUTPUT_DIR="${YT4K_OUTPUT_DIR:-$HOME/Videos}"
MAX_HEIGHT="${YT4K_MAX_HEIGHT:-2160}"

# =============================================================================
# UTILITIES
# =============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

die() {
    print_error "$1"
    exit 1
}

# =============================================================================
# VALIDATION
# =============================================================================

check_requirements() {
    if ! command -v yt-dlp &>/dev/null; then
        die "yt-dlp is not installed. Install with: pip install yt-dlp"
    fi
}

validate_url() {
    local url="$1"
    if [[ -z "$url" ]]; then
        return 1
    fi
    # Basic URL validation
    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    fi
    return 1
}

# =============================================================================
# CORE FUNCTIONS
# =============================================================================

show_formats() {
    local url="$1"
    print_info "Available formats for: $url"
    echo ""
    yt-dlp -F "$url"
}

download_4k() {
    local url="$1"
    local output_dir="$2"
    
    print_info "Downloading 4K video..."
    print_info "Output directory: $output_dir"
    echo ""
    
    yt-dlp \
        -f "bestvideo[height<=${MAX_HEIGHT}]+bestaudio/best[height<=${MAX_HEIGHT}]/best" \
        --merge-output-format mp4 \
        -o "${output_dir}/%(title)s.%(ext)s" \
        --progress \
        "$url"
}

download_4k_exact() {
    local url="$1"
    local output_dir="$2"
    
    print_info "Downloading exact 4K (2160p) video..."
    print_info "Output directory: $output_dir"
    echo ""
    
    yt-dlp \
        -f "bestvideo[height=2160]+bestaudio/best[height=2160]" \
        --merge-output-format mp4 \
        -o "${output_dir}/%(title)s.%(ext)s" \
        --progress \
        "$url"
}

download_4k_mp4_only() {
    local url="$1"
    local output_dir="$2"
    
    print_info "Downloading 4K video (MP4 preferred)..."
    print_info "Output directory: $output_dir"
    echo ""
    
    yt-dlp \
        -f "bestvideo[height<=${MAX_HEIGHT}][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
        --merge-output-format mp4 \
        -o "${output_dir}/%(title)s.%(ext)s" \
        --progress \
        "$url"
}

# =============================================================================
# USAGE
# =============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <URL>

Download 4K videos using yt-dlp.

OPTIONS:
    -h, --help          Show this help message
    -f, --formats       List available formats (no download)
    -e, --exact         Download exact 4K (2160p) only, fail if unavailable
    -m, --mp4           Prefer MP4 format
    -o, --output DIR    Output directory (default: $OUTPUT_DIR)

ENVIRONMENT VARIABLES:
    YT4K_OUTPUT_DIR     Default output directory
    YT4K_MAX_HEIGHT     Maximum video height (default: 2160)

EXAMPLES:
    $(basename "$0") "https://youtube.com/watch?v=VIDEO_ID"
    $(basename "$0") -f "https://youtube.com/watch?v=VIDEO_ID"
    $(basename "$0") -e -o ~/Downloads "https://youtube.com/watch?v=VIDEO_ID"
    $(basename "$0") -m "https://youtube.com/watch?v=VIDEO_ID"

EOF
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local show_formats_only=false
    local exact_4k=false
    local mp4_only=false
    local output_dir="$OUTPUT_DIR"
    local url=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -f|--formats)
                show_formats_only=true
                shift
                ;;
            -e|--exact)
                exact_4k=true
                shift
                ;;
            -m|--mp4)
                mp4_only=true
                shift
                ;;
            -o|--output)
                if [[ -z "${2:-}" ]]; then
                    die "Option -o requires an argument"
                fi
                output_dir="$2"
                shift 2
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                url="$1"
                shift
                ;;
        esac
    done
    
    # Check requirements
    check_requirements
    
    # Validate URL
    if [[ -z "$url" ]]; then
        print_error "No URL provided"
        echo ""
        usage
        exit 1
    fi
    
    if ! validate_url "$url"; then
        die "Invalid URL: $url"
    fi
    
    # Create output directory if needed
    if [[ ! -d "$output_dir" ]]; then
        print_info "Creating output directory: $output_dir"
        mkdir -p "$output_dir"
    fi
    
    # Execute requested action
    if [[ "$show_formats_only" == true ]]; then
        show_formats "$url"
    elif [[ "$exact_4k" == true ]]; then
        download_4k_exact "$url" "$output_dir"
    elif [[ "$mp4_only" == true ]]; then
        download_4k_mp4_only "$url" "$output_dir"
    else
        download_4k "$url" "$output_dir"
    fi
    
    print_info "Done!"
}

main "$@"
