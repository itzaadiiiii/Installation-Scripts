# Shell script to Copy files recursively to remote hosts

#!/bin/bash

# Function to recursively copy files to remote hosts
copy_to_remote() {
  local source_dir="$1"
  local remote_hosts="$2"
  local remote_dest="$3"
  local os_type

  # Check for required arguments
  if [[ -z "$source_dir" || -z "$remote_hosts" || -z "$remote_dest" ]]; then
    echo "Usage: $0 <source_dir> <remote_hosts> <remote_dest>"
    echo "  <remote_hosts> can be a comma-separated list of hostnames or IPs."
    return 1
  fi

  # Determine the operating system (not critical for rsync, but good practice)
  if [[ -f /etc/os-release ]]; then
    os_type=$(grep -oP '(?<=^ID=).+' /etc/os-release)
  elif [[ -f /etc/redhat-release ]]; then
    os_type="centos"
  elif [[ -f /etc/debian_version ]]; then
    os_type="ubuntu"
  else
    echo "Unsupported operating system."
  fi

  # Modify OS detection for amazon linux 2
  if [[ "$os_type" == "amzn" ]]; then
      os_type="amazon"
  fi

  # Split the remote hosts string into an array
  local IFS=',' read -ra hosts <<< "$remote_hosts"

  # Iterate through the remote hosts and copy the files
  for host in "${hosts[@]}"; do
    host=$(echo "$host" | tr -d ' ') # Remove leading/trailing spaces
    if [[ -n "$host" ]]; then # check if host is not empty.
      echo "Copying files to $host:$remote_dest..."
      if rsync -avz "$source_dir/" "$host:$remote_dest"; then
        echo "Files copied successfully to $host:$remote_dest."
      else
        echo "Failed to copy files to $host:$remote_dest."
      fi
    fi
  done
}

# Example usage:
# copy_to_remote "/path/to/source/directory" "user@host1, user@host2, user@host3" "/remote/destination/directory"
# copy_to_remote "/local/data" "192.168.1.10, 192.168.1.11" "/var/www/remote_data"
