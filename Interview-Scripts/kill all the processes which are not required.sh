# Write a shell script function to find and kill all the processes which are not required.
#!/bin/bash

# Function to find and kill unnecessary processes
kill_unnecessary_processes() {
  local os_type
  local processes_to_kill

  # Determine the operating system
  if [[ -f /etc/os-release ]]; then
    os_type=$(grep -oP '(?<=^ID=).+' /etc/os-release)
  elif [[ -f /etc/redhat-release ]]; then
    os_type="centos" # or amazon
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

  # Define processes to kill based on the OS.
  case "$os_type" in
    ubuntu)
      processes_to_kill=(
        apport # Error reporting
        whoopsie # Canonical telemetry
        thermald # if excessive CPU usage. use caution.
        avahi-daemon # if not using network discovery
        snapd # if snaps are not used. Use caution.
        update-notifier # if you dont want update notifications
        gnome-software # if not using gnome software
        fwupd # if you dont need firmware updates.
      )
      ;;
    centos|rhel|fedora|amazon)
      processes_to_kill=(
        abrt-watch-log # Automated bug reporting tool
        abrtd # Automated bug reporting daemon
        firewalld # if you are using other firewall solutions.
        chronyd # if you dont need time synchronization
        NetworkManager-wait-online.service #if you dont need network online check.
        tuned # if not using tuned profiles.
        postfix # if not using mail server.
      )
      ;;
    *)
      echo "Unsupported operating system: $os_type"
      return 1
      ;;
  esac

  # Kill the processes
  for process in "${processes_to_kill[@]}"; do
    if pgrep -x "$process" > /dev/null; then
      echo "Killing process: $process"
      sudo pkill -x "$process"
    else
      echo "Process '$process' not found."
    fi
  done
}

# Example usage:
kill_unnecessary_processes
