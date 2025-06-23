#!/usr/bin/env bash

# This function is to be implemented into hardn-main.sh

# ABOUT the function
#  Hardens SSH configuration.
#  Creates a backup, apples the custom sshd_config file, validates the config, then restarts SSH.
#  ADDITIONAl:
# Need to  ensure that the SSH service remains functional even if there are issues with the configuration file,
# Such as, in the event of a broken SSH config, this approach can avoid an SSH lockout.

# Steps:
# 1. Proper error handling
# 2. Configuration validation before applying changes
# 3. Automatic rollback if something goes wrong
# 4. Clear logging of what's happening

# check if script is being run from the correct directory
check_user(){
        if [ "$(id -u)" -ne 0 ]; then
            printf "\e[1;31mError: This script must be run as root\e[0m\n"
            exit 1
        fi
}

# Function to ensure SSH prerequisites are met
ensure_ssh_prerequisites() {
        # Check if sshd directory exists, create if not
        if [ ! -d "/run/sshd" ]; then
            printf "\e[1;31mCreating missing privilege separation directory: /run/sshd\e[0m\n"
            mkdir -p /run/sshd
            chmod 0755 /run/sshd
        fi

        # Check if OpenSSH server is installed
        if ! command -v sshd >/dev/null 2>&1; then
            printf "\e[1;31mOpenSSH server is not installed. Installing...\e[0m\n"
            apt update && apt install -y openssh-server
            if [ ! $? -ne 0 ]; then
                printf "\e[1;31mFailed to install OpenSSH server. Aborting.\e[0m\n"
                return 1
            fi
        fi

        return 0
}

harden_ssh_config() {
        printf "\e[1;31mHardening SSH configuration...\e[0m\n"

        # Define paths
        local system_config="/etc/ssh/sshd_config"
        local backup_config
        backup_config="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"
        local temp_config="/tmp/sshd_config.new"

        # Backup original config sshd_config
        if ! cp "${system_config}" "${backup_config}"; then
            printf "\e[1;31mFailed to create backup of SSH config. Aborting.\e[0m\n"
            return 1
        fi
        printf "\e[1;32mBackup created at %s\e[0m\n" "${backup_config}"

        # Create custom config in a temporary file first
        cat > "${temp_config}" << 'EOF'
###################################################
# THIS IS THE SECURITY HARDNED CUSTOM SSHD_CONFIG #
###################################################

# This is the sshd server system-wide configuration file.
# This is the configuration we shall use for HARDN-XDR
# Much of the settings in this file are from.
# https://linux-audit.com/ssh/audit-and-harden-your-ssh-configuration/
# And they are set as the result of much lynis testing.
# It is Configured according to lynis security testing
# This is the configuration file that will be implemented as part of
# HARDN-XDR
# All the uncommented lines are self-explanatory


# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

# Use an unconventional port number for ssh.
# Protects against brute force attacks that seek port 22
Port 8022
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
LogLevel VERBOSE

# Authentication:
LoginGraceTime 60
PermitRootLogin prohibit-password
StrictModes yes
MaxAuthTries 3
MaxSessions 4

PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
AuthorizedKeysFile	.ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none/
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
KbdInteractiveAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin prohibit-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

AllowAgentForwarding no
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
TCPKeepAlive no
#PermitUserEnvironment no
#Compression delayed
ClientAliveInterval 300
ClientAliveCountMax 0
UseDNS no
#PidFile /run/sshd.pid
MaxStartups 10:30:60
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem	sftp	/usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
#   MaxSessions 4
EOF

        # Validate the new configuration
        printf "\e[1;32mValidating new SSH configuration...\e[0m\n"
        if ! sshd -t -f "${temp_config}"; then
            printf "\e[1;31mNew SSH configuration is invalid. Keeping original configuration.\e[0m\n"
            rm -f "${temp_config}"
            return 1
        fi

        # Apply the new configuration
        printf "\e[1;32mApplying new SSH configuration...\e[0m\n"
        if ! cp "${temp_config}" "${system_config}"; then
            printf "\e[1;31mFailed to apply new SSH configuration. Keeping original configuration.\e[0m\n"
            rm -f "${temp_config}"
            return 1
        fi

        # Clean up temporary file
        rm -f "${temp_config}"

        # Restart SSH service
        printf "\e[1;32mRestarting SSH service...\e[0m\n"
        if ! systemctl restart ssh; then
            printf "\e[1;31mFailed to restart SSH service. Rolling back to original configuration...\e[0m\n"
            cp "${backup_config}" "${system_config}"
            systemctl restart ssh
            return 1
        fi

        # Verify SSH service is running
        if ! systemctl is-active --quiet ssh; then
            printf "\e[1;31mSSH service failed to start. Rolling back to original configuration...\e[0m\n"
            cp "${backup_config}" "${system_config}"
            systemctl restart ssh
            return 1
        fi

        printf "\e[1;32mSSH configuration hardened successfully!\e[0m\n"
        printf "\e[1;32mNOTE: SSH is now configured to use port 8022 instead of the default port 22.\e[0m\n"
        printf "\e[1;32mNOTE: Password authentication is disabled. Make sure you have SSH keys set up.\e[0m\n"
        return 0
}


main(){
        check_user
        ensure_ssh_prerequisites
        harden_ssh_config
}

main
