# LUKS Encrypted USB and External Drive Setup Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Identifying Your Drive](#identifying-your-drive)
3. [Creating LUKS Encrypted USB Drive](#creating-luks-encrypted-usb-drive)
4. [Creating LUKS Encrypted External Hard Drive](#creating-luks-encrypted-external-hard-drive)
5. [Mounting and Using Encrypted Drives](#mounting-and-using-encrypted-drives)
6. [Automounting (Optional)](#automounting-optional)
7. [Backup and Recovery](#backup-and-recovery)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Packages
Install the necessary tools:
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install cryptsetup parted

# Fedora/RHEL
sudo dnf install cryptsetup parted

# Arch
sudo pacman -S cryptsetup parted
```

### Important Warnings
⚠️ **WARNING**: These operations will destroy all data on the target drive. Ensure you have backups of any important data.

⚠️ **SECURITY NOTE**: Choose a strong passphrase. Consider using a password manager to generate and store it securely.

## Identifying Your Drive

### Step 1: List All Drives
```bash
# List all block devices
lsblk

# Alternative: Show more detail
sudo fdisk -l

# Show only USB devices
lsusb
```

### Step 2: Identify Target Drive
Look for your USB or external drive. Common identifiers:
- USB drives: Often `/dev/sdb`, `/dev/sdc`, etc.
- External drives: Similar naming convention
- NVMe drives: `/dev/nvme0n1`, `/dev/nvme1n1`, etc.

### Step 3: Verify Drive Selection
```bash
# Replace /dev/sdX with your actual device
sudo fdisk -l /dev/sdX

# Double-check with dmesg
dmesg | tail -20
```

## Creating LUKS Encrypted USB Drive

### Step 1: Unmount the Drive (if mounted)
```bash
# Check if mounted
mount | grep /dev/sdX

# Unmount if necessary
sudo umount /dev/sdX*
```

### Step 2: Securely Wipe the Drive (Optional but Recommended)
```bash
# Quick wipe with random data (faster)
sudo dd if=/dev/urandom of=/dev/sdX bs=1M status=progress

# OR thorough wipe with zeros (slower)
sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress
```

### Step 3: Create Partition Table
```bash
# Create GPT partition table (recommended for drives > 2TB)
sudo parted /dev/sdX mklabel gpt

# OR create MBR partition table (for compatibility with older systems)
sudo parted /dev/sdX mklabel msdos
```

### Step 4: Create Partition
```bash
# Create a single partition using entire disk
sudo parted /dev/sdX mkpart primary 0% 100%

# Verify partition creation
sudo parted /dev/sdX print
```

### Step 5: Setup LUKS Encryption
```bash
# Initialize LUKS encryption on the partition
# Note: Use /dev/sdX1 (the partition) not /dev/sdX (the whole disk)
sudo cryptsetup luksFormat /dev/sdX1

# You will be prompted:
# - Type YES (in uppercase) to confirm
# - Enter passphrase twice
```

### Step 6: Open the Encrypted Container
```bash
# Open the LUKS container with a mapper name
sudo cryptsetup luksOpen /dev/sdX1 encrypted_usb

# Verify it's open
ls /dev/mapper/
```

### Step 7: Create Filesystem
```bash
# Create ext4 filesystem (recommended for Linux)
sudo mkfs.ext4 /dev/mapper/encrypted_usb

# OR create FAT32 for cross-platform compatibility (4GB file size limit)
sudo mkfs.vfat -F32 /dev/mapper/encrypted_usb

# OR create exFAT for cross-platform with large file support
sudo mkfs.exfat /dev/mapper/encrypted_usb
```

### Step 8: Mount and Set Permissions
```bash
# Create mount point
sudo mkdir -p /mnt/encrypted_usb

# Mount the encrypted drive
sudo mount /dev/mapper/encrypted_usb /mnt/encrypted_usb

# Set ownership (replace username with your actual username)
sudo chown -R username:username /mnt/encrypted_usb
```

## Creating LUKS Encrypted External Hard Drive

The process for external hard drives is identical to USB drives, with a few considerations:

### Additional Considerations for External Drives

1. **Partition Scheme**: For drives larger than 2TB, always use GPT:
```bash
sudo parted /dev/sdX mklabel gpt
```

2. **LUKS2 Format** (Recommended for newer systems):
```bash
# Use LUKS2 format for better security and features
sudo cryptsetup luksFormat --type luks2 /dev/sdX1
```

3. **Cipher Options** (Optional - for enhanced security):
```bash
# Custom cipher and key size
sudo cryptsetup luksFormat \
    --type luks2 \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha512 \
    --iter-time 5000 \
    /dev/sdX1
```

4. **Multiple Partitions** (Optional):
```bash
# Create multiple encrypted partitions
sudo parted /dev/sdX mkpart primary 0% 50%
sudo parted /dev/sdX mkpart primary 50% 100%

# Encrypt each partition separately
sudo cryptsetup luksFormat /dev/sdX1
sudo cryptsetup luksFormat /dev/sdX2
```

## Mounting and Using Encrypted Drives

### Manual Mounting
```bash
# 1. Attach the drive and identify it
lsblk

# 2. Open the LUKS container
sudo cryptsetup luksOpen /dev/sdX1 my_encrypted_drive

# 3. Mount the filesystem
sudo mkdir -p /mnt/encrypted
sudo mount /dev/mapper/my_encrypted_drive /mnt/encrypted

# 4. Use the drive
cd /mnt/encrypted
# Copy files, etc.

# 5. Unmount when done
sudo umount /mnt/encrypted

# 6. Close the LUKS container
sudo cryptsetup luksClose my_encrypted_drive
```

### Quick Mount Script
Create a helper script for frequent use:
```bash
#!/bin/bash
# save as ~/bin/mount-encrypted.sh

DEVICE="/dev/sdX1"
MAPPER_NAME="encrypted_drive"
MOUNT_POINT="/mnt/encrypted"

# Open LUKS container
sudo cryptsetup luksOpen $DEVICE $MAPPER_NAME

# Create mount point if it doesn't exist
sudo mkdir -p $MOUNT_POINT

# Mount
sudo mount /dev/mapper/$MAPPER_NAME $MOUNT_POINT

echo "Encrypted drive mounted at $MOUNT_POINT"
```

## Automounting (Optional)

### Method 1: Using /etc/crypttab and /etc/fstab

1. Get UUID of the encrypted partition:
```bash
sudo blkid /dev/sdX1
```

2. Edit `/etc/crypttab`:
```bash
# Add line (replace UUID with your actual UUID)
encrypted_drive UUID=your-uuid-here none luks,noauto
```

3. Edit `/etc/fstab`:
```bash
# Add line for mounting
/dev/mapper/encrypted_drive /mnt/encrypted ext4 noauto,user 0 0
```

### Method 2: Using systemd (Modern Systems)

Create a systemd service for automatic mounting:
```bash
# Create service file
sudo nano /etc/systemd/system/mount-encrypted.service
```

Add content:
```ini
[Unit]
Description=Mount encrypted drive
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/cryptsetup luksOpen /dev/disk/by-uuid/YOUR-UUID encrypted_drive
ExecStart=/bin/mount /dev/mapper/encrypted_drive /mnt/encrypted
ExecStop=/bin/umount /mnt/encrypted
ExecStop=/usr/sbin/cryptsetup luksClose encrypted_drive
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

## Backup and Recovery

### Backup LUKS Header
**Critical**: Always backup the LUKS header. Without it, data is unrecoverable if the header is damaged.

```bash
# Backup header
sudo cryptsetup luksHeaderBackup /dev/sdX1 \
    --header-backup-file luks-header-backup-$(date +%Y%m%d).bin

# Store this file securely (not on the encrypted drive!)
```

### Restore LUKS Header
```bash
# Restore header from backup
sudo cryptsetup luksHeaderRestore /dev/sdX1 \
    --header-backup-file luks-header-backup.bin
```

### Add Additional Passphrases
LUKS supports up to 8 key slots:
```bash
# Add a new passphrase
sudo cryptsetup luksAddKey /dev/sdX1

# View key slots
sudo cryptsetup luksDump /dev/sdX1
```

### Remove a Passphrase
```bash
# Remove a specific key slot (0-7)
sudo cryptsetup luksRemoveKey /dev/sdX1
```

## Troubleshooting

### Common Issues and Solutions

#### 1. "Device or resource busy"
```bash
# Check what's using the device
lsof | grep /dev/sdX
fuser -m /dev/sdX1

# Force unmount if necessary
sudo umount -f /mnt/encrypted
```

#### 2. "No key available with this passphrase"
- Check caps lock
- Ensure correct keyboard layout
- Try alternate passphrases if you added multiple

#### 3. Check LUKS Container Status
```bash
# View LUKS header information
sudo cryptsetup luksDump /dev/sdX1

# Test passphrase without mounting
sudo cryptsetup luksOpen --test-passphrase /dev/sdX1
```

#### 4. Performance Optimization
```bash
# Check current cipher and mode
sudo cryptsetup status encrypted_drive

# Benchmark encryption performance
sudo cryptsetup benchmark
```

#### 5. Emergency Access
If you forget the passphrase but have the header backup and a recovery key:
```bash
# Use recovery key (if configured)
sudo cryptsetup luksOpen /dev/sdX1 emergency --key-file /path/to/recovery.key
```

## Security Best Practices

1. **Strong Passphrases**: Use at least 20 characters with mixed case, numbers, and symbols
2. **Regular Backups**: Keep encrypted backups of both data and LUKS headers
3. **Key Management**: Store passphrases in a password manager
4. **Physical Security**: Store drives in secure locations
5. **Secure Deletion**: Use `shred` or `dd` to securely delete sensitive files before encryption
6. **Regular Updates**: Keep cryptsetup and kernel updated for security patches
7. **Two-Factor Options**: Consider using YubiKey or similar for additional security

## Quick Reference Commands

```bash
# Encrypt a drive (simple)
sudo cryptsetup luksFormat /dev/sdX1
sudo cryptsetup luksOpen /dev/sdX1 encrypted
sudo mkfs.ext4 /dev/mapper/encrypted

# Mount encrypted drive
sudo cryptsetup luksOpen /dev/sdX1 encrypted
sudo mount /dev/mapper/encrypted /mnt/encrypted

# Unmount encrypted drive
sudo umount /mnt/encrypted
sudo cryptsetup luksClose encrypted

# Check status
sudo cryptsetup status encrypted
sudo cryptsetup luksDump /dev/sdX1

# Backup/Restore header
sudo cryptsetup luksHeaderBackup /dev/sdX1 --header-backup-file backup.bin
sudo cryptsetup luksHeaderRestore /dev/sdX1 --header-backup-file backup.bin
```

## Additional Resources

- [LUKS Official Documentation](https://gitlab.com/cryptsetup/cryptsetup)
- [Arch Wiki - dm-crypt/Device encryption](https://wiki.archlinux.org/title/Dm-crypt/Device_encryption)
- [Ubuntu Community Help - Encrypted Filesystems](https://help.ubuntu.com/community/EncryptedFilesystems)
- [Red Hat - Encrypting Block Devices Using LUKS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/encrypting-block-devices-using-luks_security-hardening)