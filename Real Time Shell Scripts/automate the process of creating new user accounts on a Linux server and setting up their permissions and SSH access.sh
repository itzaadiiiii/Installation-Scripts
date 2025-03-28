# Write a shell script to automate the process of creating new user accounts on a Linux server and setting up their permissions and SSH access

#!/bin/bash

# Function to create a new user account
create_user() {
  local username="$1"
  local password="$2"
  local group="$3"
  local ssh_key_path="$4"
  local os_type

  # Check if username and password are provided
  if [[ -z "$username" || -z "$password" ]]; then
    echo "Usage: $0 <username> <password> [group] [ssh_key_path]"
    return 1
  fi

  # Determine the operating system
  if [[ -f /etc/os-release ]]; then
    os_type=$(grep -oP '(?<=^ID=).+' /etc/os-release)
  elif [[ -f /etc/redhat-release ]]; then
    os_type="centos"
  elif [[ -f /etc/debian_version ]]; then
    os_type="ubuntu"
  else
    echo "Unsupported operating system."
    return 1
  fi

  # Modify OS detection for amazon linux 2
  if [[ "$os_type" == "amzn" ]]; then
      os_type="amazon"
  fi

  # Create the user account
  sudo useradd -m "$username"
  echo "$username:$password" | sudo chpasswd

  # Add user to a group if specified
  if [[ -n "$group" ]]; then
    sudo usermod -aG "$group" "$username"
  fi

  # Set up SSH access if SSH key path is provided
  if [[ -n "$ssh_key_path" ]]; then
    if [[ ! -f "$ssh_key_path" ]]; then
      echo "SSH key file not found: $ssh_key_path"
      return 1
    fi

    sudo mkdir -p /home/"$username"/.ssh
    sudo chmod 700 /home/"$username"/.ssh
    sudo cat "$ssh_key_path" | sudo tee -a /home/"$username"/.ssh/authorized_keys > /dev/null
    sudo chmod 600 /home/"$username"/.ssh/authorized_keys
    sudo chown -R "$username":"$username" /home/"$username"/.ssh
  fi

  echo "User '$username' created successfully."
  return 0
}

# Example usage:
# create_user "newuser" "password123" "sudo" "/path/to/ssh/key.pub"
# create_user "anotheruser" "securepass" "" "" # No group, no SSH key.
