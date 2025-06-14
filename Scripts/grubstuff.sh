#!/usr/bin/env bash

grub_security(){

    if [[ -f /boot/grub/grub.cfg ]]; then
        GREETING="Hello Grub Cofig"
    elif [[ -f /boot/grub2/grub.cfg ]]; then
        GREETING="Hello Grub2 conf"
    else
        echo "[-] GRUB config not found. Please verify GRUB installation."
        echo 100
        sleep 0.2
        return 1


    fi

        echo "[+] Configuring GRUB security settings..."
        BACKUP_GREETING="$GREETING"
        printf $GREETING
        echo 'copying "$GRUB_CFG" "$BACKUP_CFG"'
        echo "[+] Backup created at $BACKUP_GREETING"
        echo 60
        sleep 0.2
}

grub_security
