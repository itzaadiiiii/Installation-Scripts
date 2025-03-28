# Shell script that displays the number of failed login attempts by IP address and location.

#!/bin/bash

# Function to display failed login attempts by IP and location
failed_login_attempts() {
  local auth_log
  local os_type

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

  # Determine the authentication log file location
  case "$os_type" in
    ubuntu|debian)
      auth_log="/var/log/auth.log"
      ;;
    centos|rhel|fedora|amazon)
      auth_log="/var/log/secure"
      ;;
    *)
      echo "Unsupported operating system: $os_type"
      return 1
      ;;
  esac

  # Check if the authentication log file exists
  if [[ ! -f "$auth_log" ]]; then
    echo "Authentication log file not found: $auth_log"
    return 1
  fi

  # Extract failed login attempts, IP addresses, and use geoiplookup for location
  grep -i "Failed password" "$auth_log" | \
  awk '{
    for (i=1; i<=NF; i++) {
      if ($i ~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) {
        ip=$i;
        system("geoiplookup " ip " | awk -F': ' \'{print $2}\' ");
        print ip;
      }
    }
  }' | sort | uniq -c | sort -nr
}

# Example usage:
failed_login_attempts
