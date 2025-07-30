#!/bin/bash

# Get OS type (ubuntu, amzn, etc.)
OS=$(grep ^ID= /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')

echo "Detected OS: $OS"

# Timeout = 30 minutes = 1800 seconds
TIMEOUT=1800

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

configure_timeout() {
    echo "Setting SSH session timeout to 30 minutes..."

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

setup_ssh
configure_timeout

echo "✅ SSH installed and 30-minute timeout configured."


