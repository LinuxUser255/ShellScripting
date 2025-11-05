#!/usr/bin/env bash

# SAFE FAST TAR - No nested processes, controlled resources
set -euo pipefail

# Configuration
TARGET="${1:-old-downloads}"
OUTPUT="${TARGET}.tar.zst"

# Validate target exists
if [[ ! -e "$TARGET" ]]; then
    echo "Error: '$TARGET' not found"
    exit 1
fi

# Check for existing archive
if [[ -f "$OUTPUT" ]]; then
    echo "Error: '$OUTPUT' already exists. Remove it first or choose different name."
    exit 1
fi

# Get size for progress bar
SIZE=$(du -sb "$TARGET" 2>/dev/null | cut -f1 || echo 0)

# Auto-detect safe thread count (leave some for system)
THREADS=$(( $(nproc) - 2 ))
[[ $THREADS -lt 1 ]] && THREADS=1

# Check available RAM and adjust compression
RAM_GB=$(free -g | awk '/Mem:/ {print int($2)}')
if [[ $RAM_GB -lt 4 ]]; then
    LEVEL=14  # Low memory safe
    EXTRA=""
elif [[ $RAM_GB -lt 16 ]]; then
    LEVEL=16  # Medium memory
    EXTRA=""
else
    LEVEL=16  # High memory - still safe
    EXTRA="--long"
fi

echo "Compressing '$TARGET' ($(numfmt --to=iec-i --suffix=B $SIZE 2>/dev/null || echo 'size unknown'))"
echo "Using: zstd -$LEVEL -T$THREADS $EXTRA"

# SAFE PIPELINE: No nested process substitutions
# Using proper pipes and error handling
if tar -c --sparse "$TARGET" 2>/dev/null | \
   pv -s "$SIZE" -F ' %b  %t  %p  @ %r' 2>/dev/null | \
   zstd -$LEVEL -T$THREADS $EXTRA -o "$OUTPUT" 2>/dev/null; then

    echo "Verifying archive..."
    if zstd -t "$OUTPUT" 2>/dev/null; then
        FINAL_SIZE=$(stat -c%s "$OUTPUT" 2>/dev/null || echo 0)
        if [[ $SIZE -gt 0 && $FINAL_SIZE -gt 0 ]]; then
            SAVED=$(( 100 - (FINAL_SIZE * 100 / SIZE) ))
            echo "✓ Success! Archive verified."
            echo "  Size: $(du -h "$OUTPUT" | cut -f1) (saved ${SAVED}%)"
            echo ""
            echo "To remove original (VERIFY BACKUP FIRST!):"
            echo "  rm -rf '$TARGET'"
        else
            echo "✓ Archive created: $OUTPUT"
        fi
    else
        echo "✗ ERROR: Archive verification failed!"
        echo "  DO NOT delete the original!"
        exit 1
    fi
else
    echo "✗ ERROR: Compression failed!"
    [[ -f "$OUTPUT" ]] && rm -f "$OUTPUT"
    exit 1
fi

