#!/usr/bin/env bash


install_package_dependencies() {
    printf "\033[1;31[+] Installing package dependencies from progs.csv...\033[0m\n"
    progsfile="$1"
    if ! dpkg -s "$1" >/dev/null 2>&1; then
#        whiptail --infobox "Installing $1... ($2)" 7 60
        sudo apt install update -qq
        sudo apt install -y "$1"
    else
        whiptail --infobox "$1 is already installed." 7 60
    fi
}

install_package_dependencies
