# Write a shell script to automate the process of updating a list of servers with the latest security patches.

#!/bin/bash

# Configuration
SERVER_LIST="server1.example.com server2.example.com server3.example.com" # Replace with your servers
SSH_USER="your_ssh_user" # Replace with your SSH username
SSH_KEY="/path/to/your/ssh/private/key" # Replace with your SSH private key path
LOG_FILE="server_update_log.txt"

# Function to update a server
update_server() {
  local server="$1"
  local os_type
  local update_command

  # Determine the operating system on the remote server
  os_type=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$server" "if [[ -f /etc/os-release ]]; then grep -oP '(?<=^ID=).+' /etc/os-release; elif [[ -f /etc/redhat-release ]]; then echo 'centos'; elif [[ -f /etc/debian_version ]]; then echo 'ubuntu'; else echo 'unknown'; fi")

  # Modify OS detection for amazon linux 2
  if [[ "$os_type" == "amzn" ]]; then
      os_type="amazon"
  fi

  # Determine the update command based on the OS
  case "$os_type" in
    ubuntu|debian)
      update_command="sudo apt-get update && sudo apt-get upgrade -y"
      ;;
    centos|rhel|fedora|amazon)
      update_command="sudo yum update -y"
      ;;
    *)
      echo "Unsupported operating system on $server: $os_type" >> "$LOG_FILE"
      return 1
      ;;
  esac

  # Update the server
  echo "Updating $server..." >> "$LOG_FILE"
  if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SSH_USER@$server" "$update_command"; then
    echo "Server $server updated successfully." >> "$LOG_FILE"
    return 0
  else
    echo "Failed to update server $server." >> "$LOG_FILE"
    return 1
  fi
}

# Function to update all servers
update_servers() {
  local servers=($SERVER_LIST)

  for server in "${servers[@]}"; do
    update_server "$server"
  done
}

# Example usage:
update_servers
