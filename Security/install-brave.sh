#!/usr/bin/env bash

install_brave() {
        info "Installing Brave browser..."

        # Check if Brave is already installed
        if cmd_exists brave-browser; then
            info "Brave is already installed."
            return
        fi

        # Install Brave dependencies
        apt install -y apt-transport-https curl gnupg gnupg2 ||
            error "Failed to install Brave dependencies."

        # Import Brave's GPG key
        curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor |
            tee /usr/share/keyrings/brave-browser-archive-keyring.gpg >/dev/null ||
            error "Failed to import Brave's GPG key."

        # Add Brave repository to APT sources
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" |
            tee /etc/apt/sources.list.d/brave-browser-release.list ||
            error "Failed to add Brave repository to APT sources."

        # Update APT sources and install Brave
        apt update && apt install -y brave-browser ||
            error "Failed to install Brave browser."

        success "Brave browser installed successfully."
}

install_brave
