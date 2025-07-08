#!/usr/bin/env bash

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--create)
                : "create"
                OPERATION="$_"
                shift
                ;;
            -x|--extract)
                : "extract"
                OPERATION="$_"
                shift
                ;;
            -z|--gzip)
                : "gzip"
                COMPRESSION="$_"
                shift
                ;;
            -j|--bzip2)
                : "bzip2"
                COMPRESSION="$_"
                shift
                ;;
            -o|--output)
                : "$2"
                OUTPUT_FILE="$_"
                shift 2
                ;;
            -s|--source)
                : "$2"
                SOURCE_DIR="$_"
                shift 2
                ;;
            -v|--verbose)
                : true
                VERBOSE="$_"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}
