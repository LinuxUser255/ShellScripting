#!/usr/bin/env bash

# MAKE THE CURSOR GO FAST
# Cursor Speed Control Script
# Adjusts keyboard repeat rate and delay for faster/normal typing


# Check if xset is available, install if needed
if ! command -v xset &> /dev/null; then
    echo "Installing required package..."
    sudo apt install -y x11-xserver-utils
fi

echo ''
echo -e 'Adjust cursor speed:'
echo -e '1) Fast (360ms delay, 70Hz repeat)'
echo -e '2) Normal (320ms delay, 40Hz repeat)'
read -r -p 'Select option [1-2]: ' sel

case "$sel" in
    1)
        : "360 70"  # Fast setting
        echo "Setting cursor to fast mode"
    ;;

    2)
        : "320 40"  # Normal setting
        echo "Setting cursor to normal mode"
    ;;

    *)
        echo "Invalid selection. Using default settings."
        : "320 40"  # Default to normal
    ;;
esac

# Apply the selected settings
# shellcheck disable=SC2086
xset r rate $_


echo "Cursor speed updated successfully."
