# Shell script to Find the first 10 biggest files in the file system and write the output to a file 10_biggest_files.sh depending upon the distrubution like ubuntu,centos,amazon-linux etc , write such that it can run on any distribution

#!/bin/bash

# Function to find the 10 biggest files and write to a file
find_10_biggest_files() {
  local os_type
  local output_file="10_biggest_files.txt"

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

  # Find the 10 biggest files
  find / -xdev -type f -print0 2>/dev/null | xargs -0 ls -Slh 2>/dev/null | head -n 10 > "$output_file"

  # Check if the file was created
  if [[ -f "$output_file" ]]; then
    echo "The 10 biggest files have been written to $output_file."
  else
    echo "Failed to create $output_file."
    return 1
  fi
}

# Example usage:
find_10_biggest_files
