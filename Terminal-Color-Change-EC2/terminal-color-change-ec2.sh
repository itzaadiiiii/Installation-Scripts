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

# Apply settings now
source "$SHELL_RC"

echo -e "\n✅ Mint-themed terminal ready! Try: ls, touch file.sh, mkdir test\n"
