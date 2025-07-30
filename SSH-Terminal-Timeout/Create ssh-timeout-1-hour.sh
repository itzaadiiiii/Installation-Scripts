#!/bin/bash

# Detect OS
OS=$(grep -i ^id /etc/os-release | cut -d'=' -f2 | tr -d '"')

echo "Detected OS: $OS"

# Function to install and start SSH
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
        echo "Unsupported OS."
        exit 1
    fi
}

# Function to configure session timeout
configure_timeout() {
    echo "Configuring session timeout to 1 hour..."

    # 1 hour = 3600 seconds
    sudo bash -c 'echo "ClientAliveInterval 3600" >> /etc/ssh/sshd_config'
    sudo bash -c 'echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config'

    # Restart SSH service
    if [[ "$OS" == "ubuntu" ]]; then
        sudo systemctl restart ssh
    else
        sudo systemctl restart sshd
    fi
}

# Execute functions
setup_ssh
configure_timeout

echo "✅ SSH and 1-hour timeout setup complete."
