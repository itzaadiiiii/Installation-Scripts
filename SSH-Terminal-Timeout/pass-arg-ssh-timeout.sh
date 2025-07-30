#!/bin/bash

# Get primary OS ID (ubuntu, amzn, etc.)
OS=$(grep ^ID= /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')

echo "Detected OS: $OS"

# Default timeout (in seconds): 1800 = 30 minutes
TIMEOUT=1800

# Optional argument: "30m" or "1h"
if [[ "$1" == "1h" ]]; then
    TIMEOUT=3600
elif [[ "$1" == "30m" ]]; then
    TIMEOUT=1800
fi

# Install and start SSH
setup_ssh() {
    echo "Installing and enabling SSH..."

    if [[ "$OS" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y openssh-server
        sudo systemctl enable ssh
        sudo systemctl start ssh
    elif [[ "$OS" == "amzn" || "$OS" == "amazon" ]]; then
        sudo yum install -y openssh-server
        sudo systemctl enable sshd
        sudo systemctl start sshd
    else
        echo "Unsupported OS: $OS"
        exit 1
    fi
}

# Configure timeout (30m = 1800s, 1h = 3600s)
configure_timeout() {
    echo "Setting SSH session timeout to $TIMEOUT seconds..."

    CONFIG="/etc/ssh/sshd_config"
    sudo sed -i '/^ClientAliveInterval/d' $CONFIG
    sudo sed -i '/^ClientAliveCountMax/d' $CONFIG
    echo "ClientAliveInterval $TIMEOUT" | sudo tee -a $CONFIG
    echo "ClientAliveCountMax 0" | sudo tee -a $CONFIG

    if [[ "$OS" == "ubuntu" ]]; then
        sudo systemctl restart ssh
    else
        sudo systemctl restart sshd
    fi
}

# Run
setup_ssh
configure_timeout

echo "✅ SSH installed and timeout set to $((TIMEOUT/60)) minutes."
