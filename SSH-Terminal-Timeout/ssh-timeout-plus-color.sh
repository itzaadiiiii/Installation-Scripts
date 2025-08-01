#!/bin/bash

# Script: ec2-terminal-color-setup.sh
# Purpose: Enhance EC2 terminal with mint-colored file-type output and styled prompt
# Supports: Amazon Linux, Ubuntu, CentOS

echo "🔧 Setting up custom terminal theme with mint green LS_COLORS..."

SHELL_RC="$HOME/.bashrc"

# Backup current shell config
cp "$SHELL_RC" "$SHELL_RC.bak.$(date +%s)"

# Create a custom dircolors file with mint-toned colors
cat << 'EOF' > ~/.dircolors.mint
# Custom LS_COLORS in mint green shades
# Format: <type>=[attributes]
# ANSI color codes used: 151, 120, 122, 159 (all mint shades)

# General types
DIR 01;38;5;120
LINK 01;38;5;122
EXEC 01;38;5;151
FIFO 01;38;5;159
SOCK 01;38;5;151
BLK 01;38;5;120
CHR 01;38;5;120
ORPHAN 01;38;5;122
MISSING 01;38;5;122

# File extensions
*.sh=01;38;5;151
*.txt=01;38;5;122
*.log=01;38;5;120
*.json=01;38;5;159
*.yml=01;38;5;151
*.yaml=01;38;5;151
*.env=01;38;5;122
*.conf=01;38;5;120
*.md=01;38;5;159
EOF

# Append shell enhancements to .bashrc
cat << 'EOF' >> "$SHELL_RC"

# === Color support ===
export CLICOLOR=1
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# === Apply custom minty dircolors ===
if command -v dircolors &> /dev/null; then
  eval "$(dircolors -b ~/.dircolors.mint)"
fi

# === Custom Prompt ===
# Top line: dusty pink (#A53860 → 131)
# Command input: teal-blue (#219EBC → 74)
# Output: mint variant via PROMPT_COMMAND + LS_COLORS
PS1='\[\e[38;5;131m\]\u@\h:\w\n\[\e[38;5;74m\]\$\[\e[0m\] '
PROMPT_COMMAND='echo -ne "\033[0;38;5;151m"'
trap "echo -ne '\033[0m'" DEBUG
EOF

echo -e "\n✅ Mint-themed terminal setup complete!"
echo "🔁 Please run 'source ~/.bashrc' or reconnect to apply changes."

# Get primary OS ID
OS=$(grep ^ID= /etc/os-release | head -n1 | cut -d= -f2 | tr -d '"')
echo "Detected OS: $OS"

# Function to install and start SSH
setup_ssh() {
    echo "🔐 Installing and enabling SSH..."

    if [[ "$OS" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y openssh-server
        sudo systemctl enable ssh
        sudo systemctl start ssh
    elif [[ "$OS" == "amzn" || "$OS" == "amazon" ]]; then
        if ! systemctl is-active --quiet sshd; then
            sudo yum install -y openssh-server
            sudo systemctl enable sshd
            sudo systemctl start sshd
        fi
    elif [[ "$OS" == "centos" ]]; then
        sudo yum install -y openssh-server
        sudo systemctl enable sshd
        sudo systemctl start sshd
    else
        echo "❌ Unsupported OS: $OS"
        exit 1
    fi
}

# Function to configure session timeout to 1 hour (3600 seconds)
configure_timeout() {
    echo "🕒 Configuring SSH session timeout to 1 hour..."

    # Remove any existing values
    sudo sed -i '/^ClientAliveInterval/d' /etc/ssh/sshd_config
    sudo sed -i '/^ClientAliveCountMax/d' /etc/ssh/sshd_config

    # Append new settings
    echo "ClientAliveInterval 3600" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    echo "ClientAliveCountMax 0"   | sudo tee -a /etc/ssh/sshd_config > /dev/null

    if [[ "$OS" == "ubuntu" ]]; then
        sudo systemctl restart ssh
    else
        sudo systemctl restart sshd
    fi
}

# Run setup
setup_ssh
configure_timeout

echo "✅ SSH is configured with a 1-hour session timeout."
