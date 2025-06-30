#!/usr/bin/env bash


# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (e.g. sudo $0 <username>)"
  exit 1
fi

# Check for username argument
if [ -z "$1" ]; then
  echo "❌ Usage: $0 <username>"
  exit 1
fi

USERNAME="$1"

# Check if the user exists
if id "$USERNAME" &>/dev/null; then
  echo "✅ User '$USERNAME' exists."
else
  echo "❌ User '$USERNAME' does not exist. Create the user first with 'adduser $USERNAME'"
  exit 1
fi

# Add the user to the sudo group
usermod -aG sudo "$USERNAME"

# Confirm the user was added
if id "$USERNAME" | grep -q '\bsudo\b'; then
  echo "✅ '$USERNAME' has been added to the 'sudo' group."
else
  echo "❌ Failed to add '$USERNAME' to 'sudo' group."
  exit 1
fi

