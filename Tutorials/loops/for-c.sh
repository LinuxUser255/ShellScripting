#!/usr/bin/env bash

set -euo pipefail
pkgs=(vim git curl)

install_packages() {
    info "Installing packages..."
    printf "Debug: Packages: %s\n" "${pkgs[*]}" >&2
    local total=${#pkgs[@]}
    local failed=()

    if [ "$total" -eq 0 ]; then
        warning "No packages to process"
        return
    fi

    for ((i=0; i<${#pkgs[@]}; i++)); do
        if ! is_installed "${pkgs[i]}"; then
            printf "Installing (%d/%d): %s\n" "$((i+1))" "$total" "${pkgs[i]}" >&2
            if apt install -y "${pkgs[i]}" >>install.log 2>&1; then
                success "Installed ${pkgs[i]}"
            else
                warning "Failed to install ${pkgs[i]}"
                failed+=("${pkgs[i]}")
            fi
        else
            info "Package ${pkgs[i]} is already installed."
        fi
    done

    if ((${#failed[@]} > 0)); then
        warning "Failed to install ${#failed[@]} packages: ${failed[*]}"
    else
        success "All packages installed successfully"
    fi
}



main() {
    install_packages
}


main
