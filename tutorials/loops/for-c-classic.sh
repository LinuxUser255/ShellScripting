#!/usr/bin/env bash

pkgs=(vim git curl)

install_packages() {
    info "Installing packages..."
    local total=${#pkgs[@]}
    local count=0
    local failed=()

    for pkg in "${pkgs[@]}"; do
        ((count++))

        printf "Processing (%d/%d): %s\n" "$count" "$total" "$pkg"
        if [ "$pkg" = "git" ]; then
            warning "Failed to process $pkg"
            failed+=("$pkg")
        else
            success "Processed $pkg"
        fi
    done

    if ((${#failed[@]} > 0)); then
        warning "Failed to process ${#failed[@]} packages: ${failed[*]}"
    else
        success "All packages processed successfully"
    fi
}
