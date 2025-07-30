#!/bin/bash

# Script: ec2-terminal-color-setup.sh
# Purpose: Enhance EC2 shell usability with colored command prompt and output.
# OS Support: Amazon Linux, CentOS, Ubuntu

echo "🔧 Setting up colorized terminal prompt and output..."

# Detect shell config file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

# Backup original shell config
cp "$SHELL_RC" "$SHELL_RC.bak.$(date +%s)"

# Append color configuration to shell config
cat << 'EOF' >> "$SHELL_RC"

# === Enable color for ls, grep ===
export CLICOLOR=1
export LS_OPTIONS='--color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# === Use dircolors if available ===
if command -v dircolors &> /dev/null && [ -r ~/.dircolors ]; then
  eval "$(dircolors -b ~/.dircolors)"
fi

# === Colored Prompt: Commands Green, Output Light Blue ===
# Commands = Green, Output = Cyan/Light Blue
PS1='\[\e[1;32m\]\u@\h:\w\n\$\[\e[0m\] '
PROMPT_COMMAND='echo -ne "\033[1;36m"'
trap "echo -ne '\033[0m'" DEBUG
EOF

# Generate default ~/.dircolors (optional, safe)
if command -v dircolors &> /dev/null; then
    dircolors -p > ~/.dircolors
fi

# Apply changes now
source "$SHELL_RC"

echo -e "\n✅ Terminal color setup complete! Test with: ls -l, cd, grep"
