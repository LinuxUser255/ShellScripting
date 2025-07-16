#!/usr/bin/env bash

install_prompt() {
        # Acceptable inputs: yes, y, no, n and Enter1
        read -r -p "Ready to install the new Neovim configuration? (yes/no) or hit Enter: " confirm
        confirm=${confirm:-"yes"}
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
        if ! [[ "$confirm" =~ ^(yes|y)$ ]]; then
            printf "\e[1;31m[-] Exiting installation.\e[0m\n"
            exit 1
        fi

}

install_prompt
