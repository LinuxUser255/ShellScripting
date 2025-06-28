#!/usr/bin/env bash

#To install **VirtualBox Guest Additions** on your **Debian VM**, follow this **step-by-step guide**.
# These additions improve integration with the host, including shared clipboard, drag & drop, shared folders, and screen resizing.

### ✅ Step-by-Step: Install Guest Additions on Debian VM

#> 🖥️ These instructions assume you're using **VirtualBox** and running **Debian 12 or similar** as the guest OS.

# 🔹 1. Update Your System

sudo apt update && sudo apt upgrade -y


# 🔹 2. Install Required Packages
# These are needed to build the Guest Additions kernel modules:
sudo apt install -y build-essential dkms linux-headers-"$(uname -r)"


# 🔹 3. Insert the Guest Additions ISO
#1. In VirtualBox menu:
#   Go to `Devices` → `Insert Guest Additions CD image...`
#
#2. Mount the CD (if it doesn't auto-mount):
sudo mount /dev/cdrom /mnt


# 🔹 4. Run the Guest Additions Installer
sudo /mnt/VBoxLinuxAdditions.run

#Watch for messages about success or errors.

# 🔹 5. Reboot

sudo reboot


# ✅ Confirm Installation
#After rebooting, run:

lsmod | grep vboxguest


ps aux | pgrep VBox


## 🧪 Test Features

#   * **Automatic screen resizing**: Try resizing your VM window.
#   * **Shared clipboard**: Enable via `Devices → Shared Clipboard → Bidirectional`
#   * **Shared folders**: Configure in VM settings → Shared Folders tab.
#
#   ---
#
#   ## 🛠️ Troubleshooting Tips
#
#   * If `/mnt/VBoxLinuxAdditions.run` fails:
#
#     * Make sure your system is **fully updated**.
#     * Check for build tools: `gcc`, `make`, and `dkms` must be installed.
#     * Re-insert the Guest Additions ISO if needed.
#
