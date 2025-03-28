# Shell script to gracefully unmount a disk.

#!/bin/bash

# Function to gracefully unmount a disk
graceful_unmount() {
  local disk_path="$1"
  local os_type
  local umount_command

  # Check if a disk path is provided
  if [[ -z "$disk_path" ]]; then
    echo "Usage: $0 <disk_path>"
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

  # Check if the disk is mounted
  if ! mountpoint -q "$disk_path"; then
    echo "Disk '$disk_path' is not mounted."
    return 0 # Not mounted, so nothing to unmount
  fi

  # Unmount the disk
  umount_command="sudo umount \"$disk_path\""

  if eval "$umount_command"; then
    echo "Disk '$disk_path' unmounted successfully."
    return 0
  else
    echo "Failed to unmount disk '$disk_path'."
    return 1
  fi
}

# Example usage:
# graceful_unmount /dev/sdb1
# graceful_unmount /mnt/mydisk
